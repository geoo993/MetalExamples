//
//  Renderer.swift
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 25/06/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import Foundation
import MetalKit

class Renderer: NSObject {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue

    // vertices drawn anti-clockwise
    var vertices: [Float] = [
        -1,  1, 0,   // V0  top left
        -1, -1, 0,   // V1  bottom left
        1, -1, 0,   // V2   bottom right
        1, -1, 0,   // V2   bottom right
        1,  1, 0,   // V3   top right
        -1,  1, 0    // V0  top left
    ]

    var pipelineState: MTLRenderPipelineState?
    var vertexBuffer: MTLBuffer?

    //MARK: - initialise the Renderer with a device
    init(device: MTLDevice) {
        //⚠️ there should only be one device and one command queue per application

        //1) Create a reference to the GPU, which is the Device
        self.device = device

        //2) Create a command Queue
        self.commandQueue = device.makeCommandQueue()!
        super.init()

        //3) setup model and pipeline
        buildModel()
        buildPipelineState()
    }

    // MARK: - create metal buffer that holds the vertices from the vertices array
    private func buildModel() {
        vertexBuffer = device.makeBuffer(bytes: vertices,
                                         length: vertices.count * MemoryLayout<Float>.size,
                                         options: [])
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

        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
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
            let descriptor = view.currentRenderPassDescriptor,
            let pipelineState = self.pipelineState else { return }

        //2) Create a command buffer to hold the command encoder
        let commandBuffer = commandQueue.makeCommandBuffer()!

        //3) Encode all the commands
        let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)!

        //4) setup the state and send the vertex buffer to the GPU and the the GPU to draw those vertices
        // The pipeline state will tell the GPU what shader function to use.
        // It is possible that you will need to use different shader functions for different objects that you render,
        // so you may need to setup multiple pipelines, which will mean that you will need to send the GPU
        // multiple commands each with its own command encoder.
        commandEncoder.setRenderPipelineState(pipelineState)


        //5) we then tell the GPU to use our vertex buffer, the offset is the starting byte.
        // you can see that if we had more complex buffers, we can tell the offset to start somewhere else in the buffer.
        // internaly, there is an index table of buffer and the at index specifies whihc entry in the table
        // the buffer is at. you can have up to 31 buffers.
        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)


        //6) finally we setup to draw, we specify that we are drawing a triangle primitive rather than a point or a line.
        // remember that we are setting a list of commands to the command encoder that get sent off in a batch
        // to the GPU, it is not until the commit at the end of the methods that we finish drawing or object.
        commandEncoder.drawPrimitives(type: MTLPrimitiveType.triangle,
                                      vertexStart: 0, vertexCount: vertices.count)

        commandEncoder.endEncoding()
        commandBuffer.present(drawable)

        //7) send command buffer to the GPU when you finish encoding all the commands
        commandBuffer.commit()

    }
}
