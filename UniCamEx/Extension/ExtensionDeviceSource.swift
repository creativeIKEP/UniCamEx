import Foundation
import CoreMediaIO
import os.log

class ExtensionDeviceSource: NSObject, CMIOExtensionDeviceSource {
    
    private(set) var device: CMIOExtensionDevice!
    
    private var _streamSource: ExtensionStreamSource!
    
    private var _sinkStreamSource: ExtensionSinkStreamSource!
    private var _sinking: Bool = false
    
    private var _streamingCounter: UInt32 = 0
    
    private var _timer: DispatchSourceTimer?
    
    private let _timerQueue = DispatchQueue(label: "timerQueue", qos: .userInteractive, attributes: [], autoreleaseFrequency: .workItem, target: .global(qos: .userInteractive))
    
    private var _videoDescription: CMFormatDescription!
    
    private var _bufferPool: CVPixelBufferPool!
    
    private var _bufferAuxAttributes: NSDictionary!
    
    private var _whiteStripeStartRow: UInt32 = 0
    
    private var _whiteStripeIsAscending: Bool = false
    
    init(localizedName: String) {
        
        super.init()
        let deviceID = UUID(uuidString: UniCamExConfig.DEVICE_ID)!
        self.device = CMIOExtensionDevice(localizedName: localizedName, deviceID: deviceID, legacyDeviceID: nil, source: self)
        
        let dims = CMVideoDimensions(width: 1920, height: 1080)
        CMVideoFormatDescriptionCreate(allocator: kCFAllocatorDefault, codecType: kCVPixelFormatType_32BGRA, width: dims.width, height: dims.height, extensions: nil, formatDescriptionOut: &_videoDescription)
        
        let pixelBufferAttributes: NSDictionary = [
            kCVPixelBufferWidthKey: dims.width,
            kCVPixelBufferHeightKey: dims.height,
            kCVPixelBufferPixelFormatTypeKey: _videoDescription.mediaSubType,
            kCVPixelBufferIOSurfacePropertiesKey: [:] as NSDictionary
        ]
        CVPixelBufferPoolCreate(kCFAllocatorDefault, nil, pixelBufferAttributes, &_bufferPool)
        
        let videoStreamFormat = CMIOExtensionStreamFormat.init(formatDescription: _videoDescription, maxFrameDuration: CMTime(value: 1, timescale: Int32(kFrameRate)), minFrameDuration: CMTime(value: 1, timescale: Int32(kFrameRate)), validFrameDurations: nil)
        _bufferAuxAttributes = [kCVPixelBufferPoolAllocationThresholdKey: 5]
        
        let videoID = UUID(uuidString: UniCamExConfig.VIDEO_ID)!
        _streamSource = ExtensionStreamSource(localizedName: "\(VIRTUAL_CAMERA_NAME).Video", streamID: videoID, streamFormat: videoStreamFormat, device: device)
        
        let sinkStreamID = UUID(uuidString: UniCamExConfig.SINK_STREAM_ID)!
        _sinkStreamSource = ExtensionSinkStreamSource(localizedName: "\(VIRTUAL_CAMERA_NAME).Video.Sink", streamID: sinkStreamID, streamFormat: videoStreamFormat, device: device)
        do {
            try device.addStream(_streamSource.stream)
            try device.addStream(_sinkStreamSource.stream)
        } catch let error {
            fatalError("Failed to add stream: \(error.localizedDescription)")
        }
    }
    
    var availableProperties: Set<CMIOExtensionProperty> {
        
        return [.deviceTransportType, .deviceModel]
    }
    
    func deviceProperties(forProperties properties: Set<CMIOExtensionProperty>) throws -> CMIOExtensionDeviceProperties {
        
        let deviceProperties = CMIOExtensionDeviceProperties(dictionary: [:])
        if properties.contains(.deviceTransportType) {
            deviceProperties.transportType = kIOAudioDeviceTransportTypeVirtual
        }
        if properties.contains(.deviceModel) {
            deviceProperties.model = VIRTUAL_CAMERA_NAME
        }
        
        return deviceProperties
    }
    
    func setDeviceProperties(_ deviceProperties: CMIOExtensionDeviceProperties) throws {
        
        // Handle settable properties here.
    }
    
    func startStreaming() {
        
        guard let _ = _bufferPool else {
            return
        }
        
        _streamingCounter += 1
        
        _timer = DispatchSource.makeTimerSource(flags: .strict, queue: _timerQueue)
        _timer!.schedule(deadline: .now(), repeating: 1.0 / Double(kFrameRate), leeway: .seconds(0))
        
        _timer!.setEventHandler {
            if self._sinking { return }
            
            var err: OSStatus = 0
            let now = CMClockGetTime(CMClockGetHostTimeClock())
            
            var pixelBuffer: CVPixelBuffer?
            err = CVPixelBufferPoolCreatePixelBufferWithAuxAttributes(kCFAllocatorDefault, self._bufferPool, self._bufferAuxAttributes, &pixelBuffer)
            if err != 0 {
                os_log(.error, "out of pixel buffers \(err)")
            }
            
            if let pixelBuffer = pixelBuffer {
                
                CVPixelBufferLockBaseAddress(pixelBuffer, [])
                
                var bufferPtr = CVPixelBufferGetBaseAddress(pixelBuffer)!
                let width = CVPixelBufferGetWidth(pixelBuffer)
                let height = CVPixelBufferGetHeight(pixelBuffer)
                let rowBytes = CVPixelBufferGetBytesPerRow(pixelBuffer)
                memset(bufferPtr, 0, rowBytes * height)
                
                let whiteStripeStartRow = self._whiteStripeStartRow
                if self._whiteStripeIsAscending {
                    self._whiteStripeStartRow = whiteStripeStartRow - 1
                    self._whiteStripeIsAscending = self._whiteStripeStartRow > 0
                }
                else {
                    self._whiteStripeStartRow = whiteStripeStartRow + 1
                    self._whiteStripeIsAscending = self._whiteStripeStartRow >= (height - kWhiteStripeHeight)
                }
                bufferPtr += rowBytes * Int(whiteStripeStartRow)
                for _ in 0..<kWhiteStripeHeight {
                    for _ in 0..<width {
                        var white: UInt32 = 0xFFFFFFFF
                        memcpy(bufferPtr, &white, MemoryLayout.size(ofValue: white))
                        bufferPtr += MemoryLayout.size(ofValue: white)
                    }
                }
                
                CVPixelBufferUnlockBaseAddress(pixelBuffer, [])
                
                var sbuf: CMSampleBuffer!
                var timingInfo = CMSampleTimingInfo()
                timingInfo.presentationTimeStamp = CMClockGetTime(CMClockGetHostTimeClock())
                err = CMSampleBufferCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: pixelBuffer, dataReady: true, makeDataReadyCallback: nil, refcon: nil, formatDescription: self._videoDescription, sampleTiming: &timingInfo, sampleBufferOut: &sbuf)
                if err == 0 {
                    self._streamSource.stream.send(sbuf, discontinuity: [], hostTimeInNanoseconds: UInt64(timingInfo.presentationTimeStamp.seconds * Double(NSEC_PER_SEC)))
                }
                os_log(.info, "video time \(timingInfo.presentationTimeStamp.seconds) now \(now.seconds) err \(err)")
            }
        }
        
        _timer!.setCancelHandler {
        }
        
        _timer!.resume()
    }
    
    func stopStreaming() {
        
        if _streamingCounter > 1 {
            _streamingCounter -= 1
        }
        else {
            _streamingCounter = 0
            if let timer = _timer {
                timer.cancel()
                _timer = nil
            }
        }
    }
    
    func startSinkStreaming() {
        _sinking = true
        _sinkStreamSource.consumeSampleBuffer = { [weak self] buffer in
            if self?._streamingCounter == 0 { return }
            var timingInfo = CMSampleTimingInfo()
            timingInfo.presentationTimeStamp = CMClockGetTime(CMClockGetHostTimeClock())
            let nanoSec = UInt64(timingInfo.presentationTimeStamp.seconds * Double(NSEC_PER_SEC))
            self?._streamSource.stream.send(buffer,
                                            discontinuity: [],
                                            hostTimeInNanoseconds: nanoSec)
        }
    }
    func stopSinkStreaming() {
        _sinking = false
        _sinkStreamSource.consumeSampleBuffer = nil
    }
}
