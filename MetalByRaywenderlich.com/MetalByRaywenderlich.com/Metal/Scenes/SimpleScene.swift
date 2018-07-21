

import MetalKit
import AppCore

class SimpleScene: Scene {

    var rootNode: Node!
    var pointLightPositions: [float3] = [
        float3(  5.0,  5.0,  0.0      ),
        float3(  -5.0,  5.0,  0.0      ),
        float3(  0.0, -5.0, 0.0      ),
    ]

    var pointlightsColours: [float3] = [
        float3(0.4, 0.4, 0.5),
        float3(0.4, 0.6, 0.7),
        float3(0.3, 0.3, 0.3),
    ]

    var leftCameraAngle: Float = 0
    var leftCameraDisplacement: Float = 0
    var rightCameraAngle: Float = 0
    var rightCameraDisplacement: Float = 0
    let fishCount = 12
    
    override init(mtkView: MTKView, camera: Camera) {
        super.init(mtkView: mtkView, camera: camera)

    }

    override func setup(view: MTKView) {
        super.setup(view: view)
        name = "Simple scene"
        rootNode = Node(name: "Root")
        add(childNode: rootNode)

        // Point Light
        for i in 0..<pointLightPositions.count {
            let position: float3 = pointLightPositions[i]
            let color: float3 = pointlightsColours[i];
            let light = Cube(mtkView: view, fragmentShader: .fragment_color)

            light.name = "PointLight\(i)"
            light.position = position
            light.scale = float3(0.4, 0.4, 0.4)
            light.material.color = float4(color.x, color.y, color.z, 1.0)
            light.material.shininess = 100
            light.material.useTexture = false
            rootNode.children.append(light)

            var pointLight = PointLight()
            pointLight.position = position
            pointLight.base.color = color
            pointLight.base.intensity = 20
            pointLight.base.power = 100
            pointLight.base.ambient = float3(0.1, 0.1, 0.1)
            pointLight.base.diffuse = float3(0.6, 0.6, 0.6)
            pointLight.base.specular = float3(0.8, 0.8, 0.8)
            pointLight.atten.continual = 1.0
            pointLight.atten.linear = 0.09
            pointLight.atten.exponent = 0.32
            pointLight.range = 20

            pointLights.append(pointLight)
        }

        let bob = Model(mtkView: view, modelName: "bob", imageName: "bob_baseColor.png",
                        fragmentShader: .fragment_light_mix_shader)
        bob.material.shininess = 100
        bob.material.color = float4(0.8, 0.8, 0.8, 1)
        bob.material.useTexture = true
        rootNode.children.append(bob)

        for i in 1...fishCount {
            let blub = Model(mtkView: view, modelName: "blub", imageName: "blub_baseColor.png",
                            fragmentShader: .fragment_light_mix_shader)
            blub.name = "Blub \(i)"
            blub.material.shininess = 40
            blub.material.color = float4(0.8, 0.8, 0.8, 1)
            bob.children.append(blub)

        }


        camera.set(position: float3(0, 0,-5), viewpoint: float3(0,0,1), up: float3(0,1,0))


    }

    override func update(deltaTime: Float) {
        super.update(deltaTime: deltaTime)
        camera.updateRotation(angle: leftCameraAngle, displacement: leftCameraDisplacement)
        camera.updateMovement(deltaTime: deltaTime, angle: rightCameraAngle, displacement: rightCameraDisplacement)


        let angle = -time
        rootNode.rotation.y = angle

        if let bob = nodeNamed("Bob") {
            bob.position = float3(0, 0.015 * sin(time * 5), 0)
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

            }
        }
        
    }

    func nodeNamed(_ name: String) -> Node? {
        if rootNode.name == name {
            return rootNode
        } else {
            return rootNode.get(childNode: name)
        }
    }
}

