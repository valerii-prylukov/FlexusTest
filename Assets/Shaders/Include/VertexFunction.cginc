#ifndef VERTEX_FUNCTION_CGINC
#define VERTEX_FUNCTION_CGINC

#include "ShaderData.cginc"
#include "Noise/FractalNoise.cginc"

float _NoiseAmplitude;
float _NoiseSpeed;
float _Epsilon;

float GetHeight(float2 p)
{
    p = p + _Time.y * _NoiseSpeed;
    float h = FractalPerlinNoise3D(float3(p.x, 0, p.y));
    
    return h * _NoiseAmplitude;
}

FragmentData VertexFunction(VertexData vertexData)
{
    //_Epsilon = 1.0;
    
    float2 p = vertexData.vertex.xz;
    
    float h = GetHeight(p);
    vertexData.vertex.y += h;
    
    float hx0 = GetHeight(p - float2(_Epsilon, 0));
    float hx1 = GetHeight(p + float2(_Epsilon, 0));
    
    float hz0 = GetHeight(p - float2(0, _Epsilon));
    float hz1 = GetHeight(p + float2(0, _Epsilon));
    
    float dhdx = (hx1 - hx0) / (2.0 * _Epsilon);
    float dhdz = (hz1 - hz0) / (2.0 * _Epsilon);
    
    float3 normal = normalize(float3(-dhdx, 1.0, -dhdz));
    
    FragmentData fragmentData;
    fragmentData.vertex = UnityObjectToClipPos(vertexData.vertex);
    fragmentData.normal = UnityObjectToWorldNormal(normal);
    
    return fragmentData;
}

#endif
