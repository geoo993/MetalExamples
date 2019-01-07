//
//  Sphere.swift
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 01/07/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import MetalKit

public class Sphere: Primitive {

    override public func setup() {
        super.setup()
        name = String(describing: Sphere.self)
        useIndicies = true
    }

    // https://stackoverflow.com/questions/7957254/connecting-sphere-vertices-opengl
    // https://gist.github.com/davidbitton/1094320
    public func SolidSphere(radius: Float, latitude: Int, longitude: Int)
    {
        /* ONE
        let pi = Float.pi
        for lat in 0...latitude {
            let theta: Float = lat.toFloat * pi / latitude.toFloat
            let sinTheta: Float = sin(theta)
            let cosTheta: Float = cos(theta)

            for long in 0...longitude {
                let phi: Float = long.toFloat * 2 * pi / longitude.toFloat
                let sinPhi: Float = sin(phi)
                let cosPhi: Float = cos(phi)

                let verts = float3(cosPhi * sinTheta * radius, cosTheta * radius, sinPhi * sinTheta * radius)
                let texture = float2(1.0 - (long.toFloat / longitude.toFloat), 1.0 - (lat.toFloat / latitude.toFloat))
                let normal = float3(cosPhi * sinTheta, cosTheta, sinPhi * sinTheta)
                let vertex = Vertex(position: verts, texture: texture, color: float4(verts,1), normal: normal)
                vertices.append(vertex)

            }

            for lat in 0...latitude {
                for long in 0...longitude {

                    let first: UInt16 = UInt16((lat * (longitude + 1)) + long)
                    let second: UInt16 = UInt16(first) + UInt16(longitude + 1)
                    indices.append(first)
                    indices.append(second)
                    indices.append(first + 1)

                    indices.append(second)
                    indices.append(second + 1)
                    indices.append(first + 1)

                }
            }


        }
        */

        /* TWO
        let R: Float = 1.0 / (rings - 1).toFloat
        let S: Float = 1.0 / (sectors - 1).toFloat
        let pi = Float.pi
        let pi2 = Float.pi * 2
        for r in 0..<rings {
            for s in 0..<sectors {
                let y: Float = sin( -pi2 + pi * r.toFloat * R );
                let x: Float = cos(2 * pi * s.toFloat * S) * sin( pi * r.toFloat * R )
                let z: Float = sin(2 * pi * s.toFloat * S) * sin( pi * r.toFloat * R )

                let verts = float3(x * radius, y * radius, z * radius)
                let texture = float2(s.toFloat * S, r.toFloat * R)
                let normal = float3(x, y, z)

                let vertex = Vertex(position: verts, texture: texture, color: float4(verts,1), normal: normal)
                vertices.append(vertex)
            }
        }

        for r in 0..<rings {
            for s in 0..<sectors {
                indices.append(UInt16( r * sectors + s))
                indices.append(UInt16(r * sectors + (s + 1)))
                indices.append(UInt16((r + 1) * sectors + (s + 1)))
                indices.append(UInt16((r + 1) * sectors + s))
            }
        }
 */
    }

    override public func buildVertices() {
        super.buildVertices()

        //SolidSphere(radius: 2, latitude: 50, longitude: 50)

        // Compute vertex attributes and store in VBO
        let slicesIn = 50
        let stacksIn = 50
        let pi = Float.pi
        var verts = [float3]()
        var uvs = [float2]()
        var normals = [float3]()
        var tangents = [float3]()
        var bitangents = [float3]()

        for stacks in 0..<stacksIn {

            let phi: Float = Float(stacks) / Float(stacksIn - 1) * pi
            for slices in 0...slicesIn {
                let theta: Float = Float(slices) / Float(slicesIn) * 2 * pi

                let v = float3(cos(theta) * sin(phi), sin(theta) * sin(phi), cos(phi))
                let t = float2(Float(slices) / Float(slicesIn), Float(stacks) / Float(stacksIn))
                let n = v

                verts.append(v)
                uvs.append(t)
                normals.append(n)

                let vertex = Vertex(position: v, texture: t, color: float4(v,1), normal: v)
                vertices.append(vertex)
            }
        }


        for stacks in 0..<stacksIn {
            for slices in 0..<slicesIn {

                let nextSlice = slices + 1;
                let nextStack = (stacks + 1) % stacksIn;

                let index0: UInt16 = UInt16(stacks * (slicesIn + 1) + slices)
                let index1: UInt16 = UInt16(nextStack * (slicesIn + 1) + slices)
                let index2: UInt16 = UInt16(stacks * (slicesIn + 1) + nextSlice)
                let index3: UInt16 = UInt16(nextStack * (slicesIn + 1) + nextSlice)

                indices.append(index0)
                indices.append(index1)
                indices.append(index2)

                indices.append(index2)
                indices.append(index1)
                indices.append(index3)
            }
        }

        for i in stride(from: 0, through: verts.count, by: 3) {

            guard i < verts.count - 2 else { return }

            // Shortcuts for vertices
            let v0 = verts[i + 0]
            let v1 = verts[i + 1]
            let v2 = verts[i + 2]

            // Shortcuts for UVs
            let uv0 = uvs[i + 0]
            let uv1 = uvs[i + 1]
            let uv2 = uvs[i + 2]

            // Edges of the triangle : postion delta
            let deltaPos1 = v1 - v0;
            let deltaPos2 = v2 - v0;

            // UV delta
            let deltaUV1 = uv1 - uv0;
            let deltaUV2 = uv2 - uv0;

            let rad = 1.0 / (deltaUV1.x * deltaUV2.y - deltaUV1.y * deltaUV2.x)
            let tangent = (deltaPos1 * deltaUV2.y   - deltaPos2 * deltaUV1.y) * rad
            let bitangent = (deltaPos2 * deltaUV1.x   - deltaPos1 * deltaUV2.x) * rad

            // Set the same tangent for all three vertices of the triangle.
            // They will be merged later, in vboindexer.cpp
            tangents.append(tangent)
            tangents.append(tangent)
            tangents.append(tangent)

            // Same thing for binormals
            bitangents.append(bitangent)
            bitangents.append(bitangent)
            bitangents.append(bitangent)
        }

    }

}
