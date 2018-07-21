import MetalKit

class PrimitivesScene: Scene {

    var mushroom: Model!
    var cube: Cube!
    var sun: Sphere!
    var torus: Torus!
    var pyramid: Pyramid!
    var diamond: Diamond!
    var icosahedron: Icosahedron!
    var prism: TriangularPrism!
    //var cone: Cone!
    //var cylinder: Cylinder!

    var cameraRotation: Float = 0

    override init(mtkView: MTKView, camera: Camera) {
        super.init(mtkView: mtkView, camera: camera)
    }

    override func setup (view: MTKView) {
        super.setup(view: view)
        name = "Primitives scene"

        mushroom = Model(mtkView: view, modelName: "mushroom", fragmentShader: .phong_fragment_shader)
        cube = Cube(mtkView: view, imageName: "abstract-color.jpg", fragmentShader: .phong_fragment_shader)
        torus = Torus(mtkView: view, imageName: "abstract-color.jpg", fragmentShader: .phong_fragment_shader)
        sun = Sphere(mtkView: view, imageName: "abstract-color.jpg", fragmentShader: .phong_fragment_shader)
        pyramid = Pyramid(mtkView: view, imageName: "spiralcolor.jpg", fragmentShader: .phong_fragment_shader)
        diamond = Diamond(mtkView: view, imageName: "blue-frozen-water.jpg", fragmentShader: .phong_fragment_shader)
        icosahedron = Icosahedron(mtkView: view, imageName: "colors-world", fragmentShader: .phong_fragment_shader)
        prism  = TriangularPrism(mtkView: view, imageName: "abstract-color.jpg", fragmentShader: .phong_fragment_shader)
        //cone = Cone(mtkView: view, imageName: "abstract-color.jpg", fragmentShader: .phong_fragment_shader)
        //cylinder = Cylinder(mtkView: view, imageName: "abstract-color.jpg", fragmentShader: .phong_fragment_shader)

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

        let shininess: Float = 12

        sun.material.color = float4(1, 1, 0, 1)
        sun.material.shininess = shininess
        sun.material.useTexture = true
        sun.position = float3(0, 0, 0)

        cube.position = float3(1, 0, 0)
        cube.material.shininess = shininess
        cube.material.useTexture = true
        cube.position.x = -2
        cube.scale = float3(0.5)

        mushroom.position = float3(0, 1.6, 0)
        mushroom.scale = float3(0.5)
        mushroom.material.shininess = shininess
        mushroom.material.useTexture = true

        pyramid.position = float3(0, -1.6, 0)
        pyramid.scale = float3(0.4)
        pyramid.material.shininess = shininess
        pyramid.material.useTexture = true

        diamond.position = float3(1, -1, 0)
        diamond.scale = float3(0.4)
        diamond.material.shininess = shininess
        diamond.material.useTexture = true

        icosahedron.position = float3(1, -3, -4)
        icosahedron.scale = float3(0.6)
        icosahedron.material.shininess = shininess
        icosahedron.material.useTexture = true

        prism.position = float3(1, -2, 4)
        prism.scale = float3(0.5)
        prism.material.shininess = shininess
        prism.material.useTexture = true

        //cone.position = float3(0, 2, 6)
        //cone.scale = float3(0.8)


        var dirLight = DirectionalLight()
        dirLight.direction = float3(-0.2, -1.0, -0.2)
        dirLight.base.color = float3(1, 1.0, 1.0)
        dirLight.base.intensity = 0.7
        dirLight.base.power = 2
        dirLight.base.ambient = float3(0.05)
        dirLight.base.diffuse = float3(0.4)
        dirLight.base.specular = float3(0.5)
        dirLights.append(dirLight)

        camera.set(position: float3(0,0,0), viewpoint: float3(0,0,1), up: float3(0,1,0))

    }

    override func update(deltaTime: Float) {
        super.update(deltaTime: deltaTime)

        cameraRotation += deltaTime * 10
        camera.rotateAroundPoint(distance: 45, viewpoint: torus.position, angle: cameraRotation, y: 0)

    }
}




