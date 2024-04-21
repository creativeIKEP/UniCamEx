using System;
using System.Runtime.InteropServices;
using UnityEngine;

namespace UniCamEx
{
    public class UniCamExPlugin : IDisposable
    {
        private readonly int _isHorizontalFlipId = Shader.PropertyToID("_isHorizontalFlip");
        private readonly Material _flipMaterial;
        private RenderTexture _sendTexture;
        private IntPtr _texturePtr = IntPtr.Zero;

        public UniCamExPlugin()
        {
            _flipMaterial = Resources.Load<Material>("Flip");
        }

        public void Send(Texture texture, bool isHorizontalFlip = false)
        {
#if UNITY_EDITOR_OSX || UNITY_STANDALONE_OSX
            if (texture == null) return;

            if (_sendTexture == null || _sendTexture.width != texture.width || _sendTexture.height != texture.height)
            {
                ReleaseSendTexture();
                _sendTexture = RenderTexture.GetTemporary(texture.width, texture.height);
                _texturePtr = _sendTexture.GetNativeTexturePtr();
            }

            _flipMaterial.SetInt(_isHorizontalFlipId, isHorizontalFlip ? 1 : 0);
            Graphics.Blit(texture, _sendTexture, _flipMaterial);
            UniCamExSend(_texturePtr);
#endif
        }

        public void Dispose()
        {
            ReleaseSendTexture();
        }

        private void ReleaseSendTexture()
        {
            if (_sendTexture != null)
            {
                RenderTexture.ReleaseTemporary(_sendTexture);
                _texturePtr = IntPtr.Zero;
            }
        }

#if UNITY_EDITOR_OSX || UNITY_STANDALONE_OSX
        [DllImport("UniCamExBundle")]
        private static extern void UniCamExSend(IntPtr mtlTexture);
#endif
    }
}