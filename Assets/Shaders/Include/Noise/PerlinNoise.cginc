// Функции генерирования шума Перлина. Возвращает значение в диапазоне [-1; +1]
// Source from https://www.shadertoy.com/view/4sc3z2

#ifndef PERLIN_NOISE_CGINC
#define PERLIN_NOISE_CGINC

#include "Hash.cginc"

float PerlinNoise3D(float3 p)
{
	float3 pi = floor(p);
	float3 pf = p - pi;

	float3 w = pf * pf * (3.0 - 2.0 * pf);

	float noise =	lerp(
		         lerp(
			          lerp(dot(pf - float3(0, 0, 0), Hash33(pi + float3(0, 0, 0))),
				           dot(pf - float3(1, 0, 0), Hash33(pi + float3(1, 0, 0))),
				           w.x),
			          lerp(dot(pf - float3(0, 0, 1), Hash33(pi + float3(0, 0, 1))),
				           dot(pf - float3(1, 0, 1), Hash33(pi + float3(1, 0, 1))),
				           w.x),
			          w.z),
		   lerp(
			    lerp(dot(pf - float3(0, 1, 0), Hash33(pi + float3(0, 1, 0))),
				     dot(pf - float3(1, 1, 0), Hash33(pi + float3(1, 1, 0))),
				     w.x),
			    lerp(dot(pf - float3(0, 1, 1), Hash33(pi + float3(0, 1, 1))),
				     dot(pf - float3(1, 1, 1), Hash33(pi + float3(1, 1, 1))),
				     w.x),
			    w.z),
		   w.y);

	return noise;
}

#endif // PERLIN_NOISE_CGINC
