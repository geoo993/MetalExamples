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

// This function implements the Phong shading model
// The code is based on the OpenGL 4.0 Shading Language Cookbook, pp. 67 - 68, with a few tweaks.
// Please see Chapter 2 of the book for a detailed discussion.
fragment half4 phong_shader_fragment(VertexOut vertexIn [[ stage_in ]],
                                     constant CameraInfo &camera [[ buffer(3) ]],
                                     constant MaterialInfo &material [[ buffer(4) ]],
                                     constant LightInfo &light [[ buffer(5) ]],
                                     texture2d<float> texture [[ texture(0) ]],
                                     sampler sampler2d [[ sampler(0) ]]) {

    // extract color from current fragmnet coordinates
    float4 textcolor = texture.sample(sampler2d, vertexIn.textureCoordinates);
    //float4 color = vertexIn.color;

    float3 p = vertexIn.fragPosition; // Eye coordinates are computed as part of the camera model
    float3 s = normalize(light.position - p); // light direction is the normalised vector pointing to the light source
    //float3 v = normalize(-p);
    float3 v = normalize(camera.view - p);  // view direction is the normalised vector pointing to the camera
    float3 n = normalize(vertexIn.normal);   // normal, normalizing makes sure that the normal is a unit vector
    float3 r = reflect(-s, n);   // reflection direction, is the normalised reflection vector
    float shininess = material.shininess;


    // Ambient
    float3 ambientColor = light.ambient * material.ambient;

    // diffuse
    // the dot function gives us the dot product between the normal and the light direction
    // and this gives us the angle so that we know how much lighting the fragment should receive.
    // its negative because when the normal is -1, the fragment should receive the most light, i.e.
    // diffuseFactor would be 1.
    float diffuseFactor = max(dot(s, n), 0.0);
    float3 diffuseColor = light.diffuse * material.diffuse * diffuseFactor;

    // specular
    float3 specularColor = float3(0.0);
    if (diffuseFactor > 0.0) {
        specularColor = light.specular * material.specular * pow(max(dot(r, v), 0.0), shininess);
    }

    textcolor = textcolor * float4(ambientColor + diffuseColor + specularColor, 1);

    if (textcolor.a == 0.0)
        discard_fragment();

    return half4(textcolor.r, textcolor.g, textcolor.b, 1);
}
