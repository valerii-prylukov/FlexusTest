#ifndef SHADER_DATA_CGINC
#define SHADER_DATA_CGINC

struct VertexData
{
    float4 vertex   : POSITION;
    float2 uv       : TEXCOORD0;    
};

struct FragmentData
{
    float4 vertex : SV_POSITION;
    float3 worldPos : TEXCOORD0;
    float3 worldNormal : TEXCOORD1;
};


#endif
