using UnityEngine;

public class TextureSender : MonoBehaviour
{
    [SerializeField] bool isHorizontalFlip = false;
    [SerializeField] Texture sendTexture; 

    void Update()
    {
#if UNITY_EDITOR_OSX || UNITY_STANDALONE_OSX
      UniCamEx.UniCamExPlugin.Send(sendTexture, isHorizontalFlip);  
#endif
    }
}
