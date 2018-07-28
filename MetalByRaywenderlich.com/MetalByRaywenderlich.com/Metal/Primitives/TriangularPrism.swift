
import MetalKit
import AppCore

class TriangularPrism: Primitive {

    override func setup() {
        super.setup()
        useIndicies = true
        name = String(describing: TriangularPrism.self)
    }

    override func buildVertices() {
        super.buildVertices()

        /////////2//////////
        ///////. | ./////
        //   .   |    .//
        // .     |      .//
        //0--------------/1
        //|      |      |//
        //|      |      |//
        //|      |      |//
        //|      5       |//
        //|    .   .    |//
        //|  .       .  |//
        //|.            .|//
        //3/////////////4
        let size: Float = 1.0

        vertices = [
            //vertices positions                          //texture             //colors
            Vertex( position: float3(  -size, (size * 2.0) , size ), texture: float2(0.0,1.0), color: float4(1,0,1,1), normal: float3( 0.0, 0.0, 1.0 ) ), // 0
            Vertex( position: float3( size, (size * 2.0), size ), texture: float2(1.0,1.0), color: float4(0,0,1,1),normal: float3( 0.0, 1.0, 0.0 ) ), // 1
            Vertex( position: float3( 0.0, (size * 2.0), -size ), texture: float2(0.5,1.0), color: float4(1,1,0,1),normal: float3( 1.0, 1.0, 0.0 ) ), // 2
            Vertex( position: float3(  -size, -(size * 2.0), size ), texture: float2(0.0,0.0), color: float4(0,1,1,1), normal: float3( 1.0, 0.0, 1.0 ) ), // 3
            Vertex( position: float3( size, -(size * 2.0), size ), texture: float2(1.0,0.0), color: float4(1,0,0,1), normal: float3( 1.0, 0.0, 0.0 ) ), // 4
            Vertex( position: float3( 0.0, -(size * 2.0), -size ), texture: float2(0.5,1.0), color: float4(1,1,1,1), normal: float3( 0.0, 1.0, 1.0 ) ), // 5
        ]

        indices = [
            //top
            0,1,2,
            //bottom
            3,4,5,
            //front
            4,1,0,
            0,3,4,
            //right
            5,2,1,
            1,4,5,
            //left
            3,0,2,
            2,5,3,
        ]
    }
}
