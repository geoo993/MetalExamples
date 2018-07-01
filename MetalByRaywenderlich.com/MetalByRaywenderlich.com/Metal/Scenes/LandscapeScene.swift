
import MetalKit

class LandscapeScene: Scene {

    let sun: Sphere
    let ground: Plane
    let grass: Instance
    let mushroom: Model

    var cameraRotation: Float = 0

    override init(device: MTLDevice, camera: Camera) {
        sun = Sphere(device: device)
        ground = Plane(device: device)
        grass = Instance(device: device, modelName: "grass", instances: 10000)
        mushroom = Model(device: device, modelName: "mushroom")
        super.init(device: device, camera: camera)

        setupScene()


    }

    func setupScene() {
        add(childNode: sun)
        add(childNode: ground)
        add(childNode: grass)
        add(childNode: mushroom)

        ground.materialColor = float4(0.4, 0.3, 0.1, 1) // brown
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
                blade.materialColor = greens[Int(arc4random_uniform(3))]
                blade.rotation.y = CGFloat.random(min: 0, max: 360).toFloat
            }
        }

        grass.position.x = -12
        grass.position.z = -12

        mushroom.position.x = -6
        mushroom.position.z = -8
        mushroom.scale = float3(2)

        sun.materialColor = float4(1, 1, 0, 1) // yellow
        sun.position.y = 30
        sun.position.x = 6
        sun.scale = float3(2)

        //camera.fieldOfView = 25
        camera.set(position: float3(0, 10, -20), viewpoint: float3(0,0,0), up: float3(0,1,0))
    }

    override func update(deltaTime: Float) {
        super.update(deltaTime: deltaTime)

        cameraRotation += deltaTime * 20
        camera.rotateAroundPoint(distance: 50, viewpoint: float3(0,0, 0), angle: cameraRotation, y: 20)

    }
}
