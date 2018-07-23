
import MetalKit

class LandscapeScene: Scene {

    var sun: Sphere!
    var ground: Plane!
    var grass: Instance!
    var mushroom: Model!

    var cameraRotation: Float = 0

    override init(mtkView: MTKView, camera: Camera) {
        super.init(mtkView: mtkView, camera: camera)
    }

    override func setup (view: MTKView) {
        super.setup(view: view)
        name = "Landscape scene"

        sun = Sphere(mtkView: view, fragmentShader: .fragment_color)
        ground = Plane(mtkView: view, fragmentShader: .fragment_color)
        grass = Instance(mtkView: view, modelName: "grass", instances: 10000, fragmentShader: .fragment_shader)
        mushroom = Model(mtkView: view, modelName: "mushroom", fragmentShader: .phong_fragment_shader)
      
        add(childNode: sun)
        add(childNode: ground)
        add(childNode: grass)
        add(childNode: mushroom)

        ground.material.color = float4(0.4, 0.3, 0.1, 1) // brown
        ground.material.shininess = 32
        ground.material.useTexture = true
        ground.position = float3(0, 0, 0)
        ground.scale = float3(20)
        ground.rotation.x = radians(degrees: 90)


        let greens = [
            float4(0.34, 0.51, 0.01, 1),
            float4(0.5, 0.5, 0, 1),
            float4(0.29, 0.36, 0.14, 1)
        ]

        for row in 0..<100 {
            for column in 0..<100 {
                var position = float3(0)
                position.x = (Float(row))/4
                position.z = (Float(column))/4
                let blade = grass.nodes[row * 100 + column]
                blade.scale = float3(0.5)
                blade.position = position
                blade.material.color = greens[Int(arc4random_uniform(3))]
                blade.rotation.y = CGFloat.random(min: 0, max: 360).toFloat
            }
        }

        grass.position.x = -12
        grass.position.z = -12

        mushroom.position.x = -6
        mushroom.position.z = -8
        mushroom.scale = float3(2)
        mushroom.material.shininess = 32
        mushroom.material.useTexture = true

        let sunColor = float3(1, 1, 0)
        sun.material.color = float4(sunColor, 1) // yellow
        sun.position.y = 10
        sun.position.x = 6
        sun.scale = float3(5)

        var dirLight = DirectionalLight()
        dirLight.direction = float3(0, -1.0, 0.0)
        dirLight.base.color = sunColor
        dirLight.base.intensity = 0.7
        dirLight.base.ambient = float3(0.05)
        dirLight.base.diffuse = float3(0.4)
        dirLight.base.specular = float3(0.5)
        dirLights.append(dirLight)

        //camera.fieldOfView = 25
        camera.set(position: float3(0, 10, -20), viewpoint: float3(0,0,0), up: float3(0,1,0))
    }

    override func update(deltaTime: Float) {
        super.update(deltaTime: deltaTime)

        cameraRotation += deltaTime * 20
        camera.rotateAroundPoint(distance: 50, viewpoint: float3(0,0, 0), angle: cameraRotation, y: 20)

    }
}
