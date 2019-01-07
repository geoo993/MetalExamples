
import MetalKit

public class Icosahedron: Primitive {

    override public func setup() {
        super.setup()
        name = String(describing: Icosahedron.self)
        useIndicies = true
    }

    override public func buildVertices() {
        super.buildVertices()

        let theta: Float = 26.56505117707799 * Float.pi / 180.0

        let stheta = sin(theta);
        let ctheta = cos(theta);
        let lowerVertex = Vertex(position: float3(0.0, 0.0, -1.0), texture: float2(0.0,0.0), color: float4( 1, 1, 1, 1), normal: float3( 1.0, 1.0, 0.0))
        vertices.append(lowerVertex) // the lower vertex

        // the lower pentagon
        var phi: Float = Float.pi / 5.0
        for _ in 1..<6 {
            let vertex = Vertex(position: float3(ctheta * cos(phi), ctheta * sin(phi), -stheta),
                                texture: float2(0.0,0.0),
                                color: float4(1,0,1,1),
                                normal: float3( 0.0, 1.0, 1.0 ) )

            vertices.append(vertex)
            phi += 2.0 * Float.pi / 5.0
        }

        // the upper pentagon
        phi = 0.0
        for _ in 6..<11 {
            let vertex = Vertex(position: float3(ctheta * cos(phi), ctheta * sin(phi), stheta),
                                texture: float2(0.0, 0.0),
                                color: float4(1, 0, 0, 1),
                                normal: float3( 1.0, 0.0, 1.0) )

            vertices.append(vertex)
            phi += 2.0 * Float.pi / 5.0
        }

        let vertex = Vertex(position: float3(0.0, 0.0, 1.0), texture: float2(0.0, 0.0), color: float4(0, 1, 0, 1), normal: float3( 0.0, 1.0, 0.0 ) )
        vertices.append(vertex)

        indices = [
            0, 2, 1,
            0, 3, 2,
            0, 4, 3,

            0, 5, 4,
            0, 1, 5,
            1, 2, 7,
            2, 3, 8,
            3, 4, 9,
            4, 5, 10,
            5, 1, 6,
            1, 7, 6,
            2, 8, 7,
            3, 9, 8,
            4, 10, 9,
            5, 6, 10,
            6, 7, 11,
            7, 8, 11,
            8, 9, 11,
            9, 10, 11,
            10, 6, 11,
        ]
        
    }
}
