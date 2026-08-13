Shader "FlexusTest/Fluid"
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

        _BaseFrequency("Noise Size (Base Frequency)", Range(0.001, 1.0)) = 0.2
        _Octaves("Octaves", Range(1, 8)) = 4
        _Lacunarity("Lacunarity", Range(1.0, 4.0)) = 2.0
        _Persistence("Persistence", Range(0.0, 1.0)) = 0.5
        _NoiseAmplitude("Noise Amplitude", float) = 1
        _NoiseSpeed("Noise Speed", float) = 1.0
        _Epsilon("Normal Epsilon", Range(0.001, 1.0)) = 1
        _PlaneSize("Plane Size", Range(1, 100)) = 100
    
        _WaveColor("Wave Color", Color) = (0.2, 0.8, 1.0, 1)
        _WaveColorStrength("Wave Color Strength", Range(0.0, 5.0)) = 1.0
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

            #pragma shader_feature_local _LIGHTINGMODE_SPECULAR _LIGHTINGMODE_METALLIC

            #include "UnityCG.cginc"

            #include "Include/VertexFunction.cginc"
            #include "Include/FragmentFunction.cginc"

            ENDCG
        }
    }
}
