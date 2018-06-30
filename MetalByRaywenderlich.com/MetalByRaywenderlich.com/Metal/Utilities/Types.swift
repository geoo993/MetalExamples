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
    var color: float4
    var texture: float2
}

// each model will declare a model constant struct and this matrix will be sent to the GPU
// to transform all the vertices of the model into camera space.
// An identiy matrix is sort of a neutral marix, multiply an identity matrix and you get the
// same matrix back
struct ModelConstants {
    var modelMatrix = matrix_identity_float4x4
    var viewMatrix = matrix_identity_float4x4
}
