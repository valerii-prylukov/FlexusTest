Shader "FlexusTest/Сhameleon"
{
    Properties
    {
        _BaseColor("Base Color", Color) = (0.1, 0.2, 0.8, 1.0)
        _EdgeColor("Edge Color", Color) = (0.8, 0.1, 0.6, 1.0)
        _FresnelPower("Fresnel Power", Range(0.1, 8.0)) = 2.0
        _SpecularColor("Specular Color", Color) = (0.5, 0.5, 0.5, 1.0)
        _Smoothness("Smoothness", Range(0.0, 1.0)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);

                return o;
            }

            float4 _BaseColor;
            float4 _EdgeColor;
            float4 _SpecularColor;
            float _FresnelPower;
            float _Smoothness;

            fixed4 frag (v2f i) : SV_Target
            {
                float3 normal = normalize(i.worldNormal);
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 halfVector = normalize(lightDir + viewDir);
                float nl = saturate(dot(lightDir, normal));
                float reflection = saturate(dot(halfVector, normal));
                float3 lightColor = _LightColor0.rgb;

                float specularPower = lerp(2.0, 256.0, _Smoothness * _Smoothness);
                float specular = pow(reflection, specularPower);
                specular *= nl;
                float3 specularColor = _SpecularColor.rgb * lightColor * specular;

                float fresnel = 1.0 - saturate(dot(normal, viewDir));
                fresnel = pow(fresnel, _FresnelPower);
                
                float3 albedo = lerp(_BaseColor.rgb, _EdgeColor.rgb, fresnel);

                float3 diffuseColor = albedo * lightColor * nl;

                return float4(diffuseColor + specularColor, 1);
            }
            ENDCG
        }
    }
}
