//
//  LightMixShader.metal
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 21/07/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

#include <metal_stdlib>
#include "Shader.h"
using namespace metal;


fragment float4 fragment_light_mix_shader(VertexOut vertexIn [[ stage_in ]],
                                          constant CameraInfo &camera [[ buffer(BufferIndexCameraInfo) ]],
                                          constant MaterialInfo &material [[ buffer(BufferIndexMaterialInfo) ]],
                                          constant PointLight *lights [[ buffer(BufferIndexPointLightInfo) ]],
                                          texture2d<float, access::sample> texture [[ texture(TextureIndexColor) ]],
                                          sampler sampler2d [[sampler(0)]])
{

    float3 textcolor = texture.sample(sampler2d, vertexIn.textureCoordinates).rgb;

    float3 N = normalize(vertexIn.normal);
    float3 V = normalize(camera.position - vertexIn.fragPosition);

    const int LightCount = 3;

    float3 finalColor(0, 0, 0);
    for (int i = 0; i < LightCount; ++i) {
        PointLight light = lights[i];
        float3 specularColor = material.color.xyz;
        float3 L = normalize(light.position - vertexIn.fragPosition.xyz);
        float3 diffuseIntensity = saturate(dot(N, L));
        float3 H = normalize(L + V);
        float specularBase = saturate(dot(N, H));
        float specularIntensity = powr(specularBase, material.shininess);
        float3 lightColor = light.base.color;
        finalColor += light.base.ambient * textcolor +
        diffuseIntensity * lightColor * textcolor +
        specularIntensity * lightColor * specularColor;
    }
    return float4(finalColor, 1);
}
