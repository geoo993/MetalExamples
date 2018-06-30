
import MetalKit

class Node {
    var name = "Untitled"
    var children: [Node] = []
    var position = float3(0)
    var rotation = float3(0)
    var scale = float3(1)
  
    func add(childNode: Node) {
        children.append(childNode)
    }
  
    func render(commandEncoder: MTLRenderCommandEncoder, screen: CGSize, deltaTime: Float) {
        for child in children {
            child.render(commandEncoder: commandEncoder, screen: screen, deltaTime: deltaTime)
        }
    }
}
