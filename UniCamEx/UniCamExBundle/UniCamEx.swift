import Foundation
import Metal

@objcMembers
public class UniCamEx : NSObject {
    let uniCamExModel = UniCamExModel()
    
    public override init() {
        super.init()
    }
    
    public func UniCamExSend(texture: MTLTexture) {
        uniCamExModel.onRecieveTexture(texture: texture)
    }
}
