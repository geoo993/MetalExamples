
import MetalKit

public class Pyramid: Primitive {

    override public func setup() {
        super.setup()
        name = String(describing: Pyramid.self)
        drawType = .triangle
        useIndicies = false
    }
    override public func buildVertices() {
        super.buildVertices()

        /////---- 4-------
        ////    . . .  .
        //    .  .   .  .
        //   .  .     .   .
        //  .  .       .    .
        // .   2......... |  /3
        //.              . //
        //0--------------/1
        let size: Float = 1.0

        vertices = [
            //vertices positions                          //texture             //colors
            //bottom 0,2,3  3,1,0
            Vertex( position: float3(  -size,-size,size ), texture: float2(1.0,0.0), color: float4(1, 1, 0, 1), normal: float3( 1.0, 1.0, 1.0 ) ), // 0
            Vertex( position: float3( -size, -size, -size ), texture: float2(1.0,1.0), color: float4(1, 1, 0, 1),normal: float3( 1.0, 1.0, 1.0 ) ), // 1
            Vertex( position: float3( size, -size, -size ), texture: float2(0.0,1.0), color: float4(1, 1, 0, 1),normal: float3( 1.0, 1.0, 1.0 ) ), // 2
            Vertex( position: float3(  size, -size, -size ), texture: float2(0.0,1.0), color: float4(1, 1, 0, 1),normal: float3( 1.0, 1.0, 1.0 ) ), // 3
            Vertex( position: float3( size, -size, size ), texture: float2(0.0,0.0), color: float4(1, 1, 0, 1),normal: float3( 1.0, 1.0, 1.0 ) ), // 4
            Vertex( position: float3( -size, -size, size ), texture: float2(1.0,0.0), color: float4(1, 1, 0, 1),normal: float3( 1.0, 1.0, 1.0 ) ), // 5

            //front   4,0,1
            Vertex( position: float3( 0.0, size, 0.0 ), texture: float2(0.0,1.0), color: float4(1, 0, 0, 1), normal: float3( 1.0, 1.0, 1.0 ) ), // 6
            Vertex( position: float3( -size, -size, size ), texture: float2(0.0,0.0), color: float4(1, 0, 0, 1),normal: float3( 1.0, 1.0, 1.0 ) ), // 7
            Vertex( position: float3(  size, -size,size ), texture: float2(1.0,0.0), color: float4(1, 0, 0, 1),normal: float3(1.0, 1.0, 1.0 ) ), // 8

            //back    4,3,2
            Vertex( position: float3( 0.0, size, 0.0 ), texture: float2(0.0,1.0), color: float4(0, 1, 1, 1), normal: float3( 1.0, 1.0, 1.0) ), // 9
            Vertex( position: float3( size, -size, -size ), texture: float2(0.0,0.0), color: float4(0, 1, 1, 1),normal: float3( 1.0, 1.0, 1.0 ) ), // 10
            Vertex( position: float3( -size, -size, -size ), texture: float2(1.0,0.0), color: float4(0, 1, 1, 1),normal: float3( 1.0, 1.0, 1.0 ) ), // 11

            //left   4,2,0
            Vertex( position: float3( 0.0, size, 0.0 ), texture: float2(0.0,1.0), color: float4(0, 0, 1, 1), normal: float3( 1.0, 1.0, 1.0) ), // 9
            Vertex( position: float3( -size, -size, -size ), texture: float2(0.0,0.0), color: float4(0, 0, 1, 1), normal: float3( 1.0, 1.0, 1.0 ) ), // 10
            Vertex( position: float3( -size, -size, size ), texture: float2(1.0,0.0), color: float4(0, 0, 1, 1), normal: float3( 1.0, 1.0, 1.0 ) ), // 11

            //right  4,1,3
            Vertex( position: float3( 0.0, size, 0.0 ), texture: float2(0.0,1.0), color: float4(1, 0, 1, 1), normal: float3( 1.0, 1.0, 1.0) ), // 9
            Vertex( position: float3( size, -size, size ), texture: float2(0.0,0.0), color: float4(1, 0, 1, 1), normal: float3( 1.0, 1.0, 1.0 ) ), // 10
            Vertex( position: float3( size, -size, -size ), texture: float2(1.0,0.0), color: float4(1, 0, 1, 1), normal: float3( 1.0, 1.0, 1.0 ) ), // 11

        ]
    }
}
