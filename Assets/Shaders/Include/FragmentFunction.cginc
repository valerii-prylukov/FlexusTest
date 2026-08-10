#ifndef FRAGMENT_FUNCTION_CGINC
#define FRAGMENT_FUNCTION_CGINC

#include "ShaderData.cginc"
#include "Lighting.cginc"

float3 _Color;

fixed4 FragmentFunction(FragmentData fragmentData) : SV_Target
{
    float3 finalColor = LambertLighting(_Color.rgb, fragmentData.normal);
    
    //finalColor = normalize(fragmentData.normal);
    //finalColor = finalColor * 0.5 + 0.5;

    return float4(finalColor, 1);
}

#endif
