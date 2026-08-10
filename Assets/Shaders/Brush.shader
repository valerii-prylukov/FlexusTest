Shader "FlexusTest/Brush"
{
    Properties
    {
        [HideInInspector]_MainTex("", 2D) = "black" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;

            float2 _BrushCenter;
            float _BrushRadius, _BrushStrength;

            fixed4 frag (v2f i) : SV_Target
            {
                float dist = distance(i.uv, _BrushCenter);

                float2 source = tex2D(_MainTex, i.uv).rg; 
                float col = 1.0 - step(_BrushRadius, dist);
                source = saturate(source + float2(col, 0));
                // float 
                // float depression = -smoothstep(_BrushRadius, 0.0, dist);
                // float ring = smoothstep(_BrushStrength, _BrushRadius * 1.4, dist) * (1.0 - smoothstep(_BrushRadius * 1.4, _BrushRadius * 1.8, dist))

                return float4(source, 0, 1);
            }
            ENDCG
        }
    }
}
