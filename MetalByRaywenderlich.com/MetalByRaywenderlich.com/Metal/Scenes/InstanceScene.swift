
import MetalKit
import AppCore

class InstanceScene: Scene {

    var humans : Instance

    override init(device: MTLDevice, camera: Camera) {
        humans = Instance(device: device, modelName: "humanFigure", instances: 40)
        super.init(device: device, camera: camera)
        add(childNode: humans)

        for human in humans.nodes {
            human.position.x = Float(CGFloat.random(min: -2, max: 4))
            human.position.z = Float(CGFloat.random(min: -3, max: 3))
            human.material.color = UIColor.random.toFloat4
            human.material.useTexture = false
            human.scale = float3(0.5)

        }

        light.position = float3(-5, 10, 0)
        light.color = float3(1, 1, 1)
        light.direction = float3(-2, 0, 0)
        light.ambient = float3(0.2, 0.2, 0.2)
        light.diffuse = float3(0.8, 0.8, 0.8)
        light.specular = float3(1, 1.0, 1.0)

        camera.set(position: float3(0,4,-15), viewpoint: float3(0,0,1), up: float3(0,1,0))

    }

    override func update(deltaTime: Float) {
        super.update(deltaTime: deltaTime)


    }
}
