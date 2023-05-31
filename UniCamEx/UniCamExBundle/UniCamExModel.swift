import Foundation
import AVFoundation
import CoreMediaIO
import os.log
import SystemExtensions

public class UniCamExModel {
    public let VIRTUAL_CAMERA_NAME = "UniCamEx"
    private let textureConverter = MtlTextureToSampleBufferConverter(width: 1920, height: 1080)
    let uniCamExModelInstaller = UniCamExModelInstaller()
    
    private var isSetupping: Bool = false
    private var streamQueue: CMSimpleQueue?
    private var isStreaming: Bool = false
    private var shouldEnqueue: Bool = false
    
    public init() {
        uniCamExModelInstaller.install()
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
        guard let cd = getCaptureDevice(name: VIRTUAL_CAMERA_NAME) else {
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

class UniCamExModelInstaller: NSObject {
    private (set) public var isInstalled: Bool = false
    private let extID: String = "jp.ikep.UniCamEx.Extension"
    
    public func install() {
        let activationRequest = OSSystemExtensionRequest.activationRequest(forExtensionWithIdentifier: extID, queue: .main)
        activationRequest.delegate = self
        OSSystemExtensionManager.shared.submitRequest(activationRequest)
    }
    
    public func uninstall() {
        let activationRequest = OSSystemExtensionRequest.deactivationRequest(forExtensionWithIdentifier: extID, queue: .main)
        activationRequest.delegate = self
        OSSystemExtensionManager.shared.submitRequest(activationRequest)
    }
}

extension UniCamExModelInstaller: OSSystemExtensionRequestDelegate {
    func request(_ request: OSSystemExtensionRequest,
                 actionForReplacingExtension existing: OSSystemExtensionProperties,
                 withExtension ext: OSSystemExtensionProperties) -> OSSystemExtensionRequest.ReplacementAction {
        os_log("actionForReplacingExtension: \(existing), withExtension: \(ext)")
        return .replace
    }

    func requestNeedsUserApproval(_ request: OSSystemExtensionRequest) {
        os_log("Extension needs user request!")
    }

    func request(_ request: OSSystemExtensionRequest, didFinishWithResult result: OSSystemExtensionRequest.Result) {
        os_log("Request finished with result: \(result.rawValue)")
    }

    func request(_ request: OSSystemExtensionRequest, didFailWithError error: Error) {
        os_log("request failed: \(error)")
    }
}
