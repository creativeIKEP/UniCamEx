using System;
using System.Runtime.InteropServices;
using UnityEngine;

namespace UniCamEx {
    public class UniCamExPlugin
    {
        private static Material _material = Resources.Load<Material>("Flip");
        private static RenderTexture _sendTexture = RenderTexture.GetTemporary(1920, 1080);

        public static void Send(Texture texture, bool isHorizontalFlip = false){
            #if UNITY_EDITOR_OSX || UNITY_STANDALONE_OSX
            if(texture.GetNativeTexturePtr() == IntPtr.Zero) return;
            
            if(_sendTexture.width != texture.width || _sendTexture.height != texture.height) {
                RenderTexture.ReleaseTemporary(_sendTexture);
                _sendTexture = RenderTexture.GetTemporary(texture.width, texture.height);
            }
            _material.SetInt("_isHorizontalFlip", isHorizontalFlip ? 1 : 0);
            Graphics.Blit(texture, _sendTexture, _material);
            UniCamExSend(_sendTexture.GetNativeTexturePtr());
            #endif
        }

        #if UNITY_EDITOR_OSX || UNITY_STANDALONE_OSX
        [DllImport("UniCamExBundle")]
        private static extern void UniCamExSend(IntPtr mtlTexture);
        #endif
    }
}