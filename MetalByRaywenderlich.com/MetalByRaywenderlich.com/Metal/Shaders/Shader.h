//
//  Shader.h
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 03/07/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

#ifndef Shader_h
#define Shader_h

// --------- Attributes --------
// uniform matrices and materials 3D attributes
struct Uniform {

    // Martices attributes
    float4x4 projectionMatrix;
    float4x4 modelMatrix;
    float4x4 viewMatrix;
    float3x3 normalMatrix;
};


struct MaterialInfo
{
    //sampler normalMap;
    //sampler diffuseMap;
    //sampler specularMap;

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
    float power;
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
    float3 position [[ attribute(0) ]];
    float2 textureCoordinates [[ attribute(1) ]];
    float4 color [[ attribute(2) ]];
    float3 normal [[ attribute(3) ]];
};

// this tells the rasterisor, which of these data items contains, contains the vertex position or color value
struct VertexOut {
    float4 position [[ position ]];
    float2 textureCoordinates;
    float4 color;
    float3 normal;
    float3 fragPosition;
};

float radians(float degree);


#endif /* Shader_h */
