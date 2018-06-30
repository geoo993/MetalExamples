
import MetalKit
import AppCore


class Cube: Primitive {

    override func buildVertices() {
        super.buildVertices()

        // A cube has 8 vertices and 6 sides also called faces,
        // there will be 12 triangles involved as each side has 2 triangles.
        /////6--------------/5
        ////  .           // |
        //2--------------1   |
        //    .          |   |
        //    .          |   |
        //    .          |   |
        //    .          |   |
        //    7......... |   /4
        //               | //
        //3--------------/0

        // vertices drawn anti-clockwise
        let size: Float = 1.0
        vertices = [
            /*
                Vertex(position: float3( size, -size, size ), texture:  float2(1.0,0.0), color: float4(1.0, 1.0, 0.0, 1 ), ), // 0
                Vertex(position: float3( size, size, size ), texture:  float2(1.0,1.0), color: float4( 0.0, 1.0, 1.0, 1 ) ), // 1
                Vertex(position: float3( -size, size, size ), texture:  float2(0.0,1.0), color: float4(1.0, 1.0, 1.0, 1 ),), // 2
                Vertex(position: float3( -size, -size, size ), texture:  float2(0.0,0.0), color: float4( 1.0, 1.0, 1.0, 1) ), // 3
                Vertex(position: float3( size, -size, -size ), texture:  float2(0.0,0.0), color: float4( 1.0, 0.0, 0.0, 1 ) ), // 4
                Vertex(position: float3( size, size, -size ), texture:  float2(0.0,1.0), color: float4( 0.0, 0.0, 1.0, 1 ) ), // 5
                Vertex(position: float3( -size, size, -size ), texture:  float2(1.0,1.0), color: float4( 1.0, 1.0, 1.0, 1 ) ), // 6
                Vertex(position: float3( -size, -size, -size ), texture:  float2(1.0, 0.0), color: float4( 0.0, 1.0, 1.0, 1 ) ), // 7
            */


            //vertices positions                          //texture             //colors
            //bottom 3,7,4  4,0,3
            Vertex( position: float3(  -size,-size,size ), texture: float2(1.0,0.0), color: float4( 1.0, 1.0, 1.0, 1 ) ), // 0
            Vertex( position: float3( -size, -size, -size ), texture: float2(1.0,1.0), color: float4( 1.0, 1.0, 1.0, 1 ) ), // 1
            Vertex( position: float3( size, -size, -size ), texture: float2(0.0,1.0), color: float4( 1.0, 1.0, 1.0, 1 ) ), // 2
            Vertex( position: float3(  size, -size, -size ), texture: float2(0.0,1.0), color: float4( 1.0, 1.0, 1.0, 1 ) ), // 3
            Vertex( position: float3( size, -size, size ), texture: float2(0.0,0.0), color: float4( 1.0, 1.0, 1.0, 1 ) ), // 4
            Vertex( position: float3( -size, -size, size ), texture: float2(1.0,0.0), color: float4( 1.0, 1.0, 1.0, 1 ) ), // 5

            //top   1,5,6   6,2,1
            Vertex( position: float3( size,size, size ), texture: float2(1.0,0.0), color: float4( 1.0, 1.0, 1.0, 1 ) ), // 6
            Vertex( position: float3( size, size, -size ), texture: float2(1.0,1.0), color: float4( 1.0, 1.0, 1.0, 1 ) ), // 7
            Vertex( position: float3(  -size, size,-size ), texture: float2(0.0,1.0), color: float4(1.0, 1.0, 1.0, 1 ) ), // 8
            Vertex( position: float3( -size, size,-size ), texture: float2(0.0,1.0), color: float4( 1.0, 1.0, 1.0, 1) ), // 9
            Vertex( position: float3( -size, size, size ), texture: float2(0.0,0.0), color: float4( 1.0, 1.0, 1.0, 1 ) ), // 10
            Vertex( position: float3( size, size, size ), texture: float2(1.0,0.0), color: float4( 1.0, 1.0, 1.0 ,1) ), // 11

            //front 0,1,2    2,3,0
            Vertex( position: float3(  size,-size,size ), texture: float2(1.0,0.0), color: float4( 1.0, 1.0, 1.0, 1 ) ), // 12
            Vertex( position: float3( size, size, size ), texture: float2(1.0,1.0), color: float4( 1.0, 1.0, 1.0, 1 ) ), // 13
            Vertex( position: float3( -size, size, size ), texture: float2(0.0,1.0), color: float4( 1.0, 1.0, 1.0, 1 ) ), // 14
            Vertex( position: float3( -size,size, size ), texture: float2(0.0,1.0), color: float4( 1.0, 1.0, 1.0, 1) ), // 15
            Vertex( position: float3(  -size, -size, size ), texture: float2(0.0,0.0), color: float4( 1.0, 1.0, 1.0, 1 ) ), // 16
            Vertex( position: float3( size, -size, size ), texture: float2(1.0,0.0), color: float4( 1.0, 1.0, 1.0, 1 ) ), // 17

            //back  7,6,5   5,4,7
            Vertex( position: float3( -size, -size, -size ), texture: float2(1.0,0.0), color: float4(1.0, 1.0, 1.0, 1 ) ), // 18
            Vertex( position: float3( -size, size, -size ), texture: float2(1.0,1.0), color: float4( 1.0, 1.0, 1.0, 1 ) ), // 19
            Vertex( position: float3( size, size, -size ), texture: float2(0.0,1.0), color: float4( 1.0, 1.0, 1.0, 1 ) ), // 20
            Vertex( position: float3( size, size, -size ), texture: float2(0.0,1.0), color: float4(1.0, 1.0, 1.0 , 1) ), // 21
            Vertex( position: float3( size, -size,-size ), texture: float2(0.0,0.0), color: float4( 1.0, 1.0, 1.0, 1 ) ), // 22
            Vertex( position: float3( -size, -size, -size ), texture: float2(1.0,0.0), color: float4( 1.0, 1.0, 1.0, 1 ) ), // 23

            //left   3,2,6  6,7,3
            Vertex( position: float3( -size,-size,size), texture: float2(1.0,0.0), color: float4( 1.0, 1.0, 1.0, 1 ) ), // 24
            Vertex( position: float3( -size, size, size ), texture: float2(1.0,1.0), color: float4( 1.0, 1.0, 1.0, 1 ) ), // 25
            Vertex( position: float3( -size, size, -size ), texture: float2(0.0,1.0), color: float4( 1.0, 1.0, 1.0, 1 ) ), // 26
            Vertex( position: float3( -size, size, -size ), texture: float2(0.0,1.0), color: float4( 1.0, 1.0, 1.0, 1 ) ), // 27
            Vertex( position: float3( -size, -size, -size), texture: float2(0.0,0.0), color: float4( 1.0, 1.0, 1.0, 1 ) ), // 28
            Vertex( position: float3( -size, -size, size ), texture: float2(1.0,0.0), color: float4( 1.0, 1.0, 1.0, 1) ), // 29

            //right   4,5,1   1,0,4
            Vertex( position: float3( size, -size, -size ), texture: float2(1.0,0.0), color: float4( 1.0, 1.0, 1.0, 1 ) ), // 30
            Vertex( position: float3( size, size,-size ), texture: float2(1.0,1.0), color: float4( 1.0, 1.0, 1.0 , 1) ), // 31
            Vertex( position: float3( size, size, size ), texture: float2(0.0,1.0), color: float4( 1.0, 1.0, 1.0 , 1) ), // 32
            Vertex( position: float3( size, size, size ), texture: float2(0.0,1.0), color: float4( 1.0, 1.0, 1.0 , 1) ), // 33
            Vertex( position: float3( size, -size, size ), texture: float2(0.0,0.0), color: float4( 1.0, 1.0, 1.0, 1 ) ), // 34
            Vertex( position: float3( size, -size, -size ), texture: float2(1.0,0.0), color: float4( 1.0, 1.0, 1.0, 1 ) ), // 35
        ]

        /*
        indices = [
            //top
            1,5,6, 6,2,1,

            // bottom
            3,7,4, 4,0,3,

            //front
            0,1,2, 2,3,0,

            //back
            7,6,5, 5,4,7,

            //right
            3,2,6, 6,7,3,

            //left
            4,5,1, 1,0,4
        ]
 */

    }

    init(device: MTLDevice, name: String, imageName: String) {
        super.init(device: device, name: name, imageName: imageName, useIndicies: false)
    }


}


