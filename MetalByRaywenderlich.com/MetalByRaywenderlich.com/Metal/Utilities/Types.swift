//
//  Types.swift
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 27/06/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//
import MetalKit
import simd

enum SliderType: String {
    case intensity
    case power
    case shininess
    case range
    case cutoff
    case outerCutoff
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
