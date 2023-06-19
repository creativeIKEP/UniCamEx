using UnityEngine;

public class TextureSender : MonoBehaviour
{
    [SerializeField] private bool isHorizontalFlip;
    [SerializeField] private Texture sendTexture; 

    private void Update()
    {
#if UNITY_EDITOR_OSX || UNITY_STANDALONE_OSX
      UniCamEx.UniCamExPlugin.Send(sendTexture, isHorizontalFlip);  
#endif
    }
}
