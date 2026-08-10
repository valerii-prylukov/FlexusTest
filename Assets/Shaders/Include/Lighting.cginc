#ifndef LIGHTING_CGINC
#define LIGHTING_CGINC

#include "UnityLightingCommon.cginc"

float3 LambertLighting(float3 albedo, float3 normal)
{
    float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
    float3 lightColor = _LightColor0.rgb;
    normal = normalize(normal);
    float nl = saturate(dot(normal, lightDirection));

    float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo.xyz;

    float3 color = (albedo * lightColor * nl) + ambient;

    return color;
}

#endif
