
import MetalKit
import AppCore

public class InstanceScene: Scene {

    var humans: Instance!

    override init(mtkView: MTKView, camera: Camera) {
        super.init(mtkView: mtkView, camera: camera)

    }
    
    override public func setup(view: MTKView) {
        super.setup(view: view)
        name = "Instance scene"

        humans = Instance(mtkView: view, modelName: "humanFigure", instances: 40, fragmentShader: .fragment_shader)
        add(childNode: humans)

        for human in humans.nodes {
            human.position.x = Float(CGFloat.random(min: -2, max: 4))
            human.position.z = Float(CGFloat.random(min: -3, max: 3))
            human.material.color = UIColor.random.toFloat4
            human.material.useTexture = false
            human.scale = float3(0.5)

        }

        camera.set(position: float3(0,4,-15), viewpoint: float3(0,0,1), up: float3(0,1,0))

    }

    override public func update(deltaTime: Float) {
        super.update(deltaTime: deltaTime)


    }
}
