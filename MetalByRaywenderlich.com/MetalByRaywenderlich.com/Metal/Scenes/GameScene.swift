import MetalKit

class GameScene: Scene {

    var quad: Plane
    var cube: Cube

    override init(device: MTLDevice, camera: Camera) {

        quad = Plane(device: device, name: "Quad", imageName: "abstract-color.jpg")
        cube = Cube(device: device, name: "Cube", imageName: "abstract-color.jpg")
        super.init(device: device, camera: camera)
        add(childNode: quad)
        add(childNode: cube)
        add(childNode: camera)

        camera.position.y = -1
        camera.position.x = 1
        camera.position.z = -6

        quad.position.z = -3
        quad.position.y = -1.5
        quad.scale = float3(2.0)
        
        cube.useIndicies = false
        cube.scale = float3(0.5)

    }

    override func update(deltaTime: Float) {
        super.update(deltaTime: deltaTime)

        let animateBy = abs(sin(time)/2 + 0.5) // sin values are between 1 and -1
        quad.rotation.y = animateBy
        cube.rotation.x -= deltaTime
        //cube.rotation.y += deltaTime
        //cube.rotation.z -= deltaTime
        print(time, animateBy)

        camera.rotateAroundPoint(distance: 10, viewpoint: cube.position, angle: time + 20, y: 10)
        camera.position.z += time
    }
}




