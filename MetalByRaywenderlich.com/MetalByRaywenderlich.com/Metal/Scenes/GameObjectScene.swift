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

        let teapot = Model(mtkView: view, modelName: "teapot", imageName: "tiles_baseColor.jpg",
                           fragmentShader: .fragment_toon_shader)
        teapot.name = "Teapot"
        teapot.scale = float3(2.0)
        teapot.material.shininess = 20
        teapot.position = float3(1, 2, 4)
        teapot.material.color = float4(1.0, 0.0, 0.0, 1)
        teapot.material.useTexture = false
        rootNode.children.append(teapot)

        let mushroom = Model(mtkView: view, modelName: "mushroom", fragmentShader: .fragment_toon_shader)
        mushroom.name = "Mushroom"
        mushroom.material.useTexture = true
        mushroom.material.color = float4(1, 0, 1, 1)
        mushroom.material.shininess = materialShininess
        rootNode.children.append(mushroom)

        let sphere = Sphere(mtkView: view, imageName: "explosion.png",
                            vertexShader: .vertex_fire_ball_shader, fragmentShader: .fragment_fire_ball_shader)
        sphere.name = "Sphere"
        sphere.material.useTexture = true
        sphere.material.color = float4(0, 1, 0, 1)
        sphere.material.shininess = materialShininess
        rootNode.children.append(sphere)

        for i in 0..<pointLightPositions.count {
            let position: float3 = pointLightPositions[i]
            let color: float3 = pointlightsColours[i]
            let pointLight = createPointLight(view: view, name: "PointLight\(i)", color: color, position: position, intensity: 0)
            add(childNode: pointLight.object)
            pointLights.append(pointLight.light)
        }

        camera.set(position: float3(0, 0,-5), viewpoint: float3(0,0,1), up: float3(0,1,0))
    }

    override func update(deltaTime: Float) {
        super.update(deltaTime: deltaTime)
        camera.updateRotation(angle: leftCameraAngle, displacement: leftCameraDisplacement)
        camera.updateMovement(deltaTime: deltaTime, angle: rightCameraAngle, displacement: rightCameraDisplacement)

        if let mushroom = nodeNamed("Mushroom") {
            //mushroom.rotation.y = -time
            mushroom.material.shininess = materialShininess
            mushroom.material.useTexture = true
        }

        if let sphere = nodeNamed("Sphere") {
            //sphere.rotation.y = -time
            sphere.position = float3(-3, 4, -5)
            sphere.material.shininess = materialShininess
            sphere.material.useTexture = true
        }

        if let teapot = nodeNamed("Teapot") {
            //teapot.material.color.x = sin( time * 0.1 )
            //teapot.material.color.y = sin( time * 0.06 )
            //teapot.material.color.z = sin( time * 0.03 )
            //teapot.material.color.w = 1.0
            teapot.material.shininess = materialShininess
            teapot.material.useTexture = false
        }

        for i in 0..<pointLightPositions.count {
            pointLights[i].position = pointLightPositions[i]
            pointLights[i].base.color = pointlightsColours[i]
            pointLights[i].base.intensity = lightIntensity
            pointLights[i].base.ambient = 0.15
            pointLights[i].base.diffuse = 0.8
            pointLights[i].base.specular = 0.9
            pointLights[i].atten.continual = 1.0
            pointLights[i].atten.linear = 0.09
            pointLights[i].atten.exponent = 0.032
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

    override func onSlider(_ type: SliderType, phase: UITouchPhase, value: Float) {
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
