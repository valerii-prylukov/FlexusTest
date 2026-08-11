Shader "FlexusTest/Fluid"
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

            #include "Include/VertexFunction.cginc"
            #include "Include/FragmentFunction.cginc"

            ENDCG
        }
    }
}
