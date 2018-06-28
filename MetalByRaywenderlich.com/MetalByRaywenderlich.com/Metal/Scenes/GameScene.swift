import MetalKit

class GameScene: Scene {

  var quad: Plane

  override init(device: MTLDevice, size: CGSize) {
    quad = Plane(device: device, imageName: "stewe-griffin.jpg")
    quad = Plane(device: device, imageName: "stewe-griffin.jpg", maskImageName: "picture-frame-mask.png")
    super.init(device: device, size: size)
    add(childNode: quad)
  }
}


