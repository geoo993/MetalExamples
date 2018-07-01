
import MetalKit
import AppCore

class Cone: Primitive {

    override func setup() {
        super.setup()
        useIndicies = false
        drawType = .triangle
        name = String(describing: Cone.self)
    }

    override func buildVertices() {
        super.buildVertices()


        let height: Float = 2.0
        let radius: Float = 1.0
        let numSegments = 40

        let bottomVertex = Vertex(position: float3(0,0,0), texture: float2(0, 1), color: float4(0, 1, 0, 1), normal: float3(1, 0, 0) )  // bottom vertex
        vertices.append(bottomVertex)

        for segment in 0...numSegments //use the second vertex twice
        {
            let angle = 2.0 * Float.pi * (Float(segment) / Float(numSegments)) //angle in radians
            let vertex = Vertex(position: float3( radius * sin(angle), 0.0, radius * cos(angle)),
                                texture: float2(0, 1),
                                color: float4(0,1,1,1), normal: float3(0, 1, 1))
            vertices.append(vertex)
        }

        let topVertex = Vertex(position: float3(0, height, 0), texture: float2(0, 1), color: float4(0, 1, 0, 1), normal: float3(0, 0, 1) )  // top vertex
        vertices.append(topVertex)

        for segment in (0...numSegments).reversed()
        {
            let angle = 2.0 * Float.pi * (Float(segment) / Float(numSegments)); //angle in radians
            let vertex = Vertex(position: float3( radius * sin(angle), 0.0, radius * cos(angle)),
                                texture: float2(0, 1),
                                color: float4(1,1,0,1), normal: float3(1, 0, 1))
            vertices.append(vertex)
        }

    }

}
