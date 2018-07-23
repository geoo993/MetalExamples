//
//  Shader.h
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 03/07/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

#ifndef Shader_h
#define Shader_h

#include "ShaderTypes.h"
using namespace metal;

// --------- Attributes --------
struct MaterialInfo
{
    float4 color;
    float shininess; //Shininess values typically range from 1 to 128. Higher values result in more focussed specular highlights.
    bool useTexture;
};

struct InstanceInfo {
    Uniform uniform;
    MaterialInfo material;
};

struct CameraInfo {
    float3 position;
    float3 front;
};

// lighting attributes
struct BaseLight
{
    float3 color;
    float intensity;
    float3 ambient;
    float3 diffuse;
    float3 specular;
};

struct Attenuation
{
    float continual;
    float linear;
    float exponent;
};

struct DirectionalLight
{
    BaseLight base;
    float3 direction;
};

struct PointLight
{
    BaseLight base;
    Attenuation atten;
    float3 position;
    float range;
};

struct SpotLight
{
    PointLight pointLight;
    float3 direction;
    float cutOff;
    float outerCutOff;
};

// input information to the shader
// note that each item in the struct has been given an attribute number
struct VertexIn {
    float3 position [[ attribute(VertexAttributePosition) ]];
    float2 textureCoordinates [[ attribute(VertexAttributeTexcoord) ]];
    float4 color [[ attribute(VertexAttributeColor) ]];
    float3 normal [[ attribute(VertexAttributeNormal) ]];
};

// this tells the rasterisor, which of these data items contains, contains the vertex position or color value
struct VertexOut {
    float4 position [[ position ]];
    float2 textureCoordinates;
    float4 color;
    float3 normal;
    float3 fragPosition;
    float4 eyePosition;
    float4 eyeNormal;
};

float radians(float degree);


#endif /* Shader_h */
