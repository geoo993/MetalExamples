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
}

// Structure holding material information:  its ambient, diffuse, and specular colours, and shininess
struct MaterialInfo {
    var color = float4(1)
    var ambient = float3(0)
    var diffuse = float3(0)
    var specular = float3(0)
    var shininess: Float = 1.0
    var useTexture: Bool = false
}

struct LightInfo {
    var position = float3(0)
    var color = float3(1)
    var direction = float3(0)
    var ambient = float3(0)
    var diffuse = float3(0)
    var specular = float3(0)
    var cutOff: Float = 0.0
    var exponent: Float = 0.0
}

struct CameraInfo {
    var position = float3(0)
    var view = float3(0)
    var front = float3(0)
};

struct BaseLight
{
    var color = float3(1)
    var intensity: Float = 0
    var ambient = float3(0)
    var diffuse = float3(0)
    var specular = float3(0)
};

struct Attenuation
{
    var constants: Float = 1.0
    var linear: Float = 1.0
    var exponent: Float = 1.0
};

struct DirectionalLight
{
    var base: BaseLight = BaseLight()
    var direction = float3(0)
};

struct PointLight
{
    var base: BaseLight = BaseLight()
    var atten: Attenuation = Attenuation()
    var position = float3(0)
    var range: Float = 0
};

struct SpotLight
{
    var point: PointLight = PointLight()
    var direction = float3(0)
    var cutoff: Float = 0
    var outerCutoff: Float = 0
};
