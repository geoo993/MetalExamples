import MetalKit

class GameScene: Scene {

    let sun: Sphere
    let cube: Cube
    let torus: Torus
    let torusKnot: TorusKnot
    let mushroom: Model
    let pyramid: Pyramid
    let diamond: Diamond
    let icosahedron: Icosahedron
    let prism: TriangularPrism
    //let cone: Cone
    //let cylinder: Cylinder

    var cameraRoation: Float = 0

    override init(device: MTLDevice, camera: Camera) {
        mushroom = Model(device: device, modelName: "mushroom")
        cube = Cube(device: device, imageName: "abstract-color.jpg")
        torus = Torus(device: device, imageName: "abstract-color.jpg")
        torusKnot = TorusKnot(device: device, imageName: "blue-frozen-water.jpg")
        sun = Sphere(device: device, imageName: "abstract-color.jpg")
        pyramid = Pyramid(device: device, imageName: "spiralcolor.jpg")
        diamond = Diamond(device: device, imageName: "blue-frozen-water.jpg")
        icosahedron = Icosahedron(device: device, imageName: "colors-world")
        prism  = TriangularPrism(device: device, imageName: "abstract-color.jpg")
        //cone = Cone(device: device, imageName: "abstract-color.jpg")
        //cylinder = Cylinder(device: device, imageName: "abstract-color.jpg")

        super.init(device: device, camera: camera)
        add(childNode: cube)
        add(childNode: mushroom)
        add(childNode: torus)
        add(childNode: torusKnot)
        add(childNode: sun)
        add(childNode: pyramid)
        add(childNode: diamond)
        add(childNode: icosahedron)
        add(childNode: prism)
        //add(childNode: cone)
        //add(childNode: cylinder)

        sun.materialColor = float4(1, 1, 0, 1)
        sun.position = float3(0, 0, 0)

        cube.position.x = 1

        mushroom.position = float3(0, 1.6, 0)
        mushroom.scale = float3(0.5)

        cube.position.x = -2
        cube.scale = float3(0.5)

        pyramid.position = float3(0, -1.6, 0)
        pyramid.scale = float3(0.4)

        diamond.position = float3(1, -1, 0)
        diamond.scale = float3(0.4)

        icosahedron.position = float3(1, -3, -4)
        icosahedron.scale = float3(0.6)

        prism.position = float3(1, -2, 4)
        prism.scale = float3(0.5)

        //cone.position = float3(0, 2, 6)
        //cone.scale = float3(0.8)

        torus.position = float3(3, 2, -18)
        torus.scale = float3(0.8)

        camera.set(position: float3(0,0,0), viewpoint: float3(0,0,1), up: float3(0,1,0))

    }

    override func update(deltaTime: Float) {
        super.update(deltaTime: deltaTime)

        cameraRoation += deltaTime * 10
        camera.rotateAroundPoint(distance: 45, viewpoint: torusKnot.position, angle: cameraRoation, y: 0)

    }
}




