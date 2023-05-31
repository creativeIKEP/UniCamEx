#import <Metal/Metal.h>
#include <SystemExtensions/SystemExtensions.h>
#include <UniCamExBundle-Swift.h>

extern "C" {
    UniCamEx *uniCamExModel = [[UniCamEx alloc] init];

    void UniCamExSend(unsigned char* mtlTexture) {
        id<MTLTexture> tex = (__bridge id<MTLTexture>)(void*)mtlTexture;
        [uniCamExModel UniCamExSendWithTexture:tex];
    }
}
