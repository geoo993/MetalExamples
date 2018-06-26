import MetalKit

class Scene: Node {
  var device: MTLDevice
  var size: CGSize
  
  init(device: MTLDevice, size: CGSize) {

    //1) Create a reference to the GPU, which is the Device
    self.device = device
    self.size = size
    super.init()
  }
}
