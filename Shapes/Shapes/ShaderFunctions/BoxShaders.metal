/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Shader file with functions for rendering lit, textured geometry.
*/

#include <metal_stdlib>
#include "VertexShaderData.h"
using namespace metal;

constant half3 ambientLightIntensity(0.1, 0.1, 0.1);
constant half3 diffuseLightIntensity(0.9, 0.9, 0.9);
constant half3 lightDirection(-0.577, -0.577, -0.577);

struct VertexBufferIn {
    packed_float3 position;
    packed_float3 normal;
    packed_float2 texCoords;
};

struct VertexBufferOut {
    float4 position [[position]];
    float3 normal;
    float2 texCoords;
};

vertex VertexBufferOut vertex_transform(device VertexBufferIn *vertices [[buffer(0)]],
                                  constant Uniform &uniforms [[buffer(1)]],
                                  uint vertexId [[vertex_id]])
{
    float3 modelPosition = vertices[vertexId].position;
    float3 modelNormal = vertices[vertexId].normal;
    
    VertexBufferOut out;
    // Multiplying the model position by the model-view-projection matrix moves us into clip space
    out.position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * float4(modelPosition, 1);
    // Copy the vertex normal and texture coordinates
    out.normal = uniforms.normalMatrix * modelNormal;
    out.texCoords = vertices[vertexId].texCoords;

    return out;
}

fragment half4 fragment_lit_textured(VertexBufferOut fragmentIn [[stage_in]],
                                     texture2d<float, access::sample> tex2d [[texture(0)]],
                                     sampler sampler2d [[sampler(0)]])
{
    // Sample the texture to get the surface color at this point
    half3 surfaceColor = half3(tex2d.sample(sampler2d, fragmentIn.texCoords).rrr);
    // Re-normalize the interpolated surface normal
    half3 normal = normalize(half3(fragmentIn.normal));
    // Compute the ambient color contribution
    half3 color = ambientLightIntensity * surfaceColor;
    // Calculate the diffuse factor as the dot product of the normal and light direction
    float diffuseFactor = saturate(dot(normal, -lightDirection));
    // Add in the diffuse contribution from the light
    color += diffuseFactor * diffuseLightIntensity * surfaceColor;
    return half4(color, 1);
}
