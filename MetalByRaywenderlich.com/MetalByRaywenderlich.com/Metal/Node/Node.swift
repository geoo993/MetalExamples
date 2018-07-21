
import MetalKit

class Node {
    var name = "Untitled"
    weak var parent: Node?
    var children: [Node] = []
    var position = float3(0)
    var rotation = float3(0)
    var scale = float3(1)
    var width: Float = 1
    var height: Float = 1
    var material = MaterialInfo()
    var overrideModelMatrix = false

    private var makeModelMatrix: matrix_float4x4 {
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

    var modelMatrix: matrix_float4x4!

    init(name: String) {
        self.name = name
        self.modelMatrix = makeModelMatrix
    }
    
    func add(childNode: Node) {
        children.append(childNode)
    }

    func get(childNode name: String) -> Node? {
        for node in children {
            if node.name == name {
                return node
            } else if let matchingGrandchild = node.get(childNode: name) {
                return matchingGrandchild
            }
        }
        return nil
    }

    func render(commandEncoder: MTLRenderCommandEncoder,
                parentModelMatrix: matrix_float4x4,
                camera: Camera) {
        if overrideModelMatrix == false {
            self.modelMatrix = makeModelMatrix
        }
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
