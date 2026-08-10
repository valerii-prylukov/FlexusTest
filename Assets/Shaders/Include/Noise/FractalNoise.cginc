#ifndef FRACTAL_NOISE_CGINC
#define FRACTAL_NOISE_CGINC

#define MAX_OCTAVES 8

int _Octaves;
float _Lacunarity;
float _Persistence;
float _BaseFrequency;

#include "PerlinNoise.cginc"

float FractalPerlinNoise3D(float3 samplePoint)
{
    float scale = _BaseFrequency;
	float  amplitude = 1.0, amplitudeSum = 0.0f;
	float  noiseSum = 0.0;
    for (int i = 0; i < MAX_OCTAVES; i++)
    {
        if (i >= _Octaves)
            break;
		
		float noise = PerlinNoise3D(samplePoint * scale) * amplitude;

		noiseSum += noise;

        scale *= _Lacunarity;
		amplitudeSum += amplitude;
        amplitude *= _Persistence;
    }

	noiseSum /= amplitudeSum;

	return noiseSum;
}

#endif	// FRACTAL_NOISE_CGINC
