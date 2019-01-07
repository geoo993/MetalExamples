//
//  ViewController.swift
//  FireBall
//
//  Created by GEORGE QUENTIN on 06/01/2019.
//  Copyright © 2019 GEORGE QUENTIN. All rights reserved.
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

