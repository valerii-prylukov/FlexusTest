Shader "FlexusTest/FluidDisplacement"
{
    Properties
    {
        _Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
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

            struct VertexData
            {
                float4 vertex   : POSITION;
                float2 uv       : TEXCOORD0;
            };

            struct FragmentData
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
            };

            float4 _Color;

            float _Epsilon;
            float _PlaneSize;

            uniform sampler2D _FluidMask;

            float GetDisplacement(float2 uv)
            {
                float fluid = tex2Dlod(_FluidMask, float4(uv, 0, 0)).r;

                return fluid;
            }

            float3 GetNormal(float2 uv)
            {
                float uvEpsilon = _Epsilon / _PlaneSize;

                float hx0 = GetDisplacement(uv - float2(uvEpsilon, 0));
                float hx1 = GetDisplacement(uv + float2(uvEpsilon, 0));
    
                float hz0 = GetDisplacement(uv - float2(0, uvEpsilon));
                float hz1 = GetDisplacement(uv + float2(0, uvEpsilon));
    
                float dhdx = (hx1 - hx0) / (2.0 * uvEpsilon);
                float dhdz = (hz1 - hz0) / (2.0 * uvEpsilon);
    
                float3 normal = normalize(float3(-dhdx, 1.0, -dhdz));
    
                return normal;
            }

            FragmentData VertexFunction(VertexData vertexData)
            {
                float2 uv = vertexData.uv;
    
                float displacement = GetDisplacement(uv);
    
                vertexData.vertex.y += displacement;
    
                float3 normal = GetNormal(uv);
    
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
