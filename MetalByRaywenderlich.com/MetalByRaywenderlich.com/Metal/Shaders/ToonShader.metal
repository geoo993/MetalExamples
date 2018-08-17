//
//  toonShader.metal
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 28/07/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

#include <metal_stdlib>
#include "Main/Shader.h"
using namespace metal;

/*
 Now write a function that sets one of three different colours of green (dark green, medium
 green, bright green) based on the intensity level. Recommended intensity thresholds are 0.5
 and 0.75 – that is, intensities less than 0.5 are coloured a dark green, intensities between 0.5
 and 0.75 are coloured medium green, and all other intensities are coloured bright green. You
 may wish to comment out the existing code that sets the output colour based on vColour.
 */
float3 toon(float3 color, float intensity) {
    if (intensity > 0.8f) {
        return color; //bright
    } else if (intensity > 0.65f) {
        return color * 0.65f; // medium bright
    } else if (intensity > 0.4f) {
        return color * 0.4f; // medium bright
    } else {
        return color * 0.1f; // dark
    }
}

fragment float4 fragment_toon_shader(VertexOut vertexIn [[ stage_in ]],
                                     constant ToonConstants &constants [[ buffer(BufferIndexToon) ]],
                                     constant CameraInfo &camera [[ buffer(BufferIndexCameraInfo) ]],
                                     constant MaterialInfo &material [[ buffer(BufferIndexMaterialInfo) ]],
                                     constant PointLight *lights [[buffer(BufferIndexPointLightInfo)]],
                                     texture2d<float, access::sample> texture [[ texture(TextureIndexColor) ]],
                                     sampler sampler2d [[sampler(SamplerIndexMain)]])
{

    float3 textcolor = texture.sample(sampler2d, vertexIn.textureCoordinates).rgb;
    float3 baseColor = material.useTexture ?  textcolor : material.color.xyz;
    float3 P = vertexIn.fragPosition.xyz;
    float3 N = normalize(vertexIn.normal);
    float3 V = normalize(camera.position - P);

    // toon
    float edgeMask = (dot(V, N) < constants.toonEdge) ? 0.0f : 1.0f;

    float3 finalColor(0, 0, 0);

    for (int i = 0; i < NUMBER_OF_POINT_LIGHTS; ++i) {
        PointLight light = lights[i];
        float3 S = normalize(light.position - P);
        float3 H = normalize(S + V);

        // This code implements the Blinn-Phong reflectance model (to be discussed in Lecture 6)
        // Code based on the OpenGL 4.0 Shading Language Cookbook, pages 92 - 93
        // Ambient
        float ambientCoefficient = light.base.ambient;
        float3 ambientColour = float3(ambientCoefficient, ambientCoefficient, ambientCoefficient);

        // Diffuse
        float fDiffuseIntensity = max(dot(S, N), 0.0f);
        float3 diffuseColour = light.base.diffuse * light.base.intensity * fDiffuseIntensity;

        // Specular
        float3 specularColour = float3(0.0, 0.0, 0.0);
        float fSpecularIntensity = 0.0;
        if (fDiffuseIntensity > 0.0) {
            fSpecularIntensity = pow(max(dot(H, N), 0.0f), material.shininess);
            specularColour = light.base.specular * fSpecularIntensity;
        }

        float fIntensity = fDiffuseIntensity + fSpecularIntensity;
        float3 lightsColor = (ambientColour + diffuseColour + specularColour) * baseColor * light.base.color;
        float3 toonColor = toon(lightsColor, fIntensity);

        finalColor += edgeMask * toonColor;
    }

    return float4(finalColor, 1);
}
