import CoreMediaIO
import Foundation
import os.log

class ExtensionSinkStreamSource: NSObject, CMIOExtensionStreamSource {
    var consumeSampleBuffer: ((CMSampleBuffer) -> Void)?

    private(set) var stream: CMIOExtensionStream!
    let device: CMIOExtensionDevice
    private let _streamFormat: CMIOExtensionStreamFormat
    private var client: CMIOExtensionClient?

    init(localizedName: String, streamID: UUID, streamFormat: CMIOExtensionStreamFormat, device: CMIOExtensionDevice) {
        self.device = device
        self._streamFormat = streamFormat
        super.init()
        self.stream = CMIOExtensionStream(localizedName: localizedName,
                                          streamID: streamID,
                                          direction: .sink,
                                          clockType: .hostTime,
                                          source: self)
    }

    var formats: [CMIOExtensionStreamFormat] {
        return [_streamFormat]
    }
    var activeFormatIndex: Int = 0 {
        didSet {
            if activeFormatIndex >= 1 {
                os_log(.error, "Invalid index")
            }
        }
    }
    var availableProperties: Set<CMIOExtensionProperty> {
        [
            .streamActiveFormatIndex,
            .streamFrameDuration,
            .streamSinkBufferQueueSize,
            .streamSinkBuffersRequiredForStartup,
        ]
    }
    func streamProperties(forProperties properties: Set<CMIOExtensionProperty>) throws -> CMIOExtensionStreamProperties {
        let streamProperties = CMIOExtensionStreamProperties(dictionary: [:])
        if properties.contains(.streamActiveFormatIndex) {
            streamProperties.activeFormatIndex = 0
        }
        if properties.contains(.streamFrameDuration) {
            let frameDuration = CMTime(value: 1, timescale: Int32(kFrameRate))
            streamProperties.frameDuration = frameDuration
        }
        if properties.contains(.streamSinkBufferQueueSize) {
            streamProperties.sinkBufferQueueSize = 1
        }
        if properties.contains(.streamSinkBuffersRequiredForStartup) {
            streamProperties.sinkBuffersRequiredForStartup = 1
        }
        return streamProperties
    }

    func setStreamProperties(_ streamProperties: CMIOExtensionStreamProperties) throws {
        if let activeFormatIndex = streamProperties.activeFormatIndex {
            self.activeFormatIndex = activeFormatIndex
        }
    }

    func authorizedToStartStream(for client: CMIOExtensionClient) -> Bool {
        self.client = client
        // An opportunity to inspect the client info and decide if it should be allowed to start the stream.
        return true
    }

    func startStream() throws {
        guard let deviceSource = device.source as? ExtensionDeviceSource else {
            fatalError("Unexpected source type \(String(describing: device.source))")
        }
        deviceSource.startSinkStreaming()
        subscribe()
    }

    func stopStream() throws {
        guard let deviceSource = device.source as? ExtensionDeviceSource else {
            fatalError("Unexpected source type \(String(describing: device.source))")
        }
        deviceSource.stopSinkStreaming()
    }

    private func subscribe() {
        guard let client else { return }
        stream.consumeSampleBuffer(from: client) { [weak self] (sampleBuffer: CMSampleBuffer?,
                                                                sampleBufferSequenceNumber: UInt64,
                                                                discontinuity: CMIOExtensionStream.DiscontinuityFlags,
                                                                hasMoreSampleBuffers: Bool,
                                                                error: Error?) in
            if let error {
                return
            }
            defer { self?.subscribe() }
            if let sampleBuffer {
                self?.consumeSampleBuffer?(sampleBuffer)
                let presentationNanoSec = UInt64(sampleBuffer.presentationTimeStamp.seconds * Double(NSEC_PER_SEC))
                let output = CMIOExtensionScheduledOutput(sequenceNumber: sampleBufferSequenceNumber,
                                                          hostTimeInNanoseconds: presentationNanoSec)
                self?.stream.notifyScheduledOutputChanged(output)
            }
        }
    }
}
