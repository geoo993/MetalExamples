import MetalKit

class GameScene: Scene {

  override init(device: MTLDevice, size: CGSize) {
    super.init(device: device, size: size)
    let quad = Plane(device: device, imageName: "stewe-griffin.jpg")
    add(childNode: quad)
  }
}


