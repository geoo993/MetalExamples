//
//  Shader.metal
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 26/06/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

// --------- What Are Shaders --------
// Shaders are small programs that run on the GPU.
// We use the term shader because of history.
// In the openGL pipeline shaders are used to control the shading.
// Now days we are able to program the shader in the pipeline and do a lot more than just shading.
// but the term shader is convenient to generically describe these GPU programs.
// There are three types of shader functions, and we use two of the shader functions in the graphics pipeline.
// 1- The vertex function, where we can manipulate the vertices jand their positions (graphics function)
// 2- The fragment function, where we can manipulate pixel colors (graphics function)
// 3- The kernel function, is used for parallel programming and operates on a grid or an array of data
// the graphics shader function created in the .metal file use Metal Shading Language.
// When we compile the project Xcode compiles thes .metal files into a special defualt library file.
// So unlike OpenGL, all our shader functions are compiled before the App even opens.


#include <metal_stdlib>
using namespace metal;

// --------- Attributes --------

struct Constants {
    float animateBy;
};

// input information to the shader
// note that each item in the struct has been given an attribute number
struct VertexIn {
    float4 position [[ attribute(0) ]];
    float4 color [[ attribute(1) ]];
    float2 textureCoordinates [[ attribute(2) ]];
};

// this tells the rasterisor, which of these data items contains, contains the vertex position or color value
struct VertexOut {
    float4 position [[ position ]];
    float4 color;
    float2 textureCoordinates;
};


// --------- Vertex Shader --------
// this is a vertex function so we prefix it with vertex and we are going to
// return a float4 for the position of the vertex.
// The vertex function job is to position vertex in 3d space
// the parameters are the vertices array that you created in the Renderer,
// and the vertexId is the current vertex being processed on the GPU.
// here we could do all sorts of maths to change the position of the vertex.
// the output of this function is the input of the next stage in the pipeline.
// The GPU assembles the vertices into triagle primitives and the rasterizer
// then takes over and splits our triangle into fragments.

/*
vertex float4 vertex_shader(const device packed_float3 *vertices [[ buffer(0) ]],
                            uint vertexId [[ vertex_id ]]) {
    return float4(vertices[vertexId], 1);
}
*/

// we add the constants in the parameters to send data to the GPU, we give the constant the attribute
// buffer 1 which is the buffer number that we allocated in the Renderer
/*
vertex float4 vertex_shader(const device packed_float3 *vertices [[ buffer(0) ]],
                            constant Constants &constants [[ buffer(1) ]],
                            uint vertexId [[ vertex_id ]]) {

    float4 position = float4(vertices[vertexId], 1);
    position.x += constants.animateBy;

    return position;
}
*/

vertex VertexOut vertex_shader(const VertexIn vertexIn [[ stage_in ]]) {
    VertexOut vertexOut;
    vertexOut.position = vertexIn.position;
    vertexOut.color = vertexIn.color;
    vertexOut.textureCoordinates = vertexIn.textureCoordinates;

    return vertexOut;
}





// --------- Fragment Shader --------

// the fragment function the one that returns the color of each fragment is the one that is easier that the vertex fucntion.
// it is a fragment function so we prefix it with fragment and returning a half4,
// which is a smaller float4 and calling the function fragment_shader
/*
fragment half4 fragment_shader() {
    return half4(1, 1, 0, 1);
}
 */

// notice the special qualifier 'stage_in', all the vertex information within this in-struct has been interpolated,
// during this rasterisation process, in other words it is data that the rasterisor has generated per fragment,
// rather than one constant value for all fragments.
fragment half4 fragment_shader(VertexOut vertexIn [[ stage_in ]]) {
    return half4(vertexIn.color);
}

// the second parameter here is the texture in fragment buffer 0
fragment half4 textured_fragment(VertexOut vertexIn [[ stage_in ]],
                                 sampler sampler2d [[ sampler(0) ]],
                                 texture2d<float> texture [[ texture(0) ]] ) {
    // use a default sampler state
   // constexpr sampler defaultSampler;


    // extract color from current fragmnet coordinates
    float4 textcolor = texture.sample(sampler2d, vertexIn.textureCoordinates);
    //float4 vOutColor = textcolor * vertexIn.color;

    return half4(textcolor.r, textcolor.g, textcolor.b, 1);

}
