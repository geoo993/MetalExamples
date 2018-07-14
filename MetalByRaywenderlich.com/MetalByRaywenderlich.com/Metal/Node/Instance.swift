
import MetalKit

// if we are using a model multiple times within our scene, we can use instancing to load the model once,
// but have different instances of the mesh with differen positions in the scene.
// Instancing is much more efficient on resources.
// When using models with high number of vertices and if you wanted to have many instances of
// this model rendered, it would be quite expesive operation and instancing can help with this.
// instancing allow us to only use vertice of one model and create multiple intances of that model using
// it vertices. This process will allow us to reduce the memory footprint and CPU usage
/// significantly as we are only using vertice of one instance of the model.

class Instance: Node {

    // Mark: - properties
    var model: Model
    var nodes = [Node]()
    var instances = [InstanceInfo]()

    // create a MetalBuffer and store the object instances in that buffer
    var instanceBuffer: MTLBuffer?

    //MARK: - Renderable
    var pipelineState: MTLRenderPipelineState!
    var samplerState: MTLSamplerState!
    var depthStencilState: MTLDepthStencilState!
    var vertexFunctionName: VertexFunction = .vertex_instance_shader
    var fragmentFunctionName: FragmentFunction

    var vertexDescriptor: MTLVertexDescriptor
    var uniform = Uniform()

    var drawType: MTLPrimitiveType = .triangle

    //Mark: - initialiser
    init(device: MTLDevice, modelName: String, instances: Int, fragmentShader: FragmentFunction) {
        model = Model(device: device, modelName: modelName, fragmentShader: fragmentShader)
        fragmentFunctionName = model.fragmentFunctionName
        vertexDescriptor = model.vertexDescriptor
        super.init()
        name = modelName
        create(instances: instances)
        makeBuffer(device: device)
        pipelineState = buildPipelineState(device: device)
        samplerState = buildSamplerState(device: device)
        depthStencilState = buildDepthStencilState(device: device)
    }

    //Mark: - creates instances
    func create(instances: Int) {
        for i in 0..<instances {
            let node = Node()
            node.name = "Instance \(i)"
            self.nodes.append(node)
            self.instances.append(InstanceInfo())
        }
    }

    func remove(instance: Int) {
        self.nodes.remove(at: instance)
        self.instances.remove(at: instance)
    }

    func makeBuffer(device: MTLDevice) {
        self.instanceBuffer = device
            .makeBuffer(length: instances.count * MemoryLayout<InstanceInfo>.stride , options: [])
        self.instanceBuffer?.label = "Instance Buffer"
    }

}

extension Instance: Renderable {

    func doRender(commandEncoder: MTLRenderCommandEncoder, modelMatrix: matrix_float4x4, camera: Camera) {
        guard let instanceBuffer = instanceBuffer, nodes.count > 0 else { return }

        commandEncoder.setRenderPipelineState(pipelineState)
        commandEncoder.setFragmentSamplerState(samplerState, index: 0)

        commandEncoder.setFrontFacing(.counterClockwise)
        commandEncoder.setCullMode(.back)
        commandEncoder.setDepthStencilState(depthStencilState)


        // we need to update each instance in the buffer at every draw
        var pointer = instanceBuffer.contents().bindMemory(to: InstanceInfo.self, capacity: nodes.count)

        for node in nodes {
            // setup the matrices attributes
            let modelMatrix = matrix_multiply(modelMatrix, node.modelMatrix)
            pointer.pointee.uniform.projectionMatrix = camera.perspectiveProjectionMatrix
            pointer.pointee.uniform.viewMatrix = camera.viewMatrix
            pointer.pointee.uniform.modelMatrix = modelMatrix
            pointer.pointee.uniform.normalMatrix =
                //(camera.viewMatrix * modelMatrix).upperLeft3x3()
                camera.computeNormalMatrix(modelMatrix: modelMatrix)
            pointer.pointee.material = node.material

            pointer = pointer.advanced(by: 1)
        }

        commandEncoder.setFragmentBytes(&material, length: MemoryLayout<MaterialInfo>.stride, index: 4)

        if model.texture != nil {
            commandEncoder.setFragmentTexture(model.texture, index: 0)
        }

        commandEncoder.setVertexBuffer(instanceBuffer, offset: 0, index: 1)

        guard let meshes = model.meshes as? [MTKMesh], meshes.count > 0 else { return }

        // Each MLKMesh will have one or more sub meshes with the index information.
        // To render the object we loop through MetalKit meshes, we get the VertexBuffer from the mesh
        // and set that as the GPU vertex buffer.
        for mesh in meshes {
            let vertexBuffer = mesh.vertexBuffers[0]
            commandEncoder.setVertexBuffer(vertexBuffer.buffer, offset: vertexBuffer.offset, index: 0)

            // then we loop through the MTLMesh sub meshes, and draw the group of meshes that belongs to the MTLMesh
            // using the submesh indicies.
            for submesh in mesh.submeshes {
                model.drawType = submesh.primitiveType
                commandEncoder.drawIndexedPrimitives(type: submesh.primitiveType,
                                                     indexCount: submesh.indexCount,
                                                     indexType: submesh.indexType,
                                                     indexBuffer: submesh.indexBuffer.buffer,
                                                     indexBufferOffset: submesh.indexBuffer.offset,
                                                     instanceCount: nodes.count)
            }
        }

    }


}
