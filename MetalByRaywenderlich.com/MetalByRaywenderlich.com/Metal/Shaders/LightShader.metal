//
//  LightShader.metal
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 03/07/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

#include <metal_stdlib>
#include "Main/Shader.h"

using namespace metal;


float radians(float degree) {
    return degree * 3.14159265359 / 180.0;
}

// This function implements the Phong shading model
// The code is based on the OpenGL 4.0 Shading Language Cookbook, pp. 67 - 68, with a few tweaks.
// Please see Chapter 2 of the book for a detailed discussion.
fragment half4 phong_fragment_shader(VertexOut vertexIn [[ stage_in ]],
                                     constant CameraInfo &camera [[ buffer(BufferIndexCameraInfo) ]],
                                     constant MaterialInfo &material [[ buffer(BufferIndexMaterialInfo) ]],
                                     constant DirectionalLight &light [[ buffer(BufferIndexDirectionalLightInfo) ]],
                                     texture2d<float> texture [[ texture(TextureIndexColor) ]],
                                     sampler sampler2d [[ sampler(0) ]]) {

    // extract color from current fragmnet coordinates
    float4 textcolor = texture.sample(sampler2d, vertexIn.textureCoordinates);
    //float4 color = vertexIn.color;

    float3 p = vertexIn.fragPosition; // Eye coordinates are computed as part of the camera model
    float3 s = normalize(-light.direction); // light direction is the normalised vector pointing to the light source
    //float3 v = normalize(-p);
    float3 view =  camera.position + camera.front;
    float3 v = normalize(view - p);  // view direction is the normalised vector pointing to the camera
    float3 n = normalize(vertexIn.normal);   // normal, normalizing makes sure that the normal is a unit vector
    float3 r = reflect(-s, n);   // reflection direction, is the normalised reflection vector
    float shininess = material.shininess;

    // diffuse
    // the dot function gives us the dot product between the normal and the light direction
    // and this gives us the angle so that we know how much lighting the fragment should receive.
    // its negative because when the normal is -1, the fragment should receive the most light, i.e.
    // diffuseFactor would be 1.
    float diffuseFactor = max(dot(s, n), 0.0f);
    float3 diffuseColor = light.base.diffuse * light.base.color * diffuseFactor;

    // Ambient
    float3 ambientColor = light.base.ambient * diffuseColor;

    // specular
    float3 specularColor = float3(0.0f,0,0);
    float specularFactor = pow(max(dot(v, r), 0.0f), shininess);

    if (diffuseFactor > 0.0f) {
        specularColor = light.base.specular * light.base.color * specularFactor;
    }

    if (material.useTexture) {
        textcolor = textcolor * material.color * float4(ambientColor + diffuseColor + specularColor, 1);

        if (textcolor.a == 0.0f)
            discard_fragment();

        return half4(textcolor.r, textcolor.g, textcolor.b, 1);
    } else {
        float4 finalColor = material.color * float4(ambientColor + diffuseColor + specularColor, 1);
        return half4(finalColor.r, finalColor.g, finalColor.b, 1);
    }

}


// This function implements the Blinn Phong shading model
// The code is based on the OpenGL 4.0 Shading Language Cookbook, pp. 67 - 68, with a few tweaks.
// Please see Chapter 2 of the book for a detailed discussion.
fragment half4 blinn_phong_fragment_shader(VertexOut vertexIn [[ stage_in ]],
                                           constant CameraInfo &camera [[ buffer(BufferIndexCameraInfo) ]],
                                           constant MaterialInfo &material [[ buffer(BufferIndexMaterialInfo) ]],
                                           constant SpotLight &light [[ buffer(BufferIndexSpotLightInfo) ]],
                                           texture2d<float> texture [[ texture(TextureIndexColor) ]],
                                           sampler sampler2d [[ sampler(0) ]]) {


    // extract color from current fragmnet coordinates
    float4 textcolor = texture.sample(sampler2d, vertexIn.textureCoordinates);
    //float4 color = vertexIn.color;

    float3 p = vertexIn.fragPosition; // Eye coordinates are computed as part of the camera model
    float3 d = light.direction; // d is the spotlight direction (in eye coordinates)
    float3 s = normalize(light.pointLight.position - p); // light direction is the normalised vector pointing to the light source
    //float3 v = normalize(-p);
    float3 view = camera.position + camera.front;
    float3 v = normalize(view - p);  // view direction is the normalised vector pointing to the camera
    float3 n = normalize(vertexIn.normal);   // normal, normalizing makes sure that the normal is a unit vector
    float3 h = normalize(s + v); // halfway vector between the vector pointing to the camera with the one pointing to light source
    float angle = acos(dot(-s, d));
    float cutoff = radians(clamp(light.cutOff, 0.0f, 90.0f));
    float shininess = material.shininess;
    float4 finalColor = float4(1.0f,1,1,1);

    // diffuse
    float diffuseFactor = max(dot(s, n), 0.0f);
    float3 diffuseColor = light.pointLight.base.diffuse * light.pointLight.base.color * diffuseFactor;

    // ambient
    float3 ambientColor = light.pointLight.base.ambient * light.pointLight.base.color * diffuseColor;

    if (angle < cutoff) {

        // specular
        float spotFactor = pow(dot(-s, d), light.pointLight.atten.exponent);
        float3 specularColor = float3(0.0f);
        if (diffuseFactor > 0.0f) {
            specularColor = light.pointLight.base.specular * light.pointLight.base.color * pow(max(dot(h, n), 0.0f), shininess);
        }

        finalColor = float4(ambientColor + spotFactor * (diffuseColor + specularColor), 1.0f);
    } else  {
        finalColor = float4(ambientColor, 1.0f);
    }

    if (material.useTexture == true) {
        textcolor = textcolor * material.color * finalColor;
        if (textcolor.a == 0.0f)
            discard_fragment();

        return half4(textcolor.r, textcolor.g, textcolor.b, 1);
    } else {
        finalColor = material.color * finalColor;
        return half4(finalColor.r, finalColor.g, finalColor.b, 1);
    }
}
