//
//  Shader.metal
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 26/06/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

#include <metal_stdlib>
#include "VertexShaderData.h"
using namespace metal;

// --------- Fragment Shader --------

// the fragment function the one that returns the color of each fragment is the one that is easier that the vertex fucntion.
// it is a fragment function so we prefix it with fragment and returning a half4,
// which is a smaller float4 and calling the function fragment_shader
fragment half4 fragment_shader(VertexOut vertexIn [[ stage_in ]]) {
    return half4(vertexIn.color);
}

// notice the special qualifier 'stage_in', all the vertex information within this in-struct has been interpolated,
// during this rasterisation process, in other words it is data that the rasterisor has generated per fragment,
// rather than one constant value for all fragments.
// fragment color are (r, g, b, a) per pixel, these rbg values are between 0 and 1
fragment half4 fragment_color(VertexOut vertexIn [[ stage_in ]],
                               constant MaterialInfo &material [[ buffer(BufferIndexMaterialInfo) ]]) {
    return half4(material.color);
}

fragment half4 fragment_normal(VertexOut vertexIn [[ stage_in ]]) {
    float3 normal = abs(normalize(vertexIn.eyeNormal.xyz));
    return half4(normal.x, normal.y, normal.z, 1);
}


// the second parameter here is the texture in fragment buffer 0
fragment half4 fragment_texture_shader(VertexOut vertexIn [[ stage_in ]],
                                       texture2d<float> texture [[ texture(TextureIndexColor) ]],
                                       sampler sampler2d [[ sampler(SamplerIndexMain) ]]) {

    // extract color from current fragmnet coordinates
    float4 textcolor = texture.sample(sampler2d, vertexIn.textureCoordinates);
    //float4 color = vertexIn.color;
    //float3 normal = normalize(vertexIn.normal);

    if (textcolor.a == 0.0)
        discard_fragment();

    return half4(textcolor.r, textcolor.g, textcolor.b, 1);
}

fragment half4 fragment_textured_mask_shader(VertexOut vertexIn [[ stage_in ]],
                                             texture2d<float> texture [[ texture(TextureIndexColor)]],
                                             texture2d<float> maskTexture [[ texture(TextureIndexMask) ]],
                                             sampler sampler2d [[sampler(SamplerIndexMain)]]) {

    // extract color from current fragmnet coordinates
    float4 textcolor = texture.sample(sampler2d, vertexIn.textureCoordinates);

    // extract mask from current fragment coordinates
    float4 maskColor = maskTexture.sample(sampler2d, vertexIn.textureCoordinates);

    // check the opacity, if the opacity is less than 0.5, discard the fragment.
    // This means that the fragment will be empty when rendered.
    float maskOpacity = maskColor.a;
    if (maskOpacity < 0.5)
        discard_fragment();

    // Return the fragment color for the fragments that aren't discarded:
    return half4(textcolor.r, textcolor.g, textcolor.b, 1);
}
