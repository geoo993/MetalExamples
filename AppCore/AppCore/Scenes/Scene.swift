import MetalKit

open class Scene: Node {
    
    public var rootNode: Node!
    public var camera: Camera!
    public var time: Float = 0
    public var toonEdge: Float = 0
    public var fireBallFreq: Float = 0
    public var fireBallExplo: Float = 0

    private let sceneOrigin = matrix_identity_float4x4

    public var dirLights = [DirectionalLight]()
    public let directionalLightsDirections: [float3] = [
        float3(  -0.2, -1.0, -0.3)
    ]

    public var pointLights = [PointLight]()
    public var pointLightPositions: [float3] = [
        float3(  -4.0,  2.0, -12.0    ),
        float3(  -5.7,  6.2,  2.0      ),
        float3(  1.0,  3.0,  -2.0      ),
        float3(  2.3, -3.3, -4.0      ),
        float3(  10.0,  0.0, -3.0     )
    ]

    public var pointlightsColours: [float3] = [
        float3(0.6, 0.1, 0.25),
        float3(0.2, 0.7, 0.9),
        float3(1.0, 0.9, 0.0),
        float3(0.05, 0.1, 0.9),
        float3(0.34, 0.75, 0.2),
    ]
    public var spotLights = [SpotLight]()

    public init(mtkView: MTKView, camera: Camera) {

        //1) Create a reference to the GPU, which is the Device
        super.init(name: "Untitled")
        rootNode = Node(name: "Root")
        add(childNode: rootNode)
        self.camera = camera
        setup(view: mtkView)
    }

    open override func add(childNode: Node) {
        super.add(childNode: childNode)
    }

    open func setup(view: MTKView) {

    }

    open func update(deltaTime: Float) {
        
    }

    open func sceneSizeWillChange(to size: CGSize) {
        camera.setPerspectiveProjectionMatrix(screenSize: size)
    }

    open func touchesBegan(_ view: UIView, touches: Set<UITouch>, with event: UIEvent?) {}
    open func touchesMoved(_ view: UIView, touches: Set<UITouch>, with event: UIEvent?) {}
    open func touchesEnded(_ view: UIView, touches: Set<UITouch>, with event: UIEvent?) {}
    open func touchesCancelled(_ view: UIView, touches: Set<UITouch>, with event: UIEvent?) {}
    open func onSlider(_ type: SliderType, phase: UITouch.Phase, value: Float) {}

    open func render(commandEncoder: MTLRenderCommandEncoder, deltaTime: Float) {
        update(deltaTime: deltaTime)

        // Constants
        var constants = Constants(time: time)
        commandEncoder.setVertexBytes(&constants,
                                      length: MemoryLayout<Constants>.stride,
                                      index: BufferIndex.constants.rawValue)

        // Lights
        // https://stackoverflow.com/questions/47009558/metal-compute-shader-with-1d-data-buffer-in-and-out
        commandEncoder.setFragmentBytes(&dirLights, length: MemoryLayout<DirectionalLight>.stride * dirLights.count,
            index: BufferIndex.directionalLightInfo.rawValue)

        commandEncoder.setFragmentBytes(&pointLights, length: MemoryLayout<PointLight>.stride * pointLights.count,
                                        index: BufferIndex.pointLightInfo.rawValue)

        commandEncoder.setFragmentBytes(&spotLights, length: MemoryLayout<SpotLight>.stride * spotLights.count,
                                        index: BufferIndex.spotLightInfo.rawValue)

        // toon edge
        commandEncoder.setFragmentBytes(&toonEdge, length: MemoryLayout<ToonConstants>.stride,
                                        index: BufferIndex.toon.rawValue)

        // fire ball edge
        var fireBallConstant = FireBallConstants(time: time * 0.2, frequency: fireBallFreq, explosion: fireBallExplo)
        commandEncoder.setVertexBytes(&fireBallConstant, length: MemoryLayout<FireBallConstants>.stride,
                                      index: BufferIndex.fireBall.rawValue)

        // Camera
        var cameraInfo = CameraInfo(position: camera.position, front: camera.front)
        commandEncoder.setFragmentBytes(&cameraInfo, length: MemoryLayout<CameraInfo>.stride,
                                        index: BufferIndex.cameraInfo.rawValue)
        for child in children {
            child.render(commandEncoder: commandEncoder,
                         parentModelMatrix: sceneOrigin,
                         camera: camera)
        }
    }

    open func nodeNamed(_ name: String) -> Node? {
        if rootNode.name == name {
            return rootNode
        } else {
            return rootNode.get(childNode: name)
        }
    }

}

public extension Scene {

    public func createDirectionalLight(color: float3, direction: float3) -> DirectionalLight {
        // Directional light
        var base = BaseLight()
        base.color = color
        base.ambient = 0.05
        base.diffuse = 0.4
        base.specular = 0.5
        return DirectionalLight(base: base, direction: direction)
    }

    public func createPointLight(view: MTKView, name: String, color: float3, position: float3, intensity: Float)
        -> (object: Primitive, light:PointLight) {
            // Point Light
            let light = Cube(mtkView: view, fragmentShader: .fragment_color)
            light.name = name
            light.position = position
            light.scale = float3(0.2, 0.2, 0.2)
            light.material.color = float4(color.x, color.y, color.z, 1.0)
            light.material.useTexture = true

            var pointLight = PointLight()
            pointLight.position = position
            pointLight.base.color = color
            pointLight.base.intensity = intensity
            pointLight.base.ambient = 0.1
            pointLight.base.diffuse = 0.7
            pointLight.base.specular = 0.9
            pointLight.atten.continual = 1.0
            pointLight.atten.linear = 0.09
            pointLight.atten.exponent = 0.032

            return (light, pointLight)
    }

    public func createSpotLight(view: MTKView, color: float3, position: float3, cutoff: Float, outerCutoff: Float) -> SpotLight {

        //Spot Light
        var spotLight = SpotLight()
        spotLight.pointLight.position = position
        spotLight.pointLight.base.color = color
        spotLight.pointLight.base.ambient = 0.1
        spotLight.pointLight.base.diffuse = 1.0
        spotLight.pointLight.base.specular = 1.0
        spotLight.pointLight.atten.continual = 1.0
        spotLight.pointLight.atten.linear = 0.09
        spotLight.pointLight.atten.exponent = 0.32
        spotLight.direction = float3(-2, 0, 0)
        spotLight.cutOff = cos(radians(degrees: cutoff))
        spotLight.outerCutOff = cos(radians(degrees: outerCutoff))
        return spotLight
    }
}
