import CoreMediaIO
import Foundation

class CoreMediaIOUtil {
    private init() {}

    static func getDeviceIDs() -> [CMIODeviceID] {
        var res: OSStatus
        var opa = CMIOObjectPropertyAddress(
            mSelector: CMIOObjectPropertySelector(kCMIOHardwarePropertyDevices),
            mScope: CMIOObjectPropertyScope(kCMIOObjectPropertyScopeGlobal),
            mElement: CMIOObjectPropertyElement(kCMIOObjectPropertyElementMain)
        )
        var dataSize: UInt32 = 0
        res = CMIOObjectGetPropertyDataSize(CMIODeviceID(kCMIOObjectSystemObject),
                                            &opa, 0, nil, &dataSize)
        if res != noErr {
            print("failed CMIOObjectGetPropertyDataSize")
            return []
        }
        let count = Int(dataSize) / MemoryLayout<CMIODeviceID>.size
        var dataUsed: UInt32 = 0
        var devices = [CMIODeviceID](repeating: 0, count: count)
        res = CMIOObjectGetPropertyData(CMIOObjectPropertySelector(kCMIOObjectSystemObject),
                                        &opa, 0, nil, dataSize, &dataUsed, &devices)
        if res != noErr {
            print("failed CMIOObjectGetPropertyData")
            return []
        }
        return devices
    }

    static func getDeviceUID(deviceID: CMIODeviceID) -> String? {
        var res: OSStatus
        var opa = CMIOObjectPropertyAddress(
            mSelector: CMIOObjectPropertySelector(kCMIODevicePropertyDeviceUID),
            mScope: CMIOObjectPropertyScope(kCMIOObjectPropertyScopeGlobal),
            mElement: CMIOObjectPropertyElement(kCMIOObjectPropertyElementMain)
        )
        var dataSize: UInt32 = 0
        res = CMIOObjectGetPropertyDataSize(deviceID, &opa, 0, nil, &dataSize)
        if res != noErr {
            print("failed CMIOObjectGetPropertyDataSize")
            return nil
        }
        var dataUsed: UInt32 = 0
        var deviceUID: NSString = ""
        res = CMIOObjectGetPropertyData(deviceID, &opa, 0, nil, dataSize, &dataUsed, &deviceUID)
        if res != noErr {
            print("failed CMIOObjectGetPropertyData")
            return nil
        }
        return deviceUID as String
    }

    static func getStreams(deviceID: CMIODeviceID) -> [CMIOStreamID] {
        var res: OSStatus
        var opa = CMIOObjectPropertyAddress(
            mSelector: CMIOObjectPropertySelector(kCMIODevicePropertyStreams),
            mScope: CMIOObjectPropertyScope(kCMIOObjectPropertyScopeGlobal),
            mElement: CMIOObjectPropertyElement(kCMIOObjectPropertyElementMain)
        )
        var dataSize: UInt32 = 0
        res = CMIOObjectGetPropertyDataSize(deviceID, &opa, 0, nil, &dataSize)
        if res != noErr {
            print("failed CMIOObjectGetPropertyDataSize")
            return []
        }
        var dataUsed: UInt32 = 0
        let count = Int(dataSize) / MemoryLayout<CMIOStreamID>.size
        var streams = [CMIOStreamID](repeating: 0, count: count)
        res = CMIOObjectGetPropertyData(deviceID, &opa, 0, nil, dataSize, &dataUsed, &streams)
        if res != noErr {
            print("failed CMIOObjectGetPropertyData")
            return []
        }
        return streams
    }

    static func startStream(deviceID: CMIODeviceID,
                            streamID: CMIOStreamID,
                            proc: CMIODeviceStreamQueueAlteredProc,
                            refCon: UnsafeMutableRawPointer) -> CMSimpleQueue? {
        var res: OSStatus
        var queuePtr: Unmanaged<CMSimpleQueue>? = nil
        res = CMIOStreamCopyBufferQueue(streamID, proc, refCon, &queuePtr)
        if res != noErr {
            print("failed CMIOStreamCopyBufferQueue")
            return nil
        }
        res = CMIODeviceStartStream(deviceID, streamID)
        if res != noErr {
            print("failed CMIOStreamCopyBufferQueue")
            return nil
        }
        return queuePtr?.takeUnretainedValue()
    }
}
