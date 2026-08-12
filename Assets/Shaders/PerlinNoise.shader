Shader "FlexusTest/PerlinNoise"
{
    Properties
    {
        _Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _BaseFrequency("Noise Size (Base Frequency)", Range(0.001, 1.0)) = 0.2
        _Octaves("Octaves", Range(1, 8)) = 4
        _Lacunarity("Lacunarity", Range(1.0, 4.0)) = 2.0
        _Persistence("Persistence", Range(0.0, 1.0)) = 0.5
        _NoiseAmplitude("Noise Amplitude", float) = 1
        _NoiseSpeed("Noise Speed", float) = 1.0
        _Epsilon("Normal Epsilon", Range(0.001, 1.0)) = 1
        _PlaneSize("Plane Size", Range(1, 100)) = 100
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex VertexFunction
            #pragma fragment FragmentFunction

            #include "UnityCG.cginc"
            #include "Include/Lighting.cginc"
            #include "Include/Noise/FractalNoise.cginc"

            struct VertexData
            {
                float4 vertex   : POSITION;
                float2 uv       : TEXCOORD0;    
            };

            struct FragmentData
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
            };

            float4 _Color;
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

            float3 GetNormal(float2 p)
            {
                float uvEpsilov = _Epsilon / _PlaneSize;
    
                float2 dpX = float2(_Epsilon, 0);
                float2 dpZ = float2(0, _Epsilon);
    
                float hx0 = GetHeight(p - dpX);
                float hx1 = GetHeight(p + dpX);
    
                float hz0 = GetHeight(p - dpZ);
                float hz1 = GetHeight(p + dpZ);
    
                float dhdx = (hx1 - hx0) / (2.0 * _Epsilon);
                float dhdz = (hz1 - hz0) / (2.0 * _Epsilon);
    
                float3 normal = normalize(float3(-dhdx, 1.0, -dhdz));
    
                return normal;
            }

            FragmentData VertexFunction(VertexData vertexData)
            {
                float2 p = vertexData.vertex.xz;
                float2 uv = vertexData.uv;
    
                float displacement = GetHeight(p);
    
                vertexData.vertex.y += displacement;
    
                float3 normal = GetNormal(p);
    
                FragmentData fragmentData;
                fragmentData.vertex = UnityObjectToClipPos(vertexData.vertex);
                fragmentData.normal = UnityObjectToWorldNormal(normal);
    
                return fragmentData;
            }

            fixed4 FragmentFunction(FragmentData fragmentData) : SV_Target
            {
                float3 finalColor = LambertLighting(_Color.rgb, fragmentData.normal);
    
                return float4(finalColor, 1);
            }

            ENDCG
        }
    }
}
