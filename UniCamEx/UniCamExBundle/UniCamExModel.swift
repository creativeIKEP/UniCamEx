import Foundation
import AVFoundation
import CoreMediaIO
import os.log
import SystemExtensions

public class UniCamExModel {
    private let textureConverter = MtlTextureToSampleBufferConverter(width: 1920, height: 1080)
    let uniCamExInstaller = UniCamExInstaller()
    
    private var isSetupping: Bool = false
    private var streamQueue: CMSimpleQueue?
    private var isStreaming: Bool = false
    private var shouldEnqueue: Bool = false
    
    public init() {
        uniCamExInstaller.install()
        setup()
    }
    
    public func onRecieveTexture(texture: MTLTexture) {
        if !(isStreaming && shouldEnqueue) {
            return
        }
        guard let streamQueue else { return }
        
        let time = CMClockGetTime(CMClockGetHostTimeClock())
        guard let buffer = textureConverter.convert(mtlTexture: texture, time: time) else { return }
        
        CMSimpleQueueEnqueue(streamQueue, element: Unmanaged.passRetained(buffer).toOpaque())
        
        shouldEnqueue = false
    }
    
    private func setup(){
        guard let cd = getCaptureDevice(name: UniCamExConfig.VIRTUAL_CAMERA_NAME) else {
            print("no capture device")
            return
        }
        
        let deviceIDs = CoreMediaIOUtil.getDeviceIDs()
        if deviceIDs.isEmpty {
            print("deviceIDs is empty")
            return
        }
        print("deviceIDs: \(deviceIDs)")
        
        guard let deviceID = deviceIDs
            .first(where: { CoreMediaIOUtil.getDeviceUID(deviceID: $0) == cd.uniqueID }) else {
            print("no math deviceID")
            return
        }
        print("deviceID: \(deviceID)")
        
        let streams = CoreMediaIOUtil.getStreams(deviceID: deviceID)
        if streams.count < 2 {
            print("Streams is less than expected")
            return
        }
        startStream(deviceID: deviceID, streamID: streams[1])
    }
    
    private func getCaptureDevice(name: String) -> AVCaptureDevice? {
        AVCaptureDevice
            .DiscoverySession(deviceTypes: [.externalUnknown],
                              mediaType: .video,
                              position: .unspecified)
            .devices
            .first { $0.localizedName == name }
    }
    
    private func startStream(deviceID: CMIODeviceID, streamID: CMIOStreamID) {
        let proc: CMIODeviceStreamQueueAlteredProc = { (streamID: CMIOStreamID,
                                                        token: UnsafeMutableRawPointer?,
                                                        refCon: UnsafeMutableRawPointer?) in
            guard let refCon else { return }
            let con = Unmanaged<UniCamExModel>.fromOpaque(refCon).takeUnretainedValue()
            con.alteredProc()
        }
        let refCon = Unmanaged.passUnretained(self).toOpaque()
        streamQueue = CoreMediaIOUtil.startStream(deviceID: deviceID, streamID: streamID, proc: proc, refCon: refCon)
        isStreaming = true
        shouldEnqueue = true
    }
    
    private func alteredProc() {
        if !isStreaming { return }
        shouldEnqueue = true
    }
}
