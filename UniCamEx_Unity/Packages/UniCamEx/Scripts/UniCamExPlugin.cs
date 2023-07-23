using System;
using System.Runtime.InteropServices;
using UnityEngine;

namespace UniCamEx {
    public static class UniCamExPlugin
    {
        private static RenderTexture _sendTexture = RenderTexture.GetTemporary(1920, 1080);
        private static readonly Material FlipMaterial = Resources.Load<Material>("Flip");
        private static readonly int IsHorizontalFlipId = Shader.PropertyToID("_isHorizontalFlip");

        public static void Send(Texture texture, bool isHorizontalFlip = false){
            #if UNITY_EDITOR_OSX || UNITY_STANDALONE_OSX
            if(texture.GetNativeTexturePtr() == IntPtr.Zero) return;
            
            if(_sendTexture.width != texture.width || _sendTexture.height != texture.height) {
                RenderTexture.ReleaseTemporary(_sendTexture);
                _sendTexture = RenderTexture.GetTemporary(texture.width, texture.height);
            }
            FlipMaterial.SetInt(IsHorizontalFlipId, isHorizontalFlip ? 1 : 0);
            Graphics.Blit(texture, _sendTexture, FlipMaterial);
            UniCamExSend(_sendTexture.GetNativeTexturePtr());
            #endif
        }

        #if UNITY_EDITOR_OSX || UNITY_STANDALONE_OSX
        [DllImport("UniCamExBundle")]
        private static extern void UniCamExSend(IntPtr mtlTexture);
        #endif
    }
}