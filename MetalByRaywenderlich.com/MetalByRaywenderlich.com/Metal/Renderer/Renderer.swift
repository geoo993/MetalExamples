//
//  Renderer.swift
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 25/06/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import MetalKit
import AppCore

class Renderer: NSObject {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue

    // create device scene
    let scene: Scene

    //MARK: - initialise the Renderer with a device
    init(device: MTLDevice, scene: Scene) {
        //⚠️ there should only be one device and one command queue per application

        //1) Create a reference to the GPU, which is the Device
        self.device = device

        //2) Create a command Queue
        self.commandQueue = device.makeCommandQueue()!

        // set the scene
        self.scene = scene
        super.init()

    }

}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        scene.sceneSizeWillChange(to: size.half)
    }

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


        let deltaTime = 1 / Float(view.preferredFramesPerSecond)

        // set the scene
        scene.render(commandEncoder: commandEncoder, deltaTime: deltaTime)
        
        
        commandEncoder.endEncoding()
        commandBuffer.present(drawable)

        //4) send command buffer to the GPU when you finish encoding all the commands
        commandBuffer.commit()

    }
}
