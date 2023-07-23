import Foundation
import os.log
import SystemExtensions

class UniCamExInstaller: NSObject {
    private (set) public var isInstalled: Bool = false
    
    public func install() {
        let activationRequest = OSSystemExtensionRequest.activationRequest(forExtensionWithIdentifier: UniCamExConfig.CAMERA_EXTENSION_ID, queue: .main)
        activationRequest.delegate = self
        OSSystemExtensionManager.shared.submitRequest(activationRequest)
    }
    
    public func uninstall() {
        let activationRequest = OSSystemExtensionRequest.deactivationRequest(forExtensionWithIdentifier: UniCamExConfig.CAMERA_EXTENSION_ID, queue: .main)
        activationRequest.delegate = self
        OSSystemExtensionManager.shared.submitRequest(activationRequest)
    }
}

extension UniCamExInstaller: OSSystemExtensionRequestDelegate {
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
