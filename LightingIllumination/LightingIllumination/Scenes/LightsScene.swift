

import MetalKit
import AppCore

public class LightsScene: Scene {

    var cubesPosition: [float3] = [
        float3(-1.0, -4.0, -1.0),
        float3(-8.0, 7.0, 5.0),
        float3(-5.0, 3.0, -2.0),
        float3(2.0, 5.0, 8.0),
        float3(-2.0, 8.0, -9.0),
        float3(4.0, -1.0, -2.0),
        float3(9.0, -5.0, 3.0),
        float3(-8.0, 2.0, 8.0)
    ]

    var cubesColor = float3(1.0)
    var lightCutoff: Float = 1
    var lightOuterCutoff: Float = 10
    var lightIntensity: Float = 10
    var materialShininess: Float = 32

    var previousTouchLocation: CGPoint = .zero
    var cameraRotation: Float = 0
    var leftCameraAngle: Float = 0
    var leftCameraDisplacement: Float = 0
    var rightCameraAngle: Float = 0
    var rightCameraDisplacement: Float = 0
    let fishCount = 12
    
    override public init(mtkView: MTKView, camera: Camera) {
        super.init(mtkView: mtkView, camera: camera)

    }

    override public func setup(view: MTKView) {
        super.setup(view: view)
        name = "Lights scene"
        
        /*
        for i in 0..<cubesPosition.count {
            let angle: Float = 20.0 * i.toFloat
            let position: float3 = cubesPosition[i]
            //let cube = Cube(mtkView: view, imageName: "container.png", fragmentShader: .lighting_fragment_shader)
            let cube = Model(mtkView: view, modelName: "mushroom", fragmentShader: .lighting_fragment_shader)
            cube.name = "Mushroom\(i)"
            cube.position = position
            cube.rotation = float3(1.0, angle, 1.0)
            cube.scale = float3(2.0)

            cube.material.color = float4(1,1,1, 1)
            cube.material.shininess = materialShininess
            cube.material.useTexture = true
            rootNode.children.append(cube)
        }

        
        
        let bob = Model(mtkView: view, modelName: "bob", imageName: "bob_baseColor.png",
                        fragmentShader: .lighting_fragment_shader)
        bob.name = "Bob"
        bob.material.color = float4(1.0, 1.0, 1.0, 1)
        bob.material.shininess = 100
        bob.material.useTexture = true
        rootNode.children.append(bob)

        for i in 1...fishCount {
            let blub = Model(mtkView: view, modelName: "blub", imageName: "blub_baseColor.png",
                            fragmentShader: .lighting_fragment_shader)
            blub.name = "Blub \(i)"
            blub.material.color = float4(1.0, 1.0, 1.0, 1)
            blub.material.shininess = 40
            blub.material.useTexture = true
            bob.children.append(blub)
        }

        let teapot = Model(mtkView: view, modelName: "teapot", imageName: "tiles_baseColor.jpg",
                           fragmentShader: .lighting_fragment_shader)
        teapot.name = "Teapot"
        teapot.scale = float3(2.0)
        teapot.material.shininess = materialShininess
        teapot.position = float3(3, 1, 8)
        teapot.material.color = float4(1.0, 0.0, 0.0, 1)
        teapot.material.useTexture = false
        rootNode.children.append(teapot)
 */

        for direction in directionalLightsDirections {
            let directionalLight = createDirectionalLight(color: float3(1, 1, 1), direction: direction)
            dirLights.append(directionalLight)
        }

        for i in 0..<pointLightPositions.count {
            let position: float3 = pointLightPositions[i]
            let color: float3 = pointlightsColours[i]
            let pointLight = createPointLight(view: view, name: "PointLight\(i)", color: color, position: position, intensity: 00)
            add(childNode: pointLight.object)
            pointLights.append(pointLight.light)
        }

        let spotLight = createSpotLight(view: view, color: float3(1,1,1), position: camera.position, cutoff: 0, outerCutoff: 0)
        spotLights.append(spotLight)

        camera.set(position: float3(0, 0,-5), viewpoint: float3(0,0,1), up: float3(0,1,0))
    }

    override public func update(deltaTime: Float) {
        super.update(deltaTime: deltaTime)
        camera.updateRotation(angle: leftCameraAngle, displacement: leftCameraDisplacement)
        camera.updateMovement(deltaTime: deltaTime, angle: rightCameraAngle, displacement: rightCameraDisplacement)

        //let angle = -time
        //rootNode.rotation.y = angle

        cubesColor.x = sin( time * 0.1 );
        cubesColor.y = sin( time * 0.06 );
        cubesColor.z = sin( time * 0.03 );

        for i in 0..<dirLights.count {
            dirLights[i].base.color = float3(1,1,1)
            dirLights[i].base.intensity = lightIntensity
        }

        for i in 0..<pointLightPositions.count {
            pointLights[i].position = pointLightPositions[i]
            pointLights[i].base.color = pointlightsColours[i]
            pointLights[i].base.intensity = lightIntensity
            pointLights[i].base.ambient = 0.1
            pointLights[i].base.diffuse = 0.8
            pointLights[i].base.specular = 0.9
            pointLights[i].atten.continual = 1.0
            pointLights[i].atten.linear = 0.09
            pointLights[i].atten.exponent = 0.032
        }

        for i in 0..<spotLights.count {
            spotLights[i].pointLight.position = camera.position
            spotLights[i].pointLight.base.color = float3(1.0, 1.0, 1.0)
            spotLights[i].pointLight.base.intensity = lightIntensity
            spotLights[i].pointLight.base.ambient = 0.1
            spotLights[i].pointLight.base.diffuse = 1.0
            spotLights[i].pointLight.base.specular = 1.0
            spotLights[i].pointLight.atten.continual = 1.0
            spotLights[i].pointLight.atten.linear = 0.09
            spotLights[i].pointLight.atten.exponent = 0.032
            spotLights[i].direction = camera.front
            spotLights[i].cutOff = cos(radians(degrees: lightCutoff))
            spotLights[i].outerCutOff = cos(radians(degrees: lightOuterCutoff))
        }
        
        /*
        for i in 0..<cubesPosition.count {
            if let cube = nodeNamed("Mushroom\(i)") {
                cube.material.useTexture = true
                cube.material.color = float4(1,1,1,1)
                cube.material.shininess = materialShininess
            }
        }

        if let teapot = nodeNamed("Teapot") {
            teapot.material.color = float4(cubesColor.x, cubesColor.y, cubesColor.z, 1)
            teapot.material.shininess = materialShininess
            teapot.material.useTexture = true
        }
        
        if let bob = nodeNamed("Bob") {
            bob.position = float3(0, 0.015 * sin(time * 5), 0)
            bob.material.color = float4(1,1,1,1)
            bob.material.shininess = materialShininess
            bob.material.useTexture = true
        }

        let blubBaseTransform = float4x4(rotationAbout: float3(0, 0, 1), by: -.pi / 2) *
                                float4x4(scaleBy: 0.25) *
                                float4x4(rotationAbout: float3(0, 1, 0), by: -.pi / 2)
        for i in 1...fishCount {
            if let blub = nodeNamed("Blub \(i)") {
                let pivotPosition = float3(0.4, 0, 0)
                let rotationOffset = float3(0.4, 0, 0)
                let rotationSpeed = Float(0.3)
                let rotationAngle = 2 * Float.pi * Float(rotationSpeed * time) + (2 * Float.pi / Float(fishCount) * Float(i - 1))
                let horizontalAngle = 2 * .pi / Float(fishCount) * Float(i - 1)
                let modelMatrix = float4x4(rotationAbout: float3(0, 1, 0), by: horizontalAngle) *
                                  float4x4(translationBy: rotationOffset) *
                                  float4x4(rotationAbout: float3(0, 0, 1), by: rotationAngle) *
                                  float4x4(translationBy: pivotPosition) *
                                  blubBaseTransform

                blub.overrideModelMatrix = true
                blub.modelMatrix = modelMatrix
                blub.material.color = float4(1,1,1,1)
                blub.material.shininess = materialShininess
                blub.material.useTexture = true
            }
        }

        */
    }

    override public func touchesBegan(_ view: UIView, touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        previousTouchLocation = touch.location(in: view)
    }

    override public func touchesMoved(_ view: UIView, touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: view)
        //let delta = CGPoint(x: previousTouchLocation.x - touchLocation.x,
        //                    y: previousTouchLocation.y - touchLocation.y)

        //mushroom.rotation.x += Float(delta.y) * camera.sensitivity
        //mushroom.rotation.y += Float(delta.x) * camera.sensitivity

        previousTouchLocation = touchLocation
    }

    override public func onSlider(_ type: SliderType, phase: UITouch.Phase, value: Float) {
        switch type {
        case .slider_x0: // 0 - 1
            break
        case .slider_x1: // 0 - 5
            break
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

