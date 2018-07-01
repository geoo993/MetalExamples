//
//  Renderable.swift
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 28/06/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import MetalKit

protocol Renderable {
    var pipelineState: MTLRenderPipelineState! { get set }
    var samplerState: MTLSamplerState! { get set }
    var depthStencilState: MTLDepthStencilState! { get set }
    var vertexFunctionName: String { get }
    var fragmentFunctionName: String { get }
    var vertexDescriptor: MTLVertexDescriptor { get }
    var matrices: Matrices { get set }
    var materials: Materials { get set }
    var drawType: MTLPrimitiveType { get set }
    func doRender(commandEncoder: MTLRenderCommandEncoder,
                  modelMatrix: matrix_float4x4,
                  viewMatrix: matrix_float4x4,
                  projectionMatrix: matrix_float4x4)
}

extension Renderable {

    // MARK: - Setup pipeline state
    func buildPipelineState(device: MTLDevice) -> MTLRenderPipelineState {
        //1) all our shader functions will be stored in a library
        // so we setup a new library and set the vertex and fragment shader created
        let library = device.makeDefaultLibrary()

        //2) xcode will compile these function when we complie the project
        let vertexFunction = library?.makeFunction(name: vertexFunctionName) //"vertex_shader")
        let fragmentFunction = library?.makeFunction(name: fragmentFunctionName) //"fragment_shader")

        //3) create pipeline descriptor
        // the descriptor contains the reference to the shader functions and
        // we could create the pipeline state from the descriptor
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.vertexDescriptor = vertexDescriptor

        let pipelineState: MTLRenderPipelineState
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error as NSError {
            fatalError("error: \(error.localizedDescription)")
        }
        return pipelineState
    }

    // MARK: - Setup sampler state
    func buildSamplerState(device: MTLDevice) -> MTLSamplerState {
        let descriptor = MTLSamplerDescriptor()
        descriptor.minFilter = .linear
        descriptor.magFilter = .linear
        return device.makeSamplerState(descriptor: descriptor)!
    }

    // MARK: - Setup sampler state
    func buildDepthStencilState(device: MTLDevice) -> MTLDepthStencilState {
        // rendering triangles that are facing us still does not take into account Depth.
        // we have to tell the GPU how to measure Depth and we do this using a depth stencil state.
        // the word Stencil in graphics language means, which fragments are drawn or not drawn.
        // you can create stencil buffer to mask out areas of your rendered image.
        // The depth stencil masks out fragments that are behind other fragments.
        // during rendering the rasterizer creates fragments for the blue squares, and for the yellow square.
        // each fragment can be depth tested with another fragment in the same position.
        //We create the depth stencil state using a descriptor.
        let depthStencilDescriptor = MTLDepthStencilDescriptor()

        //When the depth compared function is set to less, any fragment further away are discarded.
        depthStencilDescriptor.depthCompareFunction = .less

        // we record the depth value for testing against other fragments with isDepthWriteEnabled
        depthStencilDescriptor.isDepthWriteEnabled = true
        
        return device.makeDepthStencilState(descriptor: depthStencilDescriptor)!
    }

}
