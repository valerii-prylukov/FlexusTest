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
            float _RingRadius, _RingStrength;
            float _BrushActive;
            float _DeltaTime;
            float _OscillationDamping, _OscillationFrequency;

            fixed4 frag (v2f i) : SV_Target
            {
                float2 state = tex2D(_MainTex, i.uv).rg; 

                float height = state.r;
                float velocity = state.g;

                // Oscillation
                float omega = _OscillationFrequency;

                velocity += -height * omega * omega * _DeltaTime;
                velocity *= exp(-_OscillationDamping * _DeltaTime);

                height += velocity * _DeltaTime;

                // Brush
                if(_BrushActive > 0.5)
                {
                    float dist = distance(i.uv, _BrushCenter);

                    float inner = 1.0 - smoothstep(0.0, _BrushRadius, dist);

                    float ringStart = _BrushRadius;
                    float ringEnd = _BrushRadius * _RingRadius;
                    float ringPeak = (ringStart + ringEnd) * 0.5;

                    float ringIn = smoothstep(ringStart, ringPeak, dist);
                    float ringOut = 1.0 - smoothstep(ringPeak, ringEnd, dist);

                    float ring = ringIn * ringOut;

                    float brush = -inner * _BrushStrength + ring * _BrushStrength * _RingStrength;

                    height += brush;
                }

                return float4(height, velocity, 0, 1);
            }
            ENDCG
        }
    }
}
