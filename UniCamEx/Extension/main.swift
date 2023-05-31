import Foundation
import CoreMediaIO

// For ExtensionProviderSource & ExtensionDeviceSource & ExtensionStreamSource
let VIRTUAL_CAMERA_NAME = "UniCamEx"
let kWhiteStripeHeight: Int = 10
let kFrameRate: Int = 60

let providerSource = ExtensionProviderSource(clientQueue: nil)
CMIOExtensionProvider.startService(provider: providerSource.provider)

CFRunLoopRun()
