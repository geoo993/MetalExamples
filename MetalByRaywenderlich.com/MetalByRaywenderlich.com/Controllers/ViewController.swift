//
//  ViewController.swift
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 25/06/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//
// -------- Metal Drawing Overview -------
// what we have to do for the GPU to get evrything to render.
// 1) At the start of the Metal App we create a MTLDevice object that represents the GPU.
// 2) The GPU needs to be able to accept a list of commands, so we also setup a command queue (MTLCommandQueue)
// when the App starts.
// 3) We set a pipeline state (MTLRenderPipelineState) that among other things will tell the GPU what shader functions to use.
// 4) generally at the start of the App, we will also setup a series of special buffers (MTLBuffer),
// these are memory areas that will hold the models and textures that we will use in the App.
// For example if we were rendering a triangle, we will store the locations of each vertex in the triangle in a buffer.
// 5) for each frame we will need to create a list of commands for the GPU, such as draw the contents of the triangle buffer. So we create a command buffer (MTLCommandBuffer) to store these commands in.
// 6) each command is stored in a render command encoder (MTLRenderCommandEncoder),
// this contains all the state information that the GPU will need to execute that command.
// 7) when we have encoded all our comands, we commit the command buffer which sends it off to the GPU.

// -------- The Metal Pipeline -------
// When rendering computer graphics there is a strict pipeline,
// A pipeline is just a sequence of operations that the GPU will perform.
// Along this pipeline are certain states that you would already have setup, so that the GPU can do its job.
// the pipeline steps include (Setup -> Vertex Processing -> Primitive Assembly -> Rasterisation
// Fragment Processing -> Present)
// the pipeline steps of (Setup -> Vertex Processing -> Fragment Processing) are the ones that
// you have complete control, however (Primitive Assembly -> Rasterisation -> Present) happen on the GPU automatically.
//


import UIKit
import MetalKit
import AppCore

class ViewController: UIViewController {

    var metalView: MTKView {
        return view as! MTKView
    }

    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!

    override func viewDidLoad() {
        super.viewDidLoad()

        //1) Create a reference to the GPU, which is the Device
        metalView.device = MTLCreateSystemDefaultDevice()
        device = metalView.device

        // Setup MTKView and delegate
        metalView.clearColor = UIColor.wenderlichGreen.toMTLClearColor
        metalView.delegate = self

        //2) Create a command Queue
        commandQueue = device.makeCommandQueue()

        //⚠️ there should only be one device and one command queue per application

    }
}


extension ViewController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {

    }

    // called every frame
    func draw(in view: MTKView) {

        // The MTKView view has a drawable, whihc is not an object that is displayed in the screen and
        // we issue how drawing command to this drawable
        // The MTKView also has a render pass descriptor, whihc describes how the buffers are to be rendered,
        // we use this descriptor to create the command encoder
        guard let drawable = view.currentDrawable,
            let descriptor = view.currentRenderPassDescriptor else { return }

        //3) Create a command buffer to hold the command encoder
        let commandBuffer = commandQueue.makeCommandBuffer()

        //4) Encode all the commands
        let commandEncoder = commandBuffer?
            .makeRenderCommandEncoder(descriptor: descriptor)
        commandEncoder?.endEncoding()
        commandBuffer?.present(drawable)

        //5) send command buffer to the GPU when you finish encoding all the commands
        commandBuffer?.commit()
    }


}


