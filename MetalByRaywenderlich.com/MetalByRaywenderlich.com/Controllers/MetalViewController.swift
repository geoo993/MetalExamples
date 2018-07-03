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

// -------- The Metal Coordinates -------
// metal coordinates are a squashed queue, with 2 units width,
// 2 units height and 1 unit depth.
// The top left in 2D is (-1, 1), the bottom right is (1, -1),
// the center is (0, 0).
// before drawing object we have to setup a structure before drawing the vertices,
// each vertex need 3 floats to describe it.
// we then create a metal buffer with these vertices where we specify
// how much bytes the vertices array with the length of the number of items in the array,
// multiplied by the size of the float.
//

import UIKit
import MetalKit
import AppCore

class MetalViewController: UIViewController {

    var metalView: MTKView {
        return view as! MTKView
    }

    var renderer: Renderer!

    override func viewDidLoad() {
        super.viewDidLoad()

        //1) Create a reference to the GPU, which is the Device
        metalView.device = MTLCreateSystemDefaultDevice()
        guard let device = metalView.device else {
            fatalError("Device not created. Run on a physical device")
        }

        // create renderer
        let currentDevice = UIDevice.current.modelName
        let width = CGFloat.width(ofDevice: currentDevice).width
        let height = CGFloat.height(ofDevice: currentDevice).height
        let screenSize = CGSize(width: width, height: height)
        let camera = Camera(fov: 45, size: screenSize, zNear: 0.1, zFar: 1000)

        let primitivesScene = PrimitivesScene(device: device, camera: camera)
        let lightingScene = LightingScene(device: device, camera: camera)
        let instanceScene = InstanceScene(device: device, camera: camera)
        let landscapeScene = LandscapeScene(device: device, camera: camera)
        renderer = Renderer(device: device, scene: lightingScene)

        // Setup MTKView and delegate
        metalView.clearColor = UIColor.darkKhaki.toMTLClearColor
        metalView.depthStencilPixelFormat = .depth32Float
        metalView.delegate = renderer

        SoundController.shared.playBackgroundMusic("Gem.mp3")

    }

    deinit {
        print("🗑")
    }

}

// MARK: - Gestures
extension MetalViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        renderer?.scene.touchesBegan(view, touches:touches, with: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        renderer?.scene.touchesMoved(view, touches: touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        renderer?.scene.touchesEnded(view, touches: touches, with: event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        renderer?.scene.touchesCancelled(view, touches: touches, with: event)
    }
}
