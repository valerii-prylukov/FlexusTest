#ifndef FRAGMENT_FUNCTION_CGINC
#define FRAGMENT_FUNCTION_CGINC

#include "ShaderData.cginc"
#include "Lighting.cginc"

samplerCUBE _CubeMap;
half4 _CubeMap_HDR;

float4 _BaseColor;
float4 _EdgeColor;
float4 _SpecularColor;
float4 _WaveColor;

float _FresnelPower;
float _Metallic;
float _Smoothness;
float _ReflectionStrength;
float _WaveColorStrength;

float GetFluidVelocity(float2 uv)
{
    return tex2D(_FluidMask, uv).g;
}

float3 GetCubeMapValue(float3 viewDir, float3 normal)
{
    float3 dir = reflect(-viewDir, normal);
    
    half4 encodedReflection = texCUBE(_CubeMap, dir);
    float3 reflection = DecodeHDR(encodedReflection, _CubeMap_HDR);

    return reflection;
}

float3 SpecularLighting(FragmentData i)
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
    
    float waveVelocity = GetFluidVelocity(i.uv);
    float waveMotion = saturate(abs(waveVelocity) * _WaveColorStrength);
    albedo = lerp(albedo, _WaveColor.rgb, waveMotion);
    
    float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

    float3 diffuseColor = albedo * lightColor * nl;

    float3 finalColor = diffuseColor + specularColor + ambient;

    float3 reflection = GetCubeMapValue(viewDir, normal);
    float reflectionFactor = _ReflectionStrength * lerp(0.35, 1.0, fresnel);

    finalColor = lerp(finalColor, reflection, reflectionFactor);

    return finalColor;
}

float3 MetallicLighting(FragmentData i)
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
    
    // Wave color
    float waveVelocity = GetFluidVelocity(i.uv);
    float waveMotion = saturate(abs(waveVelocity) * _WaveColorStrength);
    baseColor = lerp(baseColor, _WaveColor.rgb, waveMotion);

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
    float reflectionStrength = _ReflectionStrength * lerp(0.15, 1.0, _Metallic) * lerp(0.35, 1.0, fresnel);

    finalColor = lerp(finalColor, reflection, reflectionStrength);

    return finalColor;
}

fixed4 FragmentFunction(FragmentData fragmentData) : SV_Target
{
    float3 finalColor;

    #if defined(_LIGHTINGMODE_METALLIC)
        finalColor = MetallicLighting(fragmentData);
    #else
        finalColor = SpecularLighting(fragmentData);
    #endif
                
    return float4(finalColor, 1.0);
}

#endif
