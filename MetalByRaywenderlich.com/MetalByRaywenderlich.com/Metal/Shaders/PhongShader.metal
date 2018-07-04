//
//  PhongShader.metal
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 03/07/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "Shader.h"

fragment half4 phong_shader_fragment(VertexOut vertexIn [[ stage_in ]],
                                     constant Light &light [[ buffer(3) ]],
                                     texture2d<float> texture [[ texture(0) ]],
                                     sampler sampler2d [[ sampler(0) ]]) {

    // extract color from current fragmnet coordinates
    float4 textcolor = texture.sample(sampler2d, vertexIn.textureCoordinates);
    float4 color = vertexIn.color;

    // Ambient
    float3 ambientColor = light.color * light.ambientIntensity;

    // Diffuse lighting
    // normalize makes sure that the normal is a unit vector
    float3 normal = normalize(vertexIn.normal);

    // the dot function gives us the dot product between the normal and the light direction
    // and this gives us the angle so that we know how much lighting the fragment should receive.
    // its negative becuase when the normal is -1, the fragment should receive the most light, i.e.
    // diffuseFactor would be 1.
    // the saturate function clamps the returned value between 0 and 1
    float diffuseFactor = saturate(-dot(normal, light.direction)); // change

    // we can now calculate the diffuse color
    float3 diffuseColor = light.color * light.diffuseIntensity * diffuseFactor;

    // Specular
    float3 eye = normalize(vertexIn.eyePosition);

    float3 reflection = reflect(light.direction, normal); //change

    float specularFactor = pow(saturate(-dot(reflection, eye)), vertexIn.shininess);

    float3 specularColor = light.color * light.specularIntensity * specularFactor;

    textcolor = textcolor * float4(ambientColor + diffuseColor + specularColor, 1);

    if (textcolor.a == 0.0)
        discard_fragment();

    return half4(textcolor.r, textcolor.g, textcolor.b, 1);
}
