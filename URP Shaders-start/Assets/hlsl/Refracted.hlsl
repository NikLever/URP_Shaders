#ifndef REFRACTED_HLSL
#define REFRACTED_HLSL

void refracted_float(float3 ViewDir, float3 Normal, float IOR, out float3 result){
    result = refract(ViewDir, Normal, IOR);
}

#endif