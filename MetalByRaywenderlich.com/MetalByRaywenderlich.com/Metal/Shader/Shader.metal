//
//  Shader.metal
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 26/06/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Constants {
    float animateBy;
};


// this is a vertex function so we prefix it with vertex and we are going to
// return a float4 for the position of the vertex.
// the parameters are the vertices array that you created in the Renderer,
// and the vertexId is the current vertex being processed on the GPU.
// here we could do all sorts of maths to change the position of the vertex.
// the output of this function is the input of the next stage in the pipeline.
// The GPU assembles the vertices into triagle primitives and the rasterizer
// then takes over and splits our triangle into fragments.

//vertex float4 vertex_shader(const device packed_float3 *vertices [[ buffer(0) ]],
//                            uint vertexId [[ vertex_id ]]) {
//    return float4(vertices[vertexId], 1);
//}

// we add the constants in the parameters to send data to the GPU, we give the constant the attribute
// buffer 1 which is the buffer number that we allocated in the Renderer
vertex float4 vertex_shader(const device packed_float3 *vertices [[ buffer(0) ]],
                            constant Constants &constants [[ buffer(1) ]],
                            uint vertexId [[ vertex_id ]]) {

    float4 position = float4(vertices[vertexId], 1);
    position.x += constants.animateBy;

    return position;
}


// the fragment function the one that returns the color of each fragment is the one that is easier that the vertex fucntion.
// it is a fragment function so we prefix it with fragment and returning a half4,
// which is a smaller float4 and calling the function fragment_shader
fragment half4 fragment_shader() {
    return half4(1, 1, 0, 1);
}
