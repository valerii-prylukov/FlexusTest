Shader "FlexusTest/Сhameleon"
{
    Properties
    {
        _BaseColor("Base Color", Color) = (0.1, 0.2, 0.8, 1.0)
        _EdgeColor("Edge Color", Color) = (0.8, 0.1, 0.6, 1.0)
        _FresnelPower("Fresnel Power", Range(0.1, 8.0)) = 2.0
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

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORDS1;
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
            float _FresnelPower;

            fixed4 frag (v2f i) : SV_Target
            {
                float3 normal = normalize(i.worldNormal);
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);

                float fresnel = 1.0 - saturate(dot(normal, viewDir));
                fresnel = pow(fresnel, _FresnelPower);
                
                float3 color = lerp(_BaseColor.rgb, _EdgeColor.rgb, fresnel);

                return float4(color, 1);
            }
            ENDCG
        }
    }
}
