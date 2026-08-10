using UnityEngine;

public class FluidPainter : MonoBehaviour
{
    private static class Uniforms
    {
        public static int BrushCenter = Shader.PropertyToID("_BrushCenter");
        public static int BrushRadius = Shader.PropertyToID("_BrushRadius");
        public static int BrushStrength = Shader.PropertyToID("_BrushStrength");
    }
    public enum TextureSize { _64x64 = 64, _128x128 = 128, _256x256 = 256, _512x512 = 512, _1024x1024 = 1024 }

    [SerializeField] TextureSize textureSize = TextureSize._512x512;
    [SerializeField][Min(1)] int brushRadius = 16;
    [SerializeField][Range(0.0f, 1.0f)] float brushStrength = 0.25f;
    [SerializeField] Material brushMaterial;

    public RenderTexture maskTexture, tempTexture;

    void Start()
    {
        maskTexture = new RenderTexture((int)textureSize, (int)textureSize, 0, RenderTextureFormat.RGHalf);
        maskTexture.filterMode = FilterMode.Bilinear;
        maskTexture.wrapMode = TextureWrapMode.Clamp;
        maskTexture.Create();

        tempTexture = new RenderTexture((int)textureSize, (int)textureSize, 0, RenderTextureFormat.RGHalf);
        tempTexture.filterMode = FilterMode.Bilinear;
        tempTexture.wrapMode = TextureWrapMode.Clamp;
        tempTexture.Create();
    }

    void Update()
    {
        if (Input.GetMouseButton(0))
        {
            HandleInput();
        }

    }

    private void OnDestroy()
    {
        if (maskTexture != null)
        {
            maskTexture.Release();
            maskTexture = null;
        }

        if (tempTexture != null)
        {
            tempTexture.Release();
            tempTexture = null;
        }
    }

    private void HandleInput()
    {
        Ray inputRay = Camera.main.ScreenPointToRay(Input.mousePosition);
        if (Physics.Raycast(inputRay, out RaycastHit hit))
        {
            brushMaterial.SetVector(Uniforms.BrushCenter, hit.textureCoord);
            brushMaterial.SetFloat(Uniforms.BrushStrength, brushStrength);
            brushMaterial.SetFloat(Uniforms.BrushRadius, (float)brushRadius / ((int)textureSize - 1));
            Graphics.Blit(maskTexture, tempTexture, brushMaterial);
            (maskTexture, tempTexture) = (tempTexture, maskTexture);
        }
    }
}
