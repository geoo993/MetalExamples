import MetalKit

class Plane: Node {
    // vertices drawn anti-clockwise
    var vertices: [Float] = [
        -1,  1, 0,   // V0  top left
        -1, -1, 0,   // V1  bottom left
        1, -1, 0,   // V2   bottom right
        //1, -1, 0,   // V2   bottom right
        1,  1, 0,   // V3   top right
        //-1,  1, 0    // V0  top left
    ]

    // the indices describe the two triangles and the order that we want to render the vertice
    var indices: [UInt16] = [
        0, 1, 2,
        2, 3, 0
    ]

    // buffer for verices
    var vertexBuffer: MTLBuffer?

    // buffer for indices
    var indexBuffer: MTLBuffer?
    

    // there will be a lot of occasion when you want to pass data to the GPU,
    // you might want to send constant values to the GPU, to do this we can create a struct to hold
    // the values that the GPU will then apply to all the vertices.
    struct Constants {
        var animateBy: Float = 0
    }
    var constants = Constants()
    var time: Float = 0

    //MARK: - initialise the Renderer with a device
    init(device: MTLDevice) {
        super.init()
        buildBuffers(device: device)
    }

    // MARK: - create metal buffer that holds the vertices and indices from the vertices and indices array
   private func buildBuffers(device: MTLDevice) {
        vertexBuffer = device.makeBuffer(bytes: vertices,
                                         length: vertices.count * MemoryLayout<Float>.size,
                                         options: [])
        indexBuffer = device.makeBuffer(bytes: indices,
                                        length: indices.count * MemoryLayout<UInt16>.size,
                                        options: [])
    }

  override func render(commandEncoder: MTLRenderCommandEncoder,
                       deltaTime: Float) {
    super.render(commandEncoder: commandEncoder,
                 deltaTime: deltaTime)
    guard let indexBuffer = indexBuffer else { return }


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
    time += deltaTime
    let animateBy = abs(sin(time)/2 + 0.5) // sin values are between 1 and -1
    constants.animateBy = animateBy
    commandEncoder.setVertexBytes(&constants, length: MemoryLayout<Constants>.stride, index: 1)


    //6a) finally we setup to draw, we specify that we are drawing a triangle primitive rather than a point or a line.
    // remember that we are setting a list of commands to the command encoder that get sent off in a batch
    // to the GPU, it is not until the commit at the end of the methods that we finish drawing or object.
    //commandEncoder.drawPrimitives(type: MTLPrimitiveType.triangle,
    //                              vertexStart: 0, vertexCount: vertices.count)

    //6b) we change the draw command to teel the GPU that we are now using the index order
    commandEncoder.drawIndexedPrimitives(type: .triangle, indexCount: indices.count,
                                         indexType: .uint16, indexBuffer: indexBuffer,
                                         indexBufferOffset: 0)
  }

  

}

