import MetalKit
import AppCore

class Primitive: Node {

    var useIndicies: Bool = true

    var vertices: [Vertex] = [
    ]

    var indices: [UInt16] = [
    ]

    // buffer for verices
    var vertexBuffer: MTLBuffer?

    // buffer for indices
    var indexBuffer: MTLBuffer?


    // there will be a lot of occasion when you want to pass data to the GPU,
    // you might want to send constant values to the GPU, to do this we can create a struct to hold
    // the values that the GPU will then apply to all the vertices.
    var uniform = Uniform()

    // how to draw the object
    var drawType: MTLPrimitiveType = .triangle

    //MARK: - Renderable
    var pipelineState: MTLRenderPipelineState!
    var samplerState: MTLSamplerState!
    var depthStencilState: MTLDepthStencilState!
    var vertexFunctionName: VertexFunction = .vertex_shader
    var fragmentFunctionName: FragmentFunction = .fragment_shader

    var vertexDescriptor: MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()
        // describe the position data from Vertex struct
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0 // buffer index of vertex array

        // describe the texture data
        vertexDescriptor.attributes[1].format = .float2
        vertexDescriptor.attributes[1].offset = MemoryLayout<float3>.stride // float3 offset from the first attribute as we are striding, this is the size of the position attribute
        vertexDescriptor.attributes[1].bufferIndex = 0 // buffer index of vertex array still at 0

        // describe the color data from Vertex struct
        vertexDescriptor.attributes[2].format = .float4
        vertexDescriptor.attributes[2].offset = MemoryLayout<float3>.stride + MemoryLayout<float2>.stride // float3 and float2 offset from the first and second attribute as we are striding, this was the size of the position and texture attribute
        vertexDescriptor.attributes[2].bufferIndex = 0 // buffer index of vertex array

        // describe the normal data from Vertex struct
        vertexDescriptor.attributes[3].format = .float3
        vertexDescriptor.attributes[3].offset = MemoryLayout<float3>.stride + MemoryLayout<float2>.stride + MemoryLayout<float4>.stride // float3 and float2 offset from the first and second attribute as we are striding, this was the size of the position and texture attribute
        vertexDescriptor.attributes[3].bufferIndex = 0 // buffer index of vertex array

        // tell the vertex descriptor the size of the information held for each vertex
        vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.stride

        return vertexDescriptor
    }

    //MARK: - Texturable
    var texture: MTLTexture?
    var maskTexture: MTLTexture?


    //MARK: - initialise the Renderer with a device
    init(device: MTLDevice, fragmentShader: FragmentFunction = .fragment_shader) {
        super.init()
        self.fragmentFunctionName = fragmentShader
        setup()
        buildVertices()
        buildBuffers(device: device)
        pipelineState = buildPipelineState(device: device)
        samplerState = buildSamplerState(device: device)
        depthStencilState = buildDepthStencilState(device: device)
    }

    init(device: MTLDevice, imageName: String, fragmentShader: FragmentFunction) {
        super.init()
        setup()
        buildVertices()
        if let texture = setTexture(device: device, imageName: imageName) {
            self.texture = texture
            self.fragmentFunctionName = fragmentShader
        }

        buildBuffers(device: device)
        pipelineState = buildPipelineState(device: device)
        samplerState = buildSamplerState(device: device)
        depthStencilState = buildDepthStencilState(device: device)
    }

    init(device: MTLDevice, imageName: String, maskImageName: String) {
        super.init()
        setup()
        buildVertices()
        if let texture = setTexture(device: device, imageName: imageName) {
            self.texture = texture
        }
        if let maskTexture = setTexture(device: device, imageName: maskImageName) {
            self.maskTexture = maskTexture
            fragmentFunctionName = .fragment_textured_mask_shader
        }
        buildBuffers(device: device)
        pipelineState = buildPipelineState(device: device)
        samplerState = buildSamplerState(device: device)
        depthStencilState = buildDepthStencilState(device: device)
    }


    // MARK: - create metal buffer that holds the vertices and indices from the vertices and indices array
    private func buildBuffers(device: MTLDevice) {
        // size vs stride. I may not have made the difference clear enough in the videos, so thank you for bringing this up.
        //Take a look at https://developer.apple.com/reference/swift/memorylayout
        //In buildBuffers(), you have MemoryLayout<Vertex>.size. This makes the buffer count * 40,
        // whereas the amount Vertex takes up in memory is actually 48 because of internal padding and alignment.
        // to know more about size, stride and allignment visit https://stackoverflow.com/questions/24662864/swift-how-to-use-sizeof

        if useIndicies {
            vertexBuffer = device.makeBuffer(bytes: vertices,
                                             length: vertices.count * MemoryLayout<Vertex>.stride,
                                             options: [])

            indexBuffer = device.makeBuffer(bytes: indices,
                                            length: indices.count * MemoryLayout<UInt16>.size,
                                            options: [])
        } else {

            vertexBuffer = device.makeBuffer(bytes: vertices,
                                             length: vertices.count * MemoryLayout<Vertex>.stride,
                                             options: [])
        }
    }

    func setup() {

    }

    func buildVertices() {

    }
}

extension Primitive: Renderable {
    func doRender(commandEncoder: MTLRenderCommandEncoder,
                  modelMatrix: matrix_float4x4,
                  camera: Camera) {

        //4) setup the state and send the vertex buffer to the GPU and the the GPU to draw those vertices
        // The pipeline state will tell the GPU what shader function to use.
        // It is possible that you will need to use different shader functions for different objects that you render,
        // so you may need to setup multiple pipelines, which will mean that you will need to send the GPU
        // multiple commands each with its own command encoder.
        commandEncoder.setRenderPipelineState(pipelineState)

        commandEncoder.setFragmentSamplerState(samplerState, index: 0)


        // if we want to render face that are facing towards by using something called backface culling
        // we can tell the render command encoder to CULL back faces, but we also need to tell the command encoder
        // which way our traingles are facing. any tringles with its vertices in clockwise order is facing away from us.
        // we can tell the comand encoder that the triangles verices are in counter clockwise order by specifying the front facing.
        // The technical term of this order is the winding of the triangle.
        commandEncoder.setFrontFacing(.counterClockwise)

        // we then set the cull mode to be back. this means that any triangle that are rendered clockwise
        // are going to be culled. The standard winding order for 3D obj format models is counter clockwise.
        // but the ⚠️ default by metal is clockwise.
        // so when we set backface culling on we almost always have to specify the winding order as counter clockwise.
        commandEncoder.setCullMode(.back)


        // before doing the draw call we set the command encoder depth stencil state
        commandEncoder.setDepthStencilState(depthStencilState)

        
        //5) we then tell the GPU to use our vertex buffer, the offset is the starting byte.
        // you can see that if we had more complex buffers, we can tell the offset to start somewhere else in the buffer.
        // internaly, there is an index table of buffer and the at index specifies whihc entry in the table
        // the buffer is at. you can have up to 31 buffers.
        // the vertex information is in the metal buffer at zero (0), so the GPU can tie the index information
        // with the vertex information
        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)



        // 6)
        // Instead of creating and sending a metal buffer as we did for the vertices and indices,
        // we can directly send the address of the constant struct by using set vertex byte.
        // as long as the data is less than 4000 bytes, then we do not have to create new metal buffers.
        // metal can manage the buffer for us.
        // As well as telling the GPU what the address of the struct is (Constant), we tell it how long
        // the struct is using stride, and allocate a buffer index number just as we did when we created
        // the metal vertex buffer.

        // setting the matrices attributes
        // projection matrix
        // the projecttion matrix will project all the vertices back into clipping space
        uniform.projectionMatrix = camera.perspectiveProjectionMatrix

        // view matrix
        uniform.viewMatrix = camera.viewMatrix

        // model matrix
        uniform.modelMatrix = modelMatrix

        // normal matrix
        uniform.normalMatrix =
            //(camera.viewMatrix * modelMatrix).upperLeft3x3()
            camera.computeNormalMatrix(modelMatrix: modelMatrix)

        commandEncoder.setVertexBytes(&uniform,
                                      length: MemoryLayout<Uniform>.stride,
                                      index: 1)

        commandEncoder.setFragmentBytes(&material, length: MemoryLayout<MaterialInfo>.stride, index: 4)
        
        // tell the command encoder to set the fragment texture at the fragment index buffer 0
        if texture != nil {
            commandEncoder.setFragmentTexture(texture, index: 0)
        }

        // set the mask texture's fragment buffer to buffer index 1:
        if maskTexture != nil {
            commandEncoder.setFragmentTexture(maskTexture, index: 1)
        }

        if useIndicies {
             guard let indexBuffer = indexBuffer else { return }
            //6b) we change the draw command to teel the GPU that we are now using the index order
            commandEncoder.drawIndexedPrimitives(type: drawType,
                                                 indexCount: indices.count,
                                                 indexType: .uint16,
                                                 indexBuffer: indexBuffer,
                                                 indexBufferOffset: 0)

            
        } else {
            //6a) finally we setup to draw, we specify that we are drawing a triangle primitive rather than a point or a line.
            // remember that we are setting a list of commands to the command encoder that get sent off in a batch
            // to the GPU, it is not until the commit at the end of the methods that we finish drawing or object.
            commandEncoder.drawPrimitives(type: drawType,
                                          vertexStart: 0,
                                          vertexCount: vertices.count)
        }


    }

}


extension Primitive: Texturable {
}


