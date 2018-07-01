
import MetalKit

class TorusKnotScene: Scene {

    let torusKnot: TorusKnot

    var cameraRotation: Float = 0

    override init(device: MTLDevice, camera: Camera) {
        torusKnot = TorusKnot(device: device, imageName: "blue-frozen-water.jpg")
        super.init(device: device, camera: camera)
        add(childNode: torusKnot)


        torusKnot.position = float3(3, 2, -18)
        torusKnot.scale = float3(0.8)

        camera.set(position: float3(0,0,0), viewpoint: float3(0,0,1), up: float3(0,1,0))

    }

    override func update(deltaTime: Float) {
        super.update(deltaTime: deltaTime)

        cameraRotation += deltaTime * 10
        camera.rotateAroundPoint(distance: 45, viewpoint: torusKnot.position, angle: cameraRotation, y: 0)

    }
}
