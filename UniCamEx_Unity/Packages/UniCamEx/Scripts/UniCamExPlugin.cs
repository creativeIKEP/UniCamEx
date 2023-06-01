using System;
using System.Runtime.InteropServices;
using UnityEngine;

namespace UniCamEx {
    public class UniCamExPlugin
    {
        private static Material material = Resources.Load<Material>("Flip");

        public static void Send(Texture texture){
            #if UNITY_EDITOR_OSX || UNITY_STANDALONE_OSX
            if(texture.GetNativeTexturePtr() == IntPtr.Zero) return;
            var tmpTex = RenderTexture.GetTemporary(texture.width, texture.height);
            Graphics.Blit(texture, tmpTex, material);
            UniCamExSend(tmpTex.GetNativeTexturePtr());
            RenderTexture.ReleaseTemporary(tmpTex);
            #endif
        }

        #if UNITY_EDITOR_OSX || UNITY_STANDALONE_OSX
        [DllImport("UniCamExBundle")]
        private static extern void UniCamExSend(IntPtr mtlTexture);
        #endif
    }
}