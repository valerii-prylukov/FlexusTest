using UnityEngine;

public class FluidDisplacement : MonoBehaviour
{
    private static class Uniforms
    {
        public static readonly int BrushCenter          = Shader.PropertyToID("_BrushCenter");
        public static readonly int BrushRadius          = Shader.PropertyToID("_BrushRadius");
        public static readonly int BrushStrength        = Shader.PropertyToID("_BrushStrength");
        public static readonly int RingRadius           = Shader.PropertyToID("_RingRadius");
        public static readonly int RingStrength         = Shader.PropertyToID("_RingStrength");
        public static readonly int FluidMask            = Shader.PropertyToID("_FluidMask");
        public static readonly int BrushActive          = Shader.PropertyToID("_BrushActive");
        public static readonly int DeltaTime            = Shader.PropertyToID("_DeltaTime");
        public static readonly int OscillationDamping   = Shader.PropertyToID("_OscillationDamping");
        public static readonly int OscillationFrequency = Shader.PropertyToID("_OscillationFrequency");
    }
    public enum TextureSize { _64x64 = 64, _128x128 = 128, _256x256 = 256, _512x512 = 512, _1024x1024 = 1024 }

    [SerializeField] TextureSize textureSize = TextureSize._512x512;
    [SerializeField][Min(1)] int brushRadius = 16;
    [SerializeField][Range(0.0f, 1.0f)] float brushStrength = 0.25f;
    [SerializeField][Range(1.0f, 2.0f)] float ringRadius = 1.5f;
    [SerializeField][Range(0.0f, 1.0f)] float ringStrength = 0.35f;
    [SerializeField][Range(0.0f, 1.0f)] float ostillationDamping = 0.5f;
    [SerializeField][Min(0.0f)] float ostillationFrequency = 16.0f;
    [SerializeField] Material brushMaterial;
    [SerializeField] Material fluidMaterial;

    private RenderTexture maskTexture, tempTexture; 
    private Camera mainCamera;

    void Start()
    {
        mainCamera = Camera.main;

        maskTexture = new RenderTexture((int)textureSize, (int)textureSize, 0, RenderTextureFormat.RGHalf);
        maskTexture.filterMode = FilterMode.Bilinear;
        maskTexture.wrapMode = TextureWrapMode.Clamp;
        maskTexture.Create();
        ClearRenderTexture(maskTexture);

        tempTexture = new RenderTexture((int)textureSize, (int)textureSize, 0, RenderTextureFormat.RGHalf);
        tempTexture.filterMode = FilterMode.Bilinear;
        tempTexture.wrapMode = TextureWrapMode.Clamp;
        tempTexture.Create();
        ClearRenderTexture(tempTexture);

        fluidMaterial.SetTexture(Uniforms.FluidMask, maskTexture);
    }

    void Update()
    {
        bool brushActive = false;
        Vector2 brushCenter = Vector2.zero;

        if (Input.GetMouseButton(0))
        {
            Ray inputRay = mainCamera.ScreenPointToRay(Input.mousePosition);
            if (Physics.Raycast(inputRay, out RaycastHit hit))
            {
                brushActive = true;
                brushCenter = hit.textureCoord;
            }
        }

        brushMaterial.SetFloat(Uniforms.BrushActive, brushActive ? 1.0f : 0.0f);
        brushMaterial.SetVector(Uniforms.BrushCenter, brushCenter);
        brushMaterial.SetFloat(Uniforms.BrushStrength, brushStrength);
        brushMaterial.SetFloat(Uniforms.BrushRadius, (float)brushRadius / ((int)textureSize - 1));
        brushMaterial.SetFloat(Uniforms.RingRadius, ringRadius);
        brushMaterial.SetFloat(Uniforms.RingStrength, ringStrength);

        brushMaterial.SetFloat(Uniforms.DeltaTime, Time.deltaTime);
        brushMaterial.SetFloat(Uniforms.OscillationDamping, ostillationDamping);
        brushMaterial.SetFloat(Uniforms.OscillationFrequency, ostillationFrequency);

        Graphics.Blit(maskTexture, tempTexture, brushMaterial);
        (maskTexture, tempTexture) = (tempTexture, maskTexture);
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

    private void ClearRenderTexture(RenderTexture renderTexture)
    {
        RenderTexture current = RenderTexture.active;
        RenderTexture.active = renderTexture;
        GL.Clear(false, true, Color.clear);
        RenderTexture.active = current;
    }
}
