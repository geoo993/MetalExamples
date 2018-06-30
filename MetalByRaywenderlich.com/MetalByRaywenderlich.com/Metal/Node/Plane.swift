import MetalKit
import AppCore

class Plane: Primitive {

    override func buildVertices() {
        super.buildVertices()
        // vertices drawn anti-clockwise
        //2--------------1
        //               |
        //               |
        //               |
        //               |
        //               |
        //               |
        //3--------------/0
        vertices = [
            Vertex(position: float3( -1, 1, 0), texture: float2(0, 1), color: float4(1, 0, 0, 1)),// 2  top left
            Vertex(position: float3( -1, -1, 0), texture: float2(0, 0), color: float4(0, 1, 0, 1)), // 3  bottom left
            Vertex(position: float3( 1, -1, 0), texture: float2(1, 0), color: float4(0, 0, 1, 1)), // 0   bottom right
            Vertex(position: float3( 1, 1, 0), texture: float2(1, 1), color: float4(1, 0, 1, 1)) // 1   top right
        ]

        // the indices describe the two triangles and the order that we want to render the vertice
        indices = [
            0, 1, 2,
            2, 3, 0
        ]

    }

    init(device: MTLDevice, name: String, imageName: String) {
        super.init(device: device, name: name, imageName: imageName)
    }
}


