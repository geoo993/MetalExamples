//
//  Renderer.swift
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 25/06/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import MetalKit

class Renderer: NSObject {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue

    // create device scene
    var scene: Scene?

    // pipeline descriptor state for referencing shader
    var pipelineState: MTLRenderPipelineState?

    // sampler state for texture
    var samplerState: MTLSamplerState?

    //MARK: - initialise the Renderer with a device
    init(device: MTLDevice) {
        //⚠️ there should only be one device and one command queue per application

        //1) Create a reference to the GPU, which is the Device
        self.device = device

        //2) Create a command Queue
        self.commandQueue = device.makeCommandQueue()!
        super.init()

        //3) setup model and pipeline
        //buildPipelineState()
        buildSamplerState()
    }

    // MARK: - Setup pipeline state
    private func buildPipelineState() {
        //1) all our shader functions will be stored in a library
        // so we setup a new library and set the vertex and fragment shader created
        let library = device.makeDefaultLibrary()

        //2) xcode will compile these function when we complie the project
        let vertexFunction = library?.makeFunction(name: "vertex_shader")
        let fragmentFunction = library?.makeFunction(name: "fragment_shader")

        //3) create pipeline descriptor
        // the descriptor contains the reference to the shader functions and
        // we could create the pipeline state from the descriptor
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        let vertexDescriptor = MTLVertexDescriptor()
        // describe the position data from Vertex struct
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0 // buffer index of vertex array

        // describe the color data from Vertex struct
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].offset = MemoryLayout<float3>.stride // float3 offset from the first attribute as we are striding, this was the size of the position attribute
        vertexDescriptor.attributes[1].bufferIndex = 0 // buffer index of vertex array

        vertexDescriptor.attributes[2].format = .float2
        vertexDescriptor.attributes[2].offset = MemoryLayout<float3>.stride + MemoryLayout<float4>.stride // float3 and float4 offset from the second attribute as we are striding, this is the size of the position and color attribute
        vertexDescriptor.attributes[2].bufferIndex = 0 // buffer index of vertex array still at 0

        // tell the vertex descriptor the size of the information held for each vertex
        vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.stride

        pipelineDescriptor.vertexDescriptor = vertexDescriptor


        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }

    // MARK: - Setup sampler state
    private func buildSamplerState() {
        let descriptor = MTLSamplerDescriptor()
        descriptor.minFilter = .linear
        descriptor.magFilter = .linear
        samplerState = device.makeSamplerState(descriptor: descriptor)
    }

}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) { }

    // MARK: - Draw object
    func draw(in view: MTKView) {

        //1) The MTKView view has a drawable, which is not an object that is displayed in the screen and
        // we issue our drawing command to this drawable.
        // The MTKView also has a render pass descriptor, which describes how the buffers are to be rendered,
        // we use this descriptor to create the command encoder.
        // Metla uses descriptor to setup Metal objects.
        // descriptors are like blueprints, a descriptor allows you to set requirement and spec about your object
        // when you setup a descriptor, you are setting up the list of properties you want your object to have.
        // then you createyour object from that descriptor, if you subsequently change the desciptor properties,
        // you're only changing the list and not the original object.
        guard let drawable = view.currentDrawable,
            let descriptor = view.currentRenderPassDescriptor
           // let pipelineState = self.pipelineState
            //let indexBuffer = self.indexBuffer
            else { return }

        //2) Create a command buffer to hold the command encoder
        let commandBuffer = commandQueue.makeCommandBuffer()!

        //3) Encode all the commands
        let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)!

        commandEncoder.setFragmentSamplerState(samplerState, index: 0)


        let deltaTime = 1 / Float(view.preferredFramesPerSecond)

        // set the scene
        scene?.render(commandEncoder: commandEncoder, deltaTime: deltaTime)
        
        
        commandEncoder.endEncoding()
        commandBuffer.present(drawable)

        //4) send command buffer to the GPU when you finish encoding all the commands
        commandBuffer.commit()

    }
}
