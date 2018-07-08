//
//  LightShader.metal
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 03/07/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "Shader.h"

fragment half4 light_shader_fragment(VertexOut vertexIn [[ stage_in ]],
                                     constant LightInfo &light [[ buffer(3) ]],
                                     constant MaterialInfo &material [[ buffer(4) ]],
                                     texture2d<float> texture [[ texture(0) ]],
                                     sampler sampler2d [[ sampler(0) ]]) {

    // extract color from current fragmnet coordinates
    float4 textcolor = texture.sample(sampler2d, vertexIn.textureCoordinates);

    // Ambient
    float3 ambientColor = light.color * light.ambient;

    // Diffuse lighting
    float3 normal = normalize(vertexIn.normal);
    float3 viewDirection = normalize(light.position - vertexIn.eyePosition); //lightDirection
    float3 lightDirection = normalize(-light.direction);
    //float diffuseFactor = max( dot( normal, lightDirection ), 0.0f);
    float diffuseFactor = saturate(-dot(normal, lightDirection));
    float3 diffuseColor = light.color * light.diffuse * diffuseFactor;

    // Specular lighting
    float3 reflectDirection = reflect(-lightDirection, normal);
    float specularFactor = pow( max( dot( viewDirection, reflectDirection ), 0.0f), material.shininess);

    float3 specularColor = light.color * light.specular * specularFactor;

    textcolor = textcolor * float4(ambientColor + diffuseColor + specularColor, 1);

    if (textcolor.a == 0.0)
    discard_fragment();

    return half4(textcolor.r, textcolor.g, textcolor.b, 1);
}
