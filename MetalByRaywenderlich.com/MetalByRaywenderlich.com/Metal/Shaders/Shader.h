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
    float4 color;
    float3 ambient;
    float3 diffuse;
    float3 specular;
    float shininess; //Shininess values typically range from 1 to 128. Higher values result in more focussed specular highlights.
    bool useTexture;
};

struct CameraInfo {
    float3 position;
    float3 view;
    float3 front;
};

// lighting attributes
struct LightInfo {
    float3 position;
    float3 color;
    float3 direction; // a direction the spotlight is pointing
    float3 ambient;
    float3 diffuse;
    float3 specular;
    float cutOff;  // a cutoff angle, used to define a cone around the direction vector
    float exponent; // an exponent, describing how light falls off from the centre

};

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
    float constants;
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
    PointLight point;
    float3 direction;
    float cutoff;
    float outerCutoff;
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


#endif /* Shader_h */
