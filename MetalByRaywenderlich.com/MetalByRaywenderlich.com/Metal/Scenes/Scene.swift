import MetalKit

class Scene: Node {
    var device: MTLDevice
    var time: Float
    var camera: Camera
    var light = LightInfo()
    var dirLights = [DirectionalLight]()
    var pointLights = [PointLight]()
    var spotLights = [SpotLight]()
    var cameraInfo = CameraInfo()

    init(device: MTLDevice, camera: Camera) {

        //1) Create a reference to the GPU, which is the Device
        self.device = device
        self.time = 0
        self.camera = camera
        super.init()
    }

    func update(deltaTime: Float) {
        

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

        self.cameraInfo.position = camera.position
        self.cameraInfo.view = camera.view
        self.cameraInfo.front = camera.front
        commandEncoder.setFragmentBytes(&cameraInfo, length: MemoryLayout<CameraInfo>.stride, index: 3)

        commandEncoder.setFragmentBytes(&light, length: MemoryLayout<LightInfo>.stride, index: 5)
        commandEncoder.setFragmentBytes(&dirLights, length: MemoryLayout<DirectionalLight>.stride, index: 6)
        commandEncoder.setFragmentBytes(&pointLights, length: MemoryLayout<PointLight>.stride, index: 7)
        commandEncoder.setFragmentBytes(&spotLights, length: MemoryLayout<SpotLight>.stride, index: 8)

        for child in children {
            child.render(commandEncoder: commandEncoder,
                         parentModelMatrix: matrix_identity_float4x4,
                         camera: camera)
        }
    }
}
