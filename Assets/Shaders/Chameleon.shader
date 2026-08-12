Shader "FlexusTest/Сhameleon"
{
    Properties
    {
        [KeywordEnum(Specular, Metallic)] _LightingMode("Lighting Mode", Float) = 0
        _BaseColor("Base Color", Color) = (0.1, 0.2, 0.8, 1.0)
        _EdgeColor("Edge Color", Color) = (0.8, 0.1, 0.6, 1.0)
        _FresnelPower("Fresnel Power", Range(0.1, 8.0)) = 2.0
        _Metallic("Metallic", Range(0.0, 1.0)) = 0.0
        _SpecularColor("Specular Color", Color) = (0.5, 0.5, 0.5, 1.0)
        _Smoothness("Smoothness", Range(0.0, 1.0)) = 0.5
        _CubeMap("Cube Map", Cube) = "black" {}
        _ReflectionStrength("Reflection Strength", Range(0.0, 1.0)) = 0.5
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

            #pragma shader_feature_local _LIGHTINGMODE_SPECULAR _LIGHTINGMODE_METALLIC

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

            samplerCUBE _CubeMap;
            float4 _BaseColor;
            float4 _EdgeColor;
            float4 _SpecularColor;
            float _FresnelPower;
            float _Metallic;
            float _Smoothness;
            float _ReflectionStrength;

            float3 GetCubeMapValue(float3 viewDir, float3 normal)
            {
                float3 dir = reflect(-viewDir, normal);
                float3 reflection = texCUBE(_CubeMap, dir).rgb;

                return reflection;
            }

            float3 SpecularLighting(v2f i)
            {
                float3 normal = normalize(i.worldNormal);
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                float3 halfVector = normalize(lightDir + viewDir);

                float nl = saturate(dot(lightDir, normal));
                float nh = saturate(dot(halfVector, normal));

                float3 lightColor = _LightColor0.rgb;

                float specularPower = lerp(2.0, 256.0, _Smoothness * _Smoothness);
                float specular = pow(nh, specularPower);
                specular *= nl;
                float3 specularColor = _SpecularColor.rgb * lightColor * specular;

                float fresnel = 1.0 - saturate(dot(normal, viewDir));
                fresnel = pow(fresnel, _FresnelPower);
                
                float3 albedo = lerp(_BaseColor.rgb, _EdgeColor.rgb, fresnel);
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                float3 diffuseColor = albedo * lightColor * nl;

                float3 finalColor = diffuseColor + specularColor + ambient;

                float3 reflection = GetCubeMapValue(viewDir, normal);
                float reflectionFactor = _ReflectionStrength * lerp(0.35, 1.0, fresnel);

                finalColor = lerp(finalColor, reflection, reflectionFactor);

                return finalColor;
            }

            float3 MetallicLighting(v2f i)
            {
                float3 normal = normalize(i.worldNormal);
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                float3 halfVector = normalize(lightDir + viewDir);

                float nl = saturate(dot(lightDir, normal));
                float nh = saturate(dot(halfVector, normal));

                float3 lightColor = _LightColor0.rgb;

                // Fresnel chameleon color
                float fresnel = 1.0 - saturate(dot(normal, viewDir));
                fresnel = pow(fresnel, _FresnelPower);

                float3 baseColor = lerp(_BaseColor.rgb, _EdgeColor.rgb, fresnel);

                // Diffuse contribution decreases with metallic
                float3 diffuseAlbedo = baseColor * (1.0 - _Metallic);
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * diffuseAlbedo;
                float3 diffuse = diffuseAlbedo * lightColor * nl;

                // Specular
                float specularPower = lerp(2.0, 256.0, _Smoothness * _Smoothness);
                float specular = pow(nh, specularPower);
                specular *= nl;
                // Dielectric -> SpecularColor
                // Metal      -> BaseColor
                float3 specularColor = lerp(_SpecularColor.rgb, baseColor, _Metallic);

                specularColor = specularColor * lightColor * specular;

                float3 finalColor = diffuse + specularColor + ambient;

                float3 reflection = GetCubeMapValue(viewDir, normal);
                float reflectionStrength = _ReflectionStrength *  lerp(0.15, 1.0, _Metallic) * lerp(0.35, 1.0, fresnel);

                finalColor = lerp(finalColor, reflection, reflectionStrength);

                return finalColor;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 finalColor;

                #if defined(_LIGHTINGMODE_METALLIC)
                    finalColor = MetallicLighting(i);
                #else
                    finalColor = SpecularLighting(i);
                #endif
                
                return float4(finalColor, 1.0);
            }
            ENDCG
        }
    }
}
