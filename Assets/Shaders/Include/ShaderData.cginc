#ifndef SHADER_DATA_CGINC
#define SHADER_DATA_CGINC

struct VertexData
{
    float4 vertex : POSITION;
};

struct FragmentData
{
    float4 vertex : SV_POSITION;
    float3 normal : NORMAL;
};


#endif
