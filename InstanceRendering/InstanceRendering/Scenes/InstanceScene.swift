
import MetalKit
import AppCore

public class InstanceScene: Scene {

    var humans: Instance!
    
    var previousTouchLocation: CGPoint = .zero
    var cameraRotation: Float = 0
    var leftCameraAngle: Float = 0
    var leftCameraDisplacement: Float = 0
    var rightCameraAngle: Float = 0
    var rightCameraDisplacement: Float = 0
    
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
        camera.updateRotation(angle: leftCameraAngle, displacement: leftCameraDisplacement)
        camera.updateMovement(deltaTime: deltaTime, angle: rightCameraAngle, displacement: rightCameraDisplacement)
    }
    
    override public func touchesBegan(_ view: UIView, touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        previousTouchLocation = touch.location(in: view)
    }
    
    override public func touchesMoved(_ view: UIView, touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: view)
        previousTouchLocation = touchLocation
    }
    
}
