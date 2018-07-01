//
//  Types.swift
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 27/06/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import simd

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
struct Uniform {
    var projectionMatrix = matrix_identity_float4x4
    var modelMatrix = matrix_identity_float4x4
    var viewMatrix = matrix_identity_float4x4
    var normalMatrix = matrix_identity_float3x3
    var materialColor = float4(1)
    var specularIntensity: Float = 1
    var shininess: Float = 1
    var useTexture: Bool = false
}

struct Light {
    var position = float3(0)
    var color = float3(1)
    var direction = float3(0)
    var ambientIntensity: Float = 1.0
    var diffuseIntensity: Float = 1.0
}

