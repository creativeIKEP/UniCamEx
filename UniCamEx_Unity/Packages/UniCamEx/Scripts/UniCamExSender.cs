using UnityEngine;

namespace UniCamEx
{
    public class UniCamExSender : MonoBehaviour
    {
        [SerializeField] private bool isHorizontalFlip;

        private UniCamExPlugin _uniCamExPlugin;
        private RenderTexture _sendRenderTexture;

        private void Start()
        {
            _uniCamExPlugin = new UniCamExPlugin();
        }

        private void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
#if UNITY_EDITOR_OSX || UNITY_STANDALONE_OSX
            if (_sendRenderTexture == null || _sendRenderTexture.width != source.width ||
                _sendRenderTexture.height != source.height)
            {
                _sendRenderTexture = new RenderTexture(source.width, source.height, 0);
            }

            var tmp = RenderTexture.GetTemporary(_sendRenderTexture.width, _sendRenderTexture.height, 0,
                RenderTextureFormat.Default, RenderTextureReadWrite.Default);
            Graphics.Blit(source, tmp);
            Graphics.CopyTexture(tmp, _sendRenderTexture);
            RenderTexture.ReleaseTemporary(tmp);
            
            _uniCamExPlugin.Send(_sendRenderTexture, isHorizontalFlip);
#endif

            Graphics.Blit(source, destination);
        }

        private void OnDestroy()
        {
            Destroy(_sendRenderTexture);
            _uniCamExPlugin.Dispose();
        }
    }
}