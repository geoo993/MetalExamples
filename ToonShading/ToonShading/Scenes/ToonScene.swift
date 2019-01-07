
import MetalKit
import AppCore

public class ToonScene: Scene {

    var sphere: Sphere!

    var previousTouchLocation: CGPoint = .zero
    var cameraRotation: Float = 0
    var leftCameraAngle: Float = 0
    var leftCameraDisplacement: Float = 0
    var rightCameraAngle: Float = 0
    var rightCameraDisplacement: Float = 0

    override public init(mtkView: MTKView, camera: Camera) {
        super.init(mtkView: mtkView, camera: camera)
    }

    override public func setup (view: MTKView) {
        super.setup(view: view)
        name = "Toon scene"

        sphere = Sphere(mtkView: view, fragmentShader: .fragment_color)
        add(childNode: sphere)
      
        sphere.material.color = float4(1,0,1, 1)
        sphere.position = float3(0,0,0)
        sphere.scale = float3(5)

        //camera.fieldOfView = 25
        camera.set(position: float3(0, 10, -20), viewpoint: float3(0,0,0), up: float3(0,1,0))
    }

    override public func update(deltaTime: Float) {
        super.update(deltaTime: deltaTime)

        cameraRotation += deltaTime * 20
        camera.rotateAroundPoint(distance: 50, viewpoint: float3(0,0, 0), angle: cameraRotation, y: 20)
        
        //camera.updateRotation(angle: leftCameraAngle, displacement: leftCameraDisplacement)
        //camera.updateMovement(deltaTime: deltaTime, angle: rightCameraAngle, displacement: rightCameraDisplacement)
    }
}
