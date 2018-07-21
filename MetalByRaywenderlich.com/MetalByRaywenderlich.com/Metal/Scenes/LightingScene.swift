
// phong shading is a very common technique in computer graphics to calculate shaded surfaces based
// on the color and lighting at each pixel.
// phong shading has 3 parts to it.
// firstly the Ambient light, Ambient light is all around us.
// the we have Diffuse lighting, we have already given some of our objects a material color.
// this materialColor should be brighter when the object is facing the light,
// and when any other part of the object is facing away from from the light, it should diffuse gradually
// darker, the material color should interact with the lights color.
// lastly we have the Specular highlight, this is light bouncing off the object and gives us the visual
// clue about how shiny an object is. A wood surface would not have much of a specular highlight
// while a shiny plastic ball would have a very intense specular highlight.
// using lighting we will need to work out which direction, each fragment of the model is facing
// and calculate the amount of color each fragment should receive from the light.
// All vertices can have a normal vector associated with them. you can think of a vector as an
// arrow pointing out to a certain direction.
// when you add a light to the scene, the light has a direction also. each of these directions is a vector.
// and by caluclating the difference between each normal vector and the light vector, we can calculate
// which part of the model are in shade.
// Comparing the light vector with the normal vector, if the vectors are pointing in the same direction,
// the dot product will be 1, and that part of the model should be shaded. if the vectors are pointing
// towards the light the dot product will be -1 and that part of the model will be fully lit.
// The way we calculate the lighting will be similar to the way we calculate the ambient lighting.

import MetalKit

class LightingScene: Scene {

    var cubes = [Cube]()
    var cubesColor = float3(1.0)
    var pointLightCubes = [Cube]()
    var lightIntensity: Float = 0.7
    var lightPower: Float = 1
    var materialShininess: Float = 32

    var cubesPosition: [float3] = [
        float3(-1.0, -4.0, -1.0),
        float3(-8.0, 7.0, 5.0),
        float3(-5.0, 3.0, -2.0),
        float3(2.0, 5.0, 8.0),
        float3(-2.0, 8.0, -9.0),
        float3(4.0, -1.0, -2.0),
        float3(9.0, -5.0, 3.0),
        float3(-8.0, 2.0, 8.0)
    ]

    let directionalLightsDirections: [float3] = [
        float3(  -0.2, -1.0, -0.3)
    ]

    var pointLightPositions: [float3] = [
        float3(  1.0,  3.0,  -2.0      ),
        float3(  -5.7,  0.2,  2.0      ),
        float3(  2.3, -3.3, -4.0      ),
        float3(  -4.0,  2.0, -12.0    ),
        float3(  0.0,  0.0, -3.0     )
    ]

    var pointlightsColours: [float3] = [
        float3(1.0, 1.0, 0.0),
        float3(0.4, 0.6, 0.7),
        float3(0.9, 0.1, 0.4),
        float3(0.6, 0.2, 0.25),
        float3(0.3, 0.5, 0.2),
    ]


    var previousTouchLocation: CGPoint = .zero
    var cameraRotation: Float = 0
    var leftCameraAngle: Float = 0
    var leftCameraDisplacement: Float = 0
    var rightCameraAngle: Float = 0
    var rightCameraDisplacement: Float = 0

    override init(mtkView: MTKView, camera: Camera) {
        super.init(mtkView: mtkView, camera: camera)
        name = "Lighting scene"

    }

    override func setup(view: MTKView) {
        super.setup(view: view)
        for i in 0..<cubesPosition.count {
            let angle: Float = 20.0 * i.toFloat
            let position: float3 = cubesPosition[i]
            let cube = Cube(mtkView: view, imageName: "container.png", fragmentShader: .lighting_fragment_shader)
            //let cube = Model(device: device, modelName: "mushroom", fragmentShader: .lighting_fragment_shader)
            cube.position = position
            cube.rotation = float3(1.0, angle, 1.0)
            cube.scale = float3(2.0)

            cube.material.color = float4(cubesColor, 1)
            cube.material.shininess = materialShininess
            cube.material.useTexture = false

            add(childNode: cube)
            cubes.append(cube)

        }

        // Directional light
        for i in 0..<directionalLightsDirections.count {
            var base = BaseLight()
            let direction = directionalLightsDirections[i]
            base.color = float3(1.0, 1.0, 1.0)
            base.intensity = lightIntensity
            base.power = lightPower
            base.ambient = float3(0.05, 0.05, 0.05)
            base.diffuse = float3(0.4, 0.4, 0.4)
            base.specular = float3(0.5, 0.5, 0.5)
            let dirLight = DirectionalLight(base: base, direction: direction)
            dirLights.append(dirLight)
        }

        // Point Light
        for i in 0..<pointLightPositions.count {
            let position: float3 = pointLightPositions[i]
            let color: float3 = pointlightsColours[i];
            let light = Cube(mtkView: view, fragmentShader: .fragment_color)
            add(childNode: light)

            light.position = position
            light.scale = float3(0.4, 0.4, 0.4)
            light.material.color = float4(color.x, color.y, color.z, 1.0)
            light.material.shininess = 20
            light.material.useTexture = false
            pointLightCubes.append(light)

            var pointLight = PointLight()
            pointLight.position = position
            pointLight.base.color = color
            pointLight.base.intensity = lightIntensity
            pointLight.base.power = lightPower
            pointLight.base.ambient = float3(0.1, 0.1, 0.1)
            pointLight.base.diffuse = float3(0.8, 0.8, 0.8)
            pointLight.base.specular = float3(1.0, 1.0, 1.0)
            pointLight.atten.continual = 1.0
            pointLight.atten.linear = 0.09
            pointLight.atten.exponent = 0.32

            let range = caluclateRange(with: pointLight)
            pointLight.range = range

            pointLights.append(pointLight)
        }

        //Spot Light
        var spotLight = SpotLight()
        spotLight.pointLight.position = float3(-5, 10, 0)
        spotLight.pointLight.base.color = float3(1, 1, 1)
        spotLight.pointLight.base.intensity = lightIntensity
        spotLight.pointLight.base.power = lightPower
        spotLight.pointLight.base.ambient = float3(0.1, 0.1, 0.1)
        spotLight.pointLight.base.diffuse = float3(1.0, 1.0, 1.0)
        spotLight.pointLight.base.specular = float3(1.0, 1.0, 1.0)
        spotLight.pointLight.atten.continual = 1.0
        spotLight.pointLight.atten.linear = 0.09
        spotLight.pointLight.atten.exponent = 0.32
        spotLight.pointLight.range = caluclateRange(with: spotLight.pointLight)
        spotLight.direction = float3(-2, 0, 0)
        spotLight.cutOff = cos(radians(degrees: 12))
        spotLight.outerCutOff = cos(radians(degrees: 18))
        spotLights.append(spotLight)

    }

    func caluclateRange(with pointLight: PointLight) -> Float {
        let a: Float = pointLight.atten.exponent
        let b: Float = pointLight.atten.linear
        let COLOR_DEPTH: Float = 256
        let colorMax = pointLight.base.color.max() ?? 1
        let c: Float = pointLight.atten.continual - COLOR_DEPTH * pointLight.base.intensity * colorMax
        return (-b + sqrtf(b * b - 4 * a * c)) / (2 * a)
    }

    override func update(deltaTime: Float) {
        super.update(deltaTime: deltaTime)
        camera.updateRotation(angle: leftCameraAngle, displacement: leftCameraDisplacement)
        camera.updateMovement(deltaTime: deltaTime, angle: rightCameraAngle, displacement: rightCameraDisplacement)

        //cameraRotation += deltaTime * 10
        //camera.rotateAroundPoint(distance: 10, viewpoint: mushroom.position, angle: cameraRotation, y: 0)

        cubesColor.x = sin( time * 0.1 );
        cubesColor.y = sin( time * 0.06 );
        cubesColor.z = sin( time * 0.03 );
        for cube in cubes {
            cube.material.color = float4(cubesColor.x, cubesColor.y, cubesColor.z, 1)
            cube.material.shininess = materialShininess
        }

        for i in 0..<dirLights.count {
            var dirLight = dirLights[i]
            dirLight.base.intensity = lightIntensity
            dirLight.base.power = lightPower
            dirLight.base.color = float3(1.0, 1.0, 1.0)
            dirLight.base.ambient = float3(0.05, 0.05, 0.05)
            dirLight.base.diffuse = float3(0.4, 0.4, 0.4)
            dirLight.base.specular = float3(0.5, 0.5, 0.5)
        }

        for i in 0..<pointLights.count {
            let color: float3 = pointlightsColours[i];
            var pointLight = pointLights[i]
            pointLight.base.color = color
            pointLight.base.intensity = lightIntensity
            pointLight.base.power = lightPower
            pointLight.base.ambient = float3(0.1, 0.1, 0.1)
            pointLight.base.diffuse = float3(0.8, 0.8, 0.8)
            pointLight.base.specular = float3(1.0, 1.0, 1.0)
            pointLight.atten.continual = 1.0
            pointLight.atten.linear = 0.09
            pointLight.atten.exponent = 0.32

            let range = caluclateRange(with: pointLight)
            pointLight.range = range
        }

        for i in 0..<spotLights.count {
            var spotLight = spotLights[i]
            spotLight.pointLight.position = camera.position
            spotLight.pointLight.base.color = float3(1, 1, 1)
            spotLight.pointLight.base.intensity = lightIntensity
            spotLight.pointLight.base.power = lightPower
            spotLight.pointLight.base.ambient = float3(0.1, 0.1, 0.1)
            spotLight.pointLight.base.diffuse = float3(1.0, 1.0, 1.0)
            spotLight.pointLight.base.specular = float3(1.0, 1.0, 1.0)
            spotLight.pointLight.atten.continual = 1.0
            spotLight.pointLight.atten.linear = 0.09
            spotLight.pointLight.atten.exponent = 0.32
            spotLight.pointLight.range = caluclateRange(with: spotLight.pointLight)
            spotLight.direction = camera.front
            spotLight.cutOff = cos(radians(degrees: 12))
            spotLight.outerCutOff = cos(radians(degrees: 18))

        }

    }

    override func touchesBegan(_ view: UIView, touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        previousTouchLocation = touch.location(in: view)
    }

    override func touchesMoved(_ view: UIView, touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: view)
        //let delta = CGPoint(x: previousTouchLocation.x - touchLocation.x,
        //                    y: previousTouchLocation.y - touchLocation.y)

        //mushroom.rotation.x += Float(delta.y) * camera.sensitivity
        //mushroom.rotation.y += Float(delta.x) * camera.sensitivity

        previousTouchLocation = touchLocation
    }

    override func onSlider(_ type: SliderType, phase: UITouchPhase, value: Float) {
        switch type {
        case .intensity:
            lightIntensity = value
        case .power:
            lightPower = value
        case .shininess:
            materialShininess = value

        }
    }
}
