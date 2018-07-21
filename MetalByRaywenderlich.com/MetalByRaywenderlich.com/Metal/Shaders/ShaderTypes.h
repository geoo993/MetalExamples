//
//  ShaderTypes.h
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 21/07/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

#ifndef ShaderTypes_h
#define ShaderTypes_h

#ifdef __METAL_VERSION__
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#define NSInteger metal::int32_t
#else
#import <Foundation/Foundation.h>
#endif
#import <simd/simd.h>


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

#endif /* ShaderTypes_h */
