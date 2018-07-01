
import MetalKit
import AppCore

class Cylinder: Primitive {

    override func setup() {
        super.setup()
        useIndicies = false
        name = String(describing: Cylinder.self)
    }

    override func buildVertices() {
        super.buildVertices()
    }
}
