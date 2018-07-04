
import MetalKit

class Node {
    var name = "Untitled"
    var children: [Node] = []
    var position = float3(0)
    var rotation = float3(0)
    var scale = float3(1)
    var width: Float = 1
    var height: Float = 1
    var materialColor = float4(1)
    var shininess: Float = 1
    var useTexture: Bool = true

    var modelMatrix: matrix_float4x4 {
        var matrix = matrix_float4x4(translationX: position.x,
                                     y: position.y, z: position.z)
        matrix = matrix.rotatedBy(rotationAngle: rotation.x,
                                  x: 1, y: 0, z: 0)
        matrix = matrix.rotatedBy(rotationAngle: rotation.y,
                                  x: 0, y: 1, z: 0)
        matrix = matrix.rotatedBy(rotationAngle: rotation.z,
                                  x: 0, y: 0, z: 1)
        matrix = matrix.scaledBy(x: scale.x, y: scale.y, z: scale.z)
        return matrix
    }
    
    func add(childNode: Node) {
        children.append(childNode)
    }

    func render(commandEncoder: MTLRenderCommandEncoder,
                parentModelMatrix: matrix_float4x4,
                camera: Camera) {
        let mMatrix = matrix_multiply(parentModelMatrix, modelMatrix)
        for child in children {
            child.render(commandEncoder: commandEncoder,
                         parentModelMatrix: mMatrix,
                         camera: camera)
        }

        if let renderable = self as? Renderable {
            commandEncoder.pushDebugGroup(name)
            renderable.doRender(commandEncoder: commandEncoder,
                                modelMatrix: mMatrix,
                                camera: camera)
            commandEncoder.popDebugGroup()
        }

    }
}
