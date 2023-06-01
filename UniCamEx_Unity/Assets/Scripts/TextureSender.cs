using UnityEngine;
using UniCamEx;

public class TextureSender : MonoBehaviour
{
    [SerializeField] bool isHorizontalFlip = false;
    [SerializeField] Texture sendTexture; 

    void Update()
    {
        UniCamExPlugin.Send(sendTexture, isHorizontalFlip);
    }
}
