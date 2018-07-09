import MetalKit

class PrimitivesScene: Scene {

    let mushroom: Model
    let cube: Cube
    let sun: Sphere
    let torus: Torus
    let pyramid: Pyramid
    let diamond: Diamond
    let icosahedron: Icosahedron
    let prism: TriangularPrism
    //let cone: Cone
    //let cylinder: Cylinder

    var cameraRotation: Float = 0

    override init(device: MTLDevice, camera: Camera) {
        mushroom = Model(device: device, modelName: "mushroom", fragmentShader: .lit_textured_fragment)
        cube = Cube(device: device, imageName: "abstract-color.jpg", fragmentShader: .lit_textured_fragment)
        torus = Torus(device: device, imageName: "abstract-color.jpg", fragmentShader: .lit_textured_fragment)
        sun = Sphere(device: device, imageName: "abstract-color.jpg", fragmentShader: .lit_textured_fragment)
        pyramid = Pyramid(device: device, imageName: "spiralcolor.jpg", fragmentShader: .lit_textured_fragment)
        diamond = Diamond(device: device, imageName: "blue-frozen-water.jpg", fragmentShader: .lit_textured_fragment)
        icosahedron = Icosahedron(device: device, imageName: "colors-world", fragmentShader: .lit_textured_fragment)
        prism  = TriangularPrism(device: device, imageName: "abstract-color.jpg", fragmentShader: .lit_textured_fragment)
        //cone = Cone(device: device, imageName: "abstract-color.jpg", fragmentShader: .lit_textured_fragment)
        //cylinder = Cylinder(device: device, imageName: "abstract-color.jpg", fragmentShader: .lit_textured_fragment)

        super.init(device: device, camera: camera)
        add(childNode: cube)
        add(childNode: mushroom)
        add(childNode: torus)
        add(childNode: sun)
        add(childNode: pyramid)
        add(childNode: diamond)
        add(childNode: icosahedron)
        add(childNode: prism)
        //add(childNode: cone)
        //add(childNode: cylinder)

        sun.material.color = float4(1, 1, 0, 1)
        sun.position = float3(0, 0, 0)

        cube.position = float3(1, 0, 0)

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


        camera.set(position: float3(0,0,0), viewpoint: float3(0,0,1), up: float3(0,1,0))

    }

    override func update(deltaTime: Float) {
        super.update(deltaTime: deltaTime)

        cameraRotation += deltaTime * 10
        camera.rotateAroundPoint(distance: 45, viewpoint: torus.position, angle: cameraRotation, y: 0)

    }
}




