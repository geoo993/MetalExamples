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

// --------- Vertex Data --------
// Structure defining the layout of each vertex.  Shared between C code filling in the vertex data
//   and Metal vertex shader consuming the vertices
// The Vertex struct defines the layout and memory of each vertex in a vertex array passes into a vertex_shader
typedef struct
{
    vector_float3 position;
    packed_float2 texture;
    vector_float4 color;
    vector_float3 normal;
} Vertex;

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
    BufferIndexConstants            = 8,
    BufferIndexToon                 = 9,
    BufferIndexFireBall             = 10,
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

// Sampler index values shared between shader and C code to ensure Metal shader texture indices
//   match indices of Metal API texture set calls
// this tells what index the sampler state is in
typedef NS_ENUM(NSInteger, SamplerIndex)
{
    SamplerIndexMain            = 0,
};


// --------- Materials --------
typedef struct
{
    vector_float4 color;
    float shininess; //Shininess values typically range from 1 to 128. Higher values result in more focussed specular highlights.
    bool useTexture;
} MaterialInfo;

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

// --------- Instance Uniform --------
typedef struct {
    Uniform uniform;
    MaterialInfo material;
} InstanceUniform;



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


// --------- Custom --------
typedef struct
{
    float time;
} Constants;

typedef struct
{
    float toonEdge;
} ToonConstants;

typedef struct
{
    float time;
    float frequency;
    float explosion;
} FireBallConstants;


struct ObjectData
{
    matrix_float4x4 LocalToWorld;
    vector_float4 color;
    vector_float4 pad0;
    vector_float4 pad01;
    vector_float4 pad02;
    matrix_float4x4 pad1;
    matrix_float4x4 pad2;

};

struct ShadowPass
{
    matrix_float4x4 ViewProjection;
    matrix_float4x4 pad1;
    matrix_float4x4 pad2;
    matrix_float4x4 pad3;
};

struct MainPass
{
    matrix_float4x4 ViewProjection;
    matrix_float4x4 ViewShadow0Projection;
    vector_float4    LightPosition;
    vector_float4    pad00;
    vector_float4    pad01;
    vector_float4    pad02;
    matrix_float4x4 pad1;
};


#endif /* ShaderTypes_h */
