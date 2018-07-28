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

    @IBOutlet weak var metalKitView: MTKView!
    @IBOutlet weak var slider0: UISlider!
    @IBOutlet weak var slider1: UISlider!
    @IBOutlet weak var slider2: UISlider!
    @IBOutlet weak var slider3: UISlider!
    @IBOutlet weak var slider4: UISlider!
    @IBOutlet weak var slider5: UISlider!
    @IBOutlet weak var leftJoyStick: JoyStickView!
    @IBOutlet weak var rightJoyStick: JoyStickView!

    var renderer: Renderer!

    override func viewDidLoad() {
        super.viewDidLoad()

        //1) Create a reference to the GPU, which is the Device and setup properties
        metalKitView.device = MTLCreateSystemDefaultDevice() //  A device is an abstraction of the GPU and provides us a few methods and properties.
        metalKitView.clearColor = MTLClearColorMake(0.01, 0.01, 0.01, 1.0)

        guard let device = metalKitView.device else {
            fatalError("Your GPU does not support Metal!")
        }
        print("\(device.name)\n")

        // we need to tell Metal to store the depth of each fragment as we process it,
        // keeping the closest depth value and only replacing it if we see a fragment that is closer to the camera.
        // This is called depth buffering, and fortunately, it’s not too hard to configure.
        // Depth buffering requires the use of an additional texture called, naturally, the depth buffer.
        // This texture is a lot like the color texture we’re already presenting to the screen when we’re done drawing,
        // but instead of storing color, it stores depth, which is basically the distance from the camera to the surface.
        metalKitView.depthStencilPixelFormat = .depth32Float_stencil8

        // we need to tell the view the format of the color texture we will be drawing to. We will choose bgra8Unorm, which is a format that uses one byte per color channel (red, green, blue, and alpha (transparency)), laid out in blue, green, red, alpha order. The Unorm portion of the name signifies that the components are stored as unsigned 8-bit values, so that the values 0-255 map to 0-100% intensity (or 0-100% opacity, in the case of the alpha channel).
        metalKitView.colorPixelFormat = .bgra8Unorm_srgb
        metalKitView.sampleCount = 1

        guard metalKitView.device != nil else {
            fatalError("Device not created. Run on a physical device")
        }

        // setup scene
        let currentDevice = UIDevice.current.modelName
        let width = CGFloat.width(ofDevice: currentDevice).width
        let height = CGFloat.height(ofDevice: currentDevice).height
        let screenSize = CGSize(width: width, height: height)

        let camera = Camera(fov: 45, size: screenSize, zNear: 0.1, zFar: 100)

        //let primitivesScene = PrimitivesScene(mtkView: metalKitView, camera: camera)
        //let instanceScene = InstanceScene(mtkView: metalKitView, camera: camera)
        //let landscapeScene = LandscapeScene(mtkView: metalKitView, camera: camera)
        //let scene = LightsScene(mtkView: metalKitView, camera: camera)
        let scene = GameObjectScene(mtkView: metalKitView, camera: camera)

        // create renderer
        renderer = Renderer(mtkView: metalKitView, scene: scene)

        // Setup MTKView and delegate
        metalKitView.delegate = renderer

        // Play sound
        //SoundController.shared.playBackgroundMusic("Gem.mp3")

        leftJoyStick.monitor = { angle, displacement in
            scene.leftCameraAngle = Float(angle)
            scene.leftCameraDisplacement = Float(displacement)
            //print("left joystick angle \(angle)")
            //print("left joystick magnitude \(displacement)")
        }
        rightJoyStick.monitor = { angle, displacement in
            scene.rightCameraAngle = Float(angle)
            scene.rightCameraDisplacement = Float(angle)
            //print("right joystick angle \(angle)")
            //print("right joystick angle \(displacement)")
        }

        slider0.addTarget(self, action: #selector(onSliderChanged(slider:event:)), for: .valueChanged)
        slider1.addTarget(self, action: #selector(onSliderChanged(slider:event:)), for: .valueChanged)
        slider2.addTarget(self, action: #selector(onSliderChanged(slider:event:)), for: .valueChanged)
        slider3.addTarget(self, action: #selector(onSliderChanged(slider:event:)), for: .valueChanged)
        slider4.addTarget(self, action: #selector(onSliderChanged(slider:event:)), for: .valueChanged)
        slider5.addTarget(self, action: #selector(onSliderChanged(slider:event:)), for: .valueChanged)

    }

    @objc func onSliderChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch slider.tag {
            case 0:
                renderer.scene.onSlider(.slider_x0, phase: touchEvent.phase, value: slider.value)
            case 1:
                renderer.scene.onSlider(.slider_x1, phase: touchEvent.phase, value: slider.value)
            case 2:
                renderer.scene.onSlider(.slider_x2, phase: touchEvent.phase, value: slider.value)
            case 3:
                renderer.scene.onSlider(.slider_x3, phase: touchEvent.phase, value: slider.value)
            case 4:
                renderer.scene.onSlider(.slider_x4, phase: touchEvent.phase, value: slider.value)
            case 5:
                renderer.scene.onSlider(.slider_x5, phase: touchEvent.phase, value: slider.value)
            default:
                break
            }
        }
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
