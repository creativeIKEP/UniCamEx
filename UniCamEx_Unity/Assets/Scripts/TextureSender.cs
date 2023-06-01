using UnityEngine;
using UniCamEx;

public class TextureSender : MonoBehaviour
{
    [SerializeField] Texture sendTexture; 

    void Update()
    {
        UniCamExPlugin.Send(sendTexture);
    }
}
