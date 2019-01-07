
import MetalKit

public class Cylinder: Primitive {

    override public func setup() {
        super.setup()
        useIndicies = false
        name = String(describing: Cylinder.self)
    }

    override public func buildVertices() {
        super.buildVertices()
    }
}
