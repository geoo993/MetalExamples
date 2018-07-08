//
//  BlinnPhongShader.metal
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 08/07/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "Shader.h"

float radians(float degree) {
    return degree * 3.14159265359 / 180.0;
}

// This function implements the Blinn Phong shading model
// The code is based on the OpenGL 4.0 Shading Language Cookbook, pp. 67 - 68, with a few tweaks.
// Please see Chapter 2 of the book for a detailed discussion.
fragment half4 blinn_phong_shader_fragment(VertexOut vertexIn [[ stage_in ]],
                                           constant CameraInfo &camera [[ buffer(3) ]],
                                           constant MaterialInfo &material [[ buffer(4) ]],
                                           constant LightInfo &light [[ buffer(5) ]],
                                           texture2d<float> texture [[ texture(0) ]],
                                           sampler sampler2d [[ sampler(0) ]]) {


    // extract color from current fragmnet coordinates
    float4 textcolor = texture.sample(sampler2d, vertexIn.textureCoordinates);
    //float4 color = vertexIn.color;

    float3 p = vertexIn.fragPosition; // Eye coordinates are computed as part of the camera model
    float3 d = light.direction; // d is the spotlight direction (in eye coordinates)
    float3 s = normalize(light.position - p); // light direction is the normalised vector pointing to the light source
    //float3 v = normalize(-p);
    float3 v = normalize(camera.view - p);  // view direction is the normalised vector pointing to the camera
    float3 n = normalize(vertexIn.normal);   // normal, normalizing makes sure that the normal is a unit vector
    float3 h = normalize(s + v); // halfway vector between the vector pointing to the camera with the one pointing to light source
    float angle = acos(dot(-s, d));
    float cutoff = radians(clamp(light.cutOff, 0.0f, 90.0));
    float shininess = material.shininess;

    // ambient
    float3 ambientColor = light.ambient * material.ambient;

    if (angle < cutoff) {

        float spotFactor = pow(dot(-s, d), light.exponent);

        // diffuse
        float diffuseFactor = max(dot(s, n), 0.0);
        float3 diffuseColor = light.diffuse * material.diffuse * diffuseFactor;

        // specular
        float3 specularColor = float3(0.0);
        if (diffuseFactor > 0.0) {
            specularColor = light.specular * material.specular * pow(max(dot(h, n), 0.0), shininess);
        }

        textcolor = textcolor *  float4(ambientColor + spotFactor * (diffuseColor + specularColor), 1);
    } else  {
        textcolor = textcolor * float4(ambientColor, 1);
    }

    if (textcolor.a == 0.0)
        discard_fragment();

    return half4(textcolor.r, textcolor.g, textcolor.b, 1);
}
