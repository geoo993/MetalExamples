import MetalKit

class Scene: Node {
    var camera: Camera!
    var time: Float = 0
    var dirLights = [DirectionalLight]()
    var pointLights = [PointLight]()
    var spotLights = [SpotLight]()
    var cameraInfo = CameraInfo()

    init(mtkView: MTKView, camera: Camera) {

        //1) Create a reference to the GPU, which is the Device
        super.init(name: "Untitled")
        self.camera = camera
        setup(view: mtkView)
    }

    override func add(childNode: Node) {
        super.add(childNode: childNode)
    }

    func setup(view: MTKView) {

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
    func onSlider(_ type: SliderType, phase: UITouchPhase, value: Float) {}

    func render(commandEncoder: MTLRenderCommandEncoder, deltaTime: Float) {
        update(deltaTime: deltaTime)

        self.cameraInfo.position = camera.position
        self.cameraInfo.front = camera.front
        commandEncoder.setFragmentBytes(&cameraInfo, length: MemoryLayout<CameraInfo>.stride,
                                        index: BufferIndex.cameraInfo.rawValue)
        commandEncoder.setFragmentBytes(&dirLights, length: MemoryLayout<DirectionalLight>.stride,
                                        index: BufferIndex.directionalLightInfo.rawValue)
        commandEncoder.setFragmentBytes(&pointLights, length: MemoryLayout<PointLight>.stride,
                                        index: BufferIndex.pointLightInfo.rawValue)
        commandEncoder.setFragmentBytes(&spotLights, length: MemoryLayout<SpotLight>.stride,
                                        index: BufferIndex.spotLightInfo.rawValue)

        for child in children {
            child.render(commandEncoder: commandEncoder,
                         parentModelMatrix: matrix_identity_float4x4,
                         camera: camera)
        }
    }
}
