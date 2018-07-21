//
//  Types.swift
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 27/06/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//
import MetalKit
import simd

public protocol HasMetalKit {
    static var view: MTKView { get }
}

enum SliderType: String {
    case intensity
    case power
    case shininess
}

enum VertexFunction: String {
    case vertex_shader
    case vertex_instance_shader
}

enum FragmentFunction: String {
    case fragment_shader
    case fragment_color
    case fragment_normal
    case fragment_texture_shader
    case fragment_textured_mask_shader
    case fragment_light_mix_shader
    case phong_fragment_shader
    case blinn_phong_fragment_shader
    case lighting_fragment_shader
}

struct Vertex {
    var position: float3
    var texture: float2
    var color: float4
    var normal: float3
}

struct InstanceInfo {
    var uniform = Uniform()
    var material = MaterialInfo()
}

// Structure holding material information:  its ambient, diffuse, and specular colours, and shininess
struct MaterialInfo {
    var color = float4(1,1,1,1)
    var shininess: Float = 1.0
    var useTexture: Bool = false
}

struct CameraInfo {
    var position = float3(0)
    var front = float3(0)
}

struct BaseLight
{
    var color = float3(1,1,1)
    var intensity: Float = 0
    var power: Float = 0
    var ambient = float3(1)
    var diffuse = float3(1)
    var specular = float3(1)
}

struct Attenuation
{
    var continual: Float = 0.0
    var linear: Float = 0.0
    var exponent: Float = 0.0
}

struct DirectionalLight
{
    var base: BaseLight = BaseLight()
    var direction = float3(0)
}

struct PointLight
{
    var base: BaseLight = BaseLight()
    var atten: Attenuation = Attenuation()
    var position = float3(0)
    var range: Float = 0
}

struct SpotLight
{
    var pointLight: PointLight = PointLight()
    var direction = float3(0)
    var cutOff: Float = 0
    var outerCutOff: Float = 0
}
