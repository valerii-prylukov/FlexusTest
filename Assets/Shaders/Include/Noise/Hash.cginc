#ifndef _HASH_CGINC
#define _HASH_CGINC

// Grab from https://www.shadertoy.com/view/4djSRW
#define MOD3 float3(0.1031, 0.11369, 0.13787)
// MOD3 можно варьировать
#define MOD2 float2(0.1031, 0.13787)

//======================================================================================================
float Hash31(float3 p3)
{
	p3 = frac(p3 * MOD3);
	p3 += dot(p3, p3.yzx + 19.19);
	// вариант если пойдут артефакты
	// p3 += dot(p3, p3.yzx + 33.33
	return frac((p3.x + p3.y) * p3.z) * 2.0 - 1.0;
}

// более дешевый вариант, но хуже распределение и больше артефактов
/*
float Hash31(float3 p3)
{
	p3 = frac(p3 * 0.3183099 + 0.1);
	p3 *= 17.0;
	return frac(p3.xxy * p.yzz * p.zyx) * 2.0 - 1.0;
}
*/

float Hash21(float2 p)
{
	p = 50.0 * frac(p * 0.3183099 + float2(0.71, 0.113));
	return -1.0 + 2.0 * frac(p.x * p.y * (p.x + p.y));
}

float3 Hash33(float3 p3)
{
	p3 = frac(p3 * MOD3);
	p3 += dot(p3, p3.yxz + 19.19);
	return -1.0 + 2.0 * frac(float3((p3.x + p3.y) * p3.z, (p3.x + p3.z) * p3.y, (p3.y + p3.z) * p3.x));
}


#endif // _HASH_CGINC
