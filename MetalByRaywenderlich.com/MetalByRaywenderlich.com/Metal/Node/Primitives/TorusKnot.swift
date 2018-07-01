
import MetalKit
import AppCore

class TorusKnot: Primitive {
    override func setup() {
        super.setup()
        useIndicies = true
        name = String(describing: TorusKnot.self)
        drawType = .triangleStrip
    }

    override func buildVertices() {
        super.buildVertices()

        let aSteps = 1024          // in: Number of steps in the torus knot
        let aFacets = 32          // in: Number of facets
        let aScale: Float = 4.0         // in: Scale of the knot
        var aThickness: Float = 0.5     // in: Thickness of the knot
        let aClumps: Float = 0.0       // in: Number of clumps in the knot
        let aClumpOffset: Float = 0.0   // in: Offset of the clump (in 0..2pi)
        let aClumpScale: Float = 0.0    // in: Scale of a clump
        let aUScale: Float = 2.0       // in: U coordinate scale
        let aVScale: Float = 32.0        // in: V coordinate scale
        let aP: Float = 3;//3.0            // in: P parameter of the knot
        let aQ: Float = 2;//-7.0             // in: Q parameter of the knot

        aThickness = aThickness * aScale
        let twopi = 2.0 * Float.pi

        let vtx: UnsafeMutablePointer<Float> = UnsafeMutablePointer<Float>.allocate(capacity: ((aSteps + 1) * (aFacets + 1) + 1) * 3)
        let normal: UnsafeMutablePointer<Float> = UnsafeMutablePointer<Float>.allocate(capacity: ((aSteps + 1) * (aFacets + 1) + 1) * 3)
        let texcoord: UnsafeMutablePointer<Float> = UnsafeMutablePointer<Float>.allocate(capacity: ((aSteps + 1) * (aFacets + 1) + 1) * 2)
        let torusIndices: UnsafeMutablePointer<UInt16> = UnsafeMutablePointer<UInt16>.allocate(capacity: (aSteps + 1) * aFacets * 2)

        for j in 0..<aFacets
        {
            for i in 0...aSteps
            {
                torusIndices[i * 2 + 0 + j * (aSteps + 1) * 2] = UInt16(j + 1 + i * (aFacets + 1))
                torusIndices[i * 2 + 1 + j * (aSteps + 1) * 2] = UInt16(j + i * (aFacets + 1))
            }

        }
        indices.append(contentsOf: Array(UnsafeBufferPointer(start: torusIndices, count: (aSteps + 1) * aFacets * 2)))

        for i in 0..<aSteps
        {
            var centerpoint: float3 = float3(0)
            var Pp = aP * Float(i) * twopi / Float(aSteps)
            var Qp = aQ * Float(i) * twopi / Float(aSteps)
            var r = (0.5 * (2 + sin(Qp))) * aScale;
            centerpoint.x = r * cos(Pp)
            centerpoint.y = r * cos(Qp)
            centerpoint.z = r * sin(Pp)

            var nextpoint: float3 = float3(0)
            Pp = aP * Float(i + 1) * twopi / Float(aSteps)
            Qp = aQ * Float(i + 1) * twopi / Float(aSteps)
            r = (0.5 * (2 + sin(Qp))) * aScale
            nextpoint.x = r * cos(Pp)
            nextpoint.y = r * cos(Qp)
            nextpoint.z = r * sin(Pp)

            var T: float3 = float3(0)
            T.x = nextpoint[0] - centerpoint[0];
            T.y = nextpoint[1] - centerpoint[1];
            T.z = nextpoint[2] - centerpoint[2];

            var N: float3 = float3(0)
            N.x = nextpoint[0] + centerpoint[0];
            N.y = nextpoint[1] + centerpoint[1];
            N.z = nextpoint[2] + centerpoint[2];

            var B: float3 = float3(0)
            B.x = T.y * N.z - T.z * N.y
            B.y = T.z * N.x - T.x * N.z
            B.z = T.x * N.y - T.y * N.x;

            N.x = B.y * T.z - B.z * T.y
            N.y = B.z * T.x - B.x * T.z
            N.z = B.x * T.y - B.y * T.x

            var l = sqrt(B.x * B.x + B.y * B.y + B.z * B.z)
            B.x /= l
            B.y /= l
            B.z /= l

            l = sqrt(N.x * N.x + N.y * N.y + N.z * N.z)
            N.x /= l;
            N.y /= l;
            N.z /= l;

            for j in 0..<aFacets
            {

                let pointx: Float = sin(Float(j) * twopi / Float(aFacets)) * aThickness * (( sin(aClumpOffset + aClumps * Float(i) * twopi / Float(aSteps)) * aClumpScale) + 1)
                let pointy: Float = cos(Float(j) * twopi / Float(aFacets)) * aThickness * (( cos(aClumpOffset + aClumps * Float(i) * twopi / Float(aSteps)) * aClumpScale) + 1)

                vtx[i * (aFacets + 1) * 3 + j * 3 + 0] = N.x * pointx + B.x * pointy + centerpoint.x
                vtx[i * (aFacets + 1) * 3 + j * 3 + 1] = N.y * pointx + B.y * pointy + centerpoint.y
                vtx[i * (aFacets + 1) * 3 + j * 3 + 2] = N.z * pointx + B.z * pointy + centerpoint.z

                normal[i * (aFacets + 1) * 3 + j * 3 + 0] = vtx[i * (aFacets + 1) * 3 + j * 3 + 0] - centerpoint.x
                normal[i * (aFacets + 1) * 3 + j * 3 + 1] = vtx[i * (aFacets + 1) * 3 + j * 3 + 1] - centerpoint.y
                normal[i * (aFacets + 1) * 3 + j * 3 + 2] = vtx[i * (aFacets + 1) * 3 + j * 3 + 2] - centerpoint.z

                let l: Float = sqrtf(
                    Float(normal[i * (aFacets + 1) * 3 + j * 3 + 0]) *
                    Float(normal[i * (aFacets + 1) * 3 + j * 3 + 0]) +
                    Float(normal[i * (aFacets + 1) * 3 + j * 3 + 1]) *
                    Float(normal[i * (aFacets + 1) * 3 + j * 3 + 1]) +
                    Float(normal[i * (aFacets + 1) * 3 + j * 3 + 2]) *
                    Float(normal[i * (aFacets + 1) * 3 + j * 3 + 2]))

                texcoord[i * (aFacets + 1) * 2 + j * 2 + 0] = (Float(j) / Float(aFacets)) * aUScale
                texcoord[i * (aFacets + 1) * 2 + j * 2 + 1] = (Float(i) / Float(aSteps)) * aVScale

                let pos = float3(vtx[    i * (aFacets + 1) * 3 + j * 3 + 0],
                                 vtx[    i * (aFacets + 1) * 3 + j * 3 + 1],
                                 vtx[    i * (aFacets + 1) * 3 + j * 3 + 2])
                let tex = float2(texcoord[i * (aFacets + 1) * 2 + j * 2 + 0],
                                 texcoord[i * (aFacets + 1) * 2 + j * 2 + 1])
                let norm = float3(normal[  i * (aFacets + 1) * 3 + j * 3 + 0],
                                  normal[  i * (aFacets + 1) * 3 + j * 3 + 1],
                                  normal[  i * (aFacets + 1) * 3 + j * 3 + 2])
                let vertex = Vertex(position: pos, texture: tex, color: float4(1,1,1,1), normal: norm)
                vertices.append(vertex)

                normal[i * (aFacets + 1) * 3 + j * 3 + 0] /= l
                normal[i * (aFacets + 1) * 3 + j * 3 + 1] /= l
                normal[i * (aFacets + 1) * 3 + j * 3 + 2] /= l
            }
            // create duplicate vertex for sideways wrapping
            // otherwise identical to first vertex in the 'ring' except for the U coordinate
            vtx[i * (aFacets + 1) * 3 + aFacets * 3 + 0] = vtx[i * (aFacets + 1) * 3 + 0];
            vtx[i * (aFacets + 1) * 3 + aFacets * 3 + 1] = vtx[i * (aFacets + 1) * 3 + 1];
            vtx[i * (aFacets + 1) * 3 + aFacets * 3 + 2] = vtx[i * (aFacets + 1) * 3 + 2];

            normal[i * (aFacets + 1) * 3 + aFacets * 3 + 0] = normal[i * (aFacets + 1) * 3 + 0];
            normal[i * (aFacets + 1) * 3 + aFacets * 3 + 1] = normal[i * (aFacets + 1) * 3 + 1];
            normal[i * (aFacets + 1) * 3 + aFacets * 3 + 2] = normal[i * (aFacets + 1) * 3 + 2];

            texcoord[i * (aFacets + 1) * 2 + aFacets * 2 + 0] = aUScale;
            texcoord[i * (aFacets + 1) * 2 + aFacets * 2 + 1] = texcoord[i * (aFacets + 1) * 2 + 1];

            let pos = float3(vtx[    i * (aFacets + 1) * 3 + aFacets * 3 + 0],
                             vtx[    i * (aFacets + 1) * 3 + aFacets * 3 + 1],
                             vtx[    i * (aFacets + 1) * 3 + aFacets * 3 + 2])
            let tex = float2(texcoord[i * (aFacets + 1) * 2 + aFacets * 2 + 0],
                             texcoord[i * (aFacets + 1) * 2 + aFacets * 2 + 1])
            let norm = float3(normal[  i * (aFacets + 1) * 3 + aFacets * 3 + 0],
                              normal[  i * (aFacets + 1) * 3 + aFacets * 3 + 1],
                              normal[  i * (aFacets + 1) * 3 + aFacets * 3 + 2])
            let vertex = Vertex(position: pos, texture: tex, color: float4(1,1,1,1), normal: norm)
            vertices.append(vertex)
        }

        // create duplicate ring of vertices for longways wrapping
        // otherwise identical to first 'ring' in the knot except for the V coordinate
        for j in 0..<aFacets
        {
            vtx[aSteps * (aFacets + 1) * 3 + j * 3 + 0] = vtx[j * 3 + 0];
            vtx[aSteps * (aFacets + 1) * 3 + j * 3 + 1] = vtx[j * 3 + 1];
            vtx[aSteps * (aFacets + 1) * 3 + j * 3 + 2] = vtx[j * 3 + 2];

            normal[aSteps * (aFacets + 1) * 3 + j * 3 + 0] = normal[j * 3 + 0];
            normal[aSteps * (aFacets + 1) * 3 + j * 3 + 1] = normal[j * 3 + 1];
            normal[aSteps * (aFacets + 1) * 3 + j * 3 + 2] = normal[j * 3 + 2];

            texcoord[aSteps * (aFacets + 1) * 2 + j * 2 + 0] = texcoord[j * 2 + 0];
            texcoord[aSteps * (aFacets + 1) * 2 + j * 2 + 1] = aVScale;

            let pos = float3(vtx[    aSteps * (aFacets + 1) * 3 + j * 3 + 0],
                             vtx[    aSteps * (aFacets + 1) * 3 + j * 3 + 1],
                             vtx[    aSteps * (aFacets + 1) * 3 + j * 3 + 2])
            let tex = float2(texcoord[aSteps * (aFacets + 1) * 2 + j * 2 + 0],
                             texcoord[aSteps * (aFacets + 1) * 2 + j * 2 + 1])
            let norm = float3(normal[  aSteps * (aFacets + 1) * 3 + j * 3 + 0],
                              normal[  aSteps * (aFacets + 1) * 3 + j * 3 + 1],
                              normal[  aSteps * (aFacets + 1) * 3 + j * 3 + 2])
            let vertex = Vertex(position: pos, texture: tex, color: float4(1,1,1,1), normal: norm)
            vertices.append(vertex)
        }

        // finally, there's one vertex that needs to be duplicated due to both U and V coordinate.
        vtx[aSteps * (aFacets + 1) * 3 + aFacets * 3 + 0] = vtx[0];
        vtx[aSteps * (aFacets + 1) * 3 + aFacets * 3 + 1] = vtx[1];
        vtx[aSteps * (aFacets + 1) * 3 + aFacets * 3 + 2] = vtx[2];

        normal[aSteps * (aFacets + 1) * 3 + aFacets * 3 + 0] = normal[0];
        normal[aSteps * (aFacets + 1) * 3 + aFacets * 3 + 1] = normal[1];
        normal[aSteps * (aFacets + 1) * 3 + aFacets * 3 + 2] = normal[2];

        texcoord[aSteps * (aFacets + 1) * 2 + aFacets * 2 + 0] = aUScale;
        texcoord[aSteps * (aFacets + 1) * 2 + aFacets * 2 + 1] = aVScale;

        let pos = float3(vtx[    aSteps * (aFacets + 1) * 3 + aFacets * 3 + 0],
                         vtx[    aSteps * (aFacets + 1) * 3 + aFacets * 3 + 1],
                         vtx[    aSteps * (aFacets + 1) * 3 + aFacets * 3 + 2])
        let tex = float2(texcoord[aSteps * (aFacets + 1) * 2 + aFacets * 2 + 0],
                         texcoord[aSteps * (aFacets + 1) * 2 + aFacets * 2 + 1])
        let norm = float3(normal[  aSteps * (aFacets + 1) * 3 + aFacets * 3 + 0],
                          normal[  aSteps * (aFacets + 1) * 3 + aFacets * 3 + 1],
                          normal[  aSteps * (aFacets + 1) * 3 + aFacets * 3 + 2])
        let vertex = Vertex(position: pos, texture: tex, color: float4(1,1,1,1), normal: norm)
        vertices.append(vertex)

        vtx.deallocate()
        normal.deallocate()
        texcoord.deallocate()
        torusIndices.deallocate()

    }

}
