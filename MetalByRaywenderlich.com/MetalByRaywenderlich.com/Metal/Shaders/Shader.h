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

    // Materials attributes
    float4 materialColor;
    float shininess;

    // texture
    float useTexture;

};


struct Material
{
    float shininess;

    float3 ambient;
    float3 diffuse;
    float3 specular;
};

// lighting attributes
struct Light {
    float3 position;
    float3 color;
    float3 direction;
    float ambientIntensity;
    float diffuseIntensity;
    float specularIntensity;
};

struct DirectionalLight
{
    float3 position;
    float3 color;
    float3 direction;

    float3 ambient;
    float3 diffuse;
    float3 specular;
};

struct PointLight
{
    float3 position;
    float3 color;

    float3 ambient;
    float3 diffuse;
    float3 specular;

    float constantic;
    float linearic;
    float quadratic;
};


struct SpotLight
{
    float3 position;
    float3 color;
    float3 direction;
    float intensity;

    float3 ambient;
    float3 diffuse;
    float3 specular;

    float constantic;
    float linearic;
    float quadratic;

    float cutOff;
    float outerCutOff;

};

// input information to the shader
// note that each item in the struct has been given an attribute number
struct VertexIn {
    float4 position [[ attribute(0) ]];
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
    float4 materialColor;
    float shininess;
    bool useTexture;
    float3 eyePosition;
};


#endif /* Shader_h */
