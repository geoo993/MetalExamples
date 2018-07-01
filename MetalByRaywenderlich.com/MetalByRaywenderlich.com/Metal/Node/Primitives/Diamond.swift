
import MetalKit
import AppCore

class Diamond: Primitive {

    override func setup() {
        super.setup()
        name = String(describing: Diamond.self)
        useIndicies = true
    }

    override func buildVertices() {
        super.buildVertices()

        /////---- 4-------
        ////    . . .  .
        //    .  .   .  .
        //   .  .     .   .
        //  .  .       .    .
        // .  2.......... |  /3
        //.  .            . . //
        //0--------------/1
        // . .        . . //
        ////. .      . .  //
        /////. .    .  ////
        ///////.. . .///
        //////// 5//
        /////////////////
        let size: Float = 1.0
        vertices = [
            //vertices positions                          //texture             //colors
            Vertex( position: float3(  -(size/2), 0.0, (size/2)), texture: float2(0.0,0.0), color: float4(1,0,1,1), normal: float3( 0.0, 0.0, 1.0 ) ), // 0
            Vertex( position: float3( (size/2), 0.0, (size/2)), texture: float2(1.0,0.0), color: float4(0,0,1,1),normal: float3( 0.0, 0.0, 0.0 ) ), // 1
            Vertex( position: float3( -(size/2), 0.0, -(size/2) ), texture: float2(0.0,0.0), color: float4(1,0,0,1),normal: float3( 1.0, 1.0, 1.0 ) ), // 2
            Vertex( position: float3(  (size/2), 0.0, -(size/2) ), texture: float2(1.0,0.0), color: float4(0,1,1,1), normal: float3( 1.0, 0.0, 1.0 ) ), // 3
            Vertex( position: float3( 0.0, size, 0.0 ), texture: float2(0.5, 1.0), color: float4(1,0,0,1), normal: float3( 1.0, 1.0, 0.0 ) ), // 4
            Vertex( position: float3( 0.0, -size, 0.0 ), texture: float2(0.5, 0.0), color: float4(1,1,0,1), normal: float3( 0.0, 1.0, 1.0 ) ), // 5

        ]

        indices = [
            //front top
            4,0,1,
            //back top
            4,3,2,
            //left top
            4,2,0,
            //right top
            4,1,3,
            //front bottom
            5,1,0,
            //back top
            5,2,3,
            //left top
            5,0,2,
            //front bottom
            5,3,1
        ]
    }
}
