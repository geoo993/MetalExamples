//
//  GameObjectScene.swift
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 28/07/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import MetalKit
import AppCore

class GameObjectScene: Scene {

    var lightCutoff: Float = 1
    var lightOuterCutoff: Float = 10
    var lightIntensity: Float = 10
    var materialShininess: Float = 32

    var previousTouchLocation: CGPoint = .zero
    var leftCameraAngle: Float = 0
    var leftCameraDisplacement: Float = 0
    var rightCameraAngle: Float = 0
    var rightCameraDisplacement: Float = 0

    override init(mtkView: MTKView, camera: Camera) {
        super.init(mtkView: mtkView, camera: camera)

    }

    override func setup(view: MTKView) {
        super.setup(view: view)
        name = "GameObject scene"

        let sphere = Sphere(mtkView: view, imageName: "explosion.png",
                            vertexShader: .vertex_fire_ball_shader, fragmentShader: .fragment_fire_ball_shader)
        sphere.name = "Sphere"
        sphere.material.useTexture = true
        sphere.material.color = float4(0, 1, 0, 1)
        sphere.material.shininess = materialShininess
        rootNode.children.append(sphere)

        camera.set(position: float3(0, 0,-5), viewpoint: float3(0,0,1), up: float3(0,1,0))
    }

    override func update(deltaTime: Float) {
        super.update(deltaTime: deltaTime)
        camera.updateRotation(angle: leftCameraAngle, displacement: leftCameraDisplacement)
        camera.updateMovement(deltaTime: deltaTime, angle: rightCameraAngle, displacement: rightCameraDisplacement)

        if let sphere = nodeNamed("Sphere") {
            sphere.rotation.y = -time
        }

    }

    override func touchesBegan(_ view: UIView, touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        previousTouchLocation = touch.location(in: view)
    }

    override func touchesMoved(_ view: UIView, touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: view)
        previousTouchLocation = touchLocation
    }

    override func onSlider(_ type: SliderType, phase: UITouch.Phase, value: Float) {
        switch type {
        case .slider_x0: // 0 - 1
            toonEdge = value
            fireBallExplo = value
        case .slider_x1: // 0 - 5
            fireBallFreq = value
        case .slider_x2: // 0 - 10
            lightCutoff = value
        case .slider_x3: // 0 - 50
            lightOuterCutoff = value
        case .slider_x4: // 0 - 100
            lightIntensity = value
        case .slider_x5: // 0 - 255
            materialShininess = value
        }
    }

}
