import MetalKit

class Scene: Node {
    var device: MTLDevice
    var time: Float
    var camera: Camera
    var light = Light()

    init(device: MTLDevice, camera: Camera) {

        //1) Create a reference to the GPU, which is the Device
        self.device = device
        self.time = 0
        self.camera = camera
        super.init()
    }

    func update(deltaTime: Float) {
        self.time += deltaTime
    }

    func sceneSizeWillChange(to size: CGSize) {
        camera.setPerspectiveProjectionMatrix(screenSize: size)
    }

    func touchesBegan(_ view: UIView, touches: Set<UITouch>, with event: UIEvent?) {}
    func touchesMoved(_ view: UIView, touches: Set<UITouch>, with event: UIEvent?) {}
    func touchesEnded(_ view: UIView, touches: Set<UITouch>, with event: UIEvent?) {}
    func touchesCancelled(_ view: UIView, touches: Set<UITouch>, with event: UIEvent?) {}

    func render(commandEncoder: MTLRenderCommandEncoder, deltaTime: Float) {
        update(deltaTime: deltaTime)

        commandEncoder.setFragmentBytes(&light, length: MemoryLayout<Light>.stride, index: 3)

        for child in children {
            child.render(commandEncoder: commandEncoder,
                         parentModelMatrix: matrix_identity_float4x4,
                         camera: camera)
        }
    }
}
