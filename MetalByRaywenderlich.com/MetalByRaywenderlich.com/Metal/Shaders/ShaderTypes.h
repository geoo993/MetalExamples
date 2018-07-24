//
//  ShaderTypes.h
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 21/07/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//
// https://stackoverflow.com/questions/38820120/is-it-possible-to-use-metal-data-types-in-objective-c

#ifndef ShaderTypes_h
#define ShaderTypes_h

#ifdef __METAL_VERSION__
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#define NSInteger metal::int32_t
#else
#import <Foundation/Foundation.h>
#endif
#import <simd/simd.h>

// --------- Buffers and Indexes --------
typedef NS_ENUM(NSInteger, BufferIndex)
{
    BufferIndexMeshPositions        = 0,
    BufferIndexUniforms             = 1,
    BufferIndexInstances            = 2,
    BufferIndexCameraInfo           = 3,
    BufferIndexMaterialInfo         = 4,
    BufferIndexDirectionalLightInfo = 5,
    BufferIndexPointLightInfo       = 6,
    BufferIndexSpotLightInfo        = 7,
    BufferIndexLights               = 8,
};

typedef NS_ENUM(NSInteger, VertexAttribute)
{
    VertexAttributePosition = 0,
    VertexAttributeTexcoord = 1,
    VertexAttributeColor    = 2,
    VertexAttributeNormal   = 3,
};

typedef NS_ENUM(NSInteger, TextureIndex)
{
    TextureIndexColor           = 0,
    TextureIndexMask            = 1,
    TextureIndexNormalMap       = 2,
    TextureIndexDiffuseMap      = 3,
    TextureIndexSpecularMap     = 4,
};



// --------- Matrix Uniform --------
// each model will declare a model constant struct and this matrix will be sent to the GPU
// to transform all the vertices of the model into camera space.
// An identiy matrix is sort of a neutral marix, multiply an identity matrix and you get the
// same matrix back
// uniform matrices and materials 3D attributes
typedef struct
{
    // Matrices attributes
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float3x3 normalMatrix;
} Uniform;

// --------- Attributes --------
typedef struct
{
    vector_float4 color;
    float shininess; //Shininess values typically range from 1 to 128. Higher values result in more focussed specular highlights.
    bool useTexture;
} MaterialInfo;

typedef struct {
    Uniform uniform;
    MaterialInfo material;
} InstanceInfo;


// --------- Camera --------
typedef struct {
    vector_float3 position;
    vector_float3 front;
} CameraInfo;

// --------- Light --------
#define NUMBER_OF_DIRECTIONAL_LIGHTS 1
#define NUMBER_OF_POINT_LIGHTS 5
#define NUMBER_OF_SPOT_LIGHTS 1

typedef struct
{
    vector_float3 color;
    float intensity;
    float ambient;
    float diffuse;
    float specular;
} BaseLight;

typedef struct
{
    float continual;
    float linear;
    float exponent;
} Attenuation;

typedef struct
{
    BaseLight base;
    vector_float3 direction;
} DirectionalLight;

typedef struct
{
    BaseLight base;
    Attenuation atten;
    vector_float3 position;
} PointLight;

typedef struct
{
    PointLight pointLight;
    vector_float3 direction;
    float cutOff;
    float outerCutOff;
} SpotLight;

typedef struct {
    DirectionalLight dirLights[NUMBER_OF_DIRECTIONAL_LIGHTS];
    PointLight pointLights[NUMBER_OF_POINT_LIGHTS];
    SpotLight spotLights[NUMBER_OF_SPOT_LIGHTS];
} LightsUniforms;

float radians(float degree);

#endif /* ShaderTypes_h */
