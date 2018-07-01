//
//  Types.swift
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 27/06/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import simd

struct Constants {
    var animateBy: Float
    var useTexture: Bool
}


struct Vertex {
    var position: float3
    var texture: float2
    var color: float4
    var normal: float3
}

// each model will declare a model constant struct and this matrix will be sent to the GPU
// to transform all the vertices of the model into camera space.
// An identiy matrix is sort of a neutral marix, multiply an identity matrix and you get the
// same matrix back
struct Matrices {
    var projectionMatrix = matrix_identity_float4x4
    var modelMatrix = matrix_identity_float4x4
    var viewMatrix = matrix_identity_float4x4
    var normalMatrix = matrix_identity_float4x4
    var materialColor = float4(1)
}

struct Materials
{
    var materialColor = float4(1)
//    sampler2D ambientMap;  // ambient map
//    sampler2D normalMap;   // normal map
//    sampler2D diffuseMap;  // diffuse map
//    sampler2D specularMap; // specular map
//    sampler2D heightMap;   // heihgt Map, also known as depth map
//    float shininess; // object material shininess
}
