#ifndef VERTEX_FUNCTION_CGINC
#define VERTEX_FUNCTION_CGINC

#include "ShaderData.cginc"
#include "Noise/FractalNoise.cginc"

float _NoiseAmplitude;
float _NoiseSpeed;
float _Epsilon;
float _PlaneSize;

float GetHeight(float2 p)
{
    float y = _Time.y * _NoiseSpeed;
    float h = FractalPerlinNoise3D(float3(p.x, y, p.y));
    
    return h * _NoiseAmplitude;
}

float GetFluid(float2 uv)
{
    float fluid = tex2Dlod(_FluidMask, float4(uv, 0, 0)).r;

    return fluid;
}

float GetDisplacement(float2 p, float2 uv)
{
    return GetHeight(p) + GetFluid(uv);
}

float3 GetNormal(float2 p, float2 uv)
{
    float uvEpsilov = _Epsilon / _PlaneSize;
    
    float2 dpX = float2(_Epsilon, 0);
    float2 dpZ = float2(0, _Epsilon);
    
    float duvX = float2(uvEpsilov, 0);
    float duvZ = float2(0, uvEpsilov);
    
    float hx0 = GetHeight(p - dpX) + GetFluid(uv - duvX);
    float hx1 = GetHeight(p + dpX) + GetFluid(uv + duvX);
    
    float hz0 = GetHeight(p - dpZ) + GetFluid(uv - duvZ);
    float hz1 = GetHeight(p + dpZ) + GetFluid(uv + duvZ);
    
    float dhdx = (hx1 - hx0) / (2.0 * _Epsilon);
    float dhdz = (hz1 - hz0) / (2.0 * _Epsilon);
    
    float3 normal = normalize(float3(-dhdx, 1.0, -dhdz));
    
    return normal;
}

FragmentData VertexFunction(VertexData vertexData)
{
    float2 p = vertexData.vertex.xz;
    float2 uv = vertexData.uv;
    
    float displacement = GetDisplacement(p, uv);
    
    vertexData.vertex.y += displacement;
    
    float3 normal = GetNormal(p, uv);
    
    FragmentData fragmentData;
    fragmentData.vertex = UnityObjectToClipPos(vertexData.vertex);
    fragmentData.worldPos = mul(unity_ObjectToWorld, vertexData.vertex).xyz;
    fragmentData.worldNormal = UnityObjectToWorldNormal(normal);
    fragmentData.uv = uv;
    
    return fragmentData;
}

#endif
