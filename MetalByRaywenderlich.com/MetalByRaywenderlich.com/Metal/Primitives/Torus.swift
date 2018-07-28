//
//  Torus.swift
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 01/07/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import MetalKit
import AppCore

class Torus: Primitive {

    override func setup() {
        super.setup()
        name = String(describing: Torus.self)
        useIndicies = false
        drawType = .triangleStrip

    }
    override func buildVertices() {
        super.buildVertices()

        let size: Float = 10.0
        let radialSeg = 50
        let circularSeg = 60

        let sTexCoord: [Float] = [ 2.0, 0, 0 ]
        let tTexCoord: [Float] = [ 0, 1.0, 0 ]

        var x: Float, y: Float, z: Float = 0      // POSITION
        var nx: Float, ny: Float, nz: Float = 0   // NORMAL
        //var tx: Float, ty: Float, tz: Float = 0   // TANGENT
        //var bx: Float, by: Float, bz: Float = 0   // BINORMAL
        var s: Float, t: Float = 0         // TEXCOORD
        var u: Float, v: Float = 0          //  U V
        var cu: Float, su: Float = 0       // COS And SIN  U
        var cv: Float, sv: Float = 0       // COS And SIN  V
        let outerRadius: Float = (size ) / 2.0 // radius
        let innerRadius: Float = 1.5             //tick
        let twopi: Float = 2.0 * Float.pi


        //for (i = 0; i < radialSeg; i++) {
        for i in 0..<radialSeg {

            //for (j = 0; j <= circularSeg; j++) {
            for j in 0...circularSeg {

                //for (k = 1; k >= 0; k--) {
                for k in (0...1).reversed() {
                   

                    /*
                     s = (i + k) % radialSeg + 0.5f;
                     t = j % (circularSeg + 1);

                     x = (radius + tick * cos(s * twopi/radialSeg)) * cos( t * twopi / circularSeg);
                     y = (radius + tick * cos(s * twopi/radialSeg)) * sin( t * twopi / circularSeg);
                     z = tick * sin(s * twopi / radialSeg);
                     */

                    u = Float(j % (circularSeg + 1)) / Float(circularSeg)
                    v = Float(i + k) / Float(radialSeg)

                    cu = cos( u * twopi ); //cos u
                    su = sin( u * twopi ); //sin u
                    cv = cos( v * twopi ); //con v
                    sv = sin( v * twopi ); //sin v

                    // Position
                    x = ( outerRadius + innerRadius * cv ) * cu
                    y = ( outerRadius + innerRadius * cv ) * su
                    z = innerRadius * sv

                    // Normal
                    nx = cu * cv
                    ny = su * cv
                    nz = sv

                    // Tangent
                    //tx = ( outerRadius + innerRadius * cv ) * -su
                    //ty = ( outerRadius + innerRadius * cv ) * cu
                    //tz = 0.0

                    // Binormal
                    //bx = -cu * sv
                    //by = -su * cv
                    //bz = cv

                    // U, V texture mapping
                    s = ( u * sTexCoord[0] ) + ( v * sTexCoord[1] )
                    t = ( v * tTexCoord[0] ) + ( v * tTexCoord[1] )

                    //s = (i + k) % radialSeg + 0.5f;
                    //t = j % (circularSeg + 1);

                    let vert = float3(x,y,z)
                    let uv = float2(s, t)
                    let norm = float3(nx, ny, nz)
                    //let tan = float3(tx, ty, tz )
                    //let biNorm = float3(bx, by, bz )
                    //let biTan = cross(norm, tan)

                    let vertex = Vertex(position: vert, texture: uv, color: float4(norm, 1), normal: norm  )
                    vertices.append(vertex)
                    //vertices.push_back(vert);
                    //texCoords.push_back(uv);
                    //normals.push_back(norm);
                    //tangents.push_back(tan);
                    //binormals.push_back(biNorm);
                    //bitangents.push_back(biTan);

                }
            }
        }

    }

}
