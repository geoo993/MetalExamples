
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

    //let torusKnot: TorusKnot
    //let cube: Cube
    let mushroom: Model

    var previousTouchLocation: CGPoint = .zero
    var cameraRotation: Float = 0
    var leftCameraAngle: Float = 0
    var leftCameraDisplacement: Float = 0
    var rightCameraAngle: Float = 0
    var rightCameraDisplacement: Float = 0

    override init(device: MTLDevice, camera: Camera) {
        //torusKnot = TorusKnot(device: device, imageName: "blue-frozen-water.jpg")
        //cube = Cube(device: device)
        mushroom = Model(device: device, modelName: "mushroom")
        super.init(device: device, camera: camera)
        //add(childNode: torusKnot)
        //add(childNode: cube)
        add(childNode: mushroom)



        //torusKnot.position = float3(0, 0, 0)
        //torusKnot.scale = float3(0.8)

        light.position = float3(-5, 10, 0)
        light.color = float3(1, 1, 1)
        light.direction = float3(-2, 0, 0)
        light.ambient = float3(0.2, 0.2, 0.2)
        light.diffuse = float3(0.8, 0.9, 0.1)
        light.specular = float3(1, 1.0, 1.0)
        light.exponent = 16.0
        light.cutOff = 30.0

        spotLight.point.base.color = float3(1, 1, 1)
        spotLight.point.base.intensity = 25.0
        spotLight.point.position = float3(-5, 10, 0)
        spotLight.point.base.ambient = float3(0.5, 0.5, 0.5)
        spotLight.point.base.diffuse = float3(0.9, 0.9, 0.91)
        spotLight.point.base.specular = float3(1.0, 1.0, 1.0)
        spotLight.point.atten.constants = 1.0
        spotLight.point.atten.linear = 0.2
        spotLight.point.atten.exponent = 0.032
        spotLight.direction = float3(-2, 0, 0)
        spotLight.point.range = 22
        spotLight.cutoff = 4.6
        spotLight.outerCutoff = 2.85

        mushroom.position = float3(0, -1, 0)
        mushroom.material.ambient = float3(0.4, 0.4, 0.4)
        mushroom.material.diffuse = float3(0.8, 0.8, 0.8)
        mushroom.material.specular = float3(0.98, 0.98, 0.98)
        mushroom.material.shininess = 12.0
        mushroom.material.useTexture = true
        mushroom.material.color = float4(1, 0, 0, 1)

        camera.set(position: float3(10,0,0), viewpoint: mushroom.position, up: float3(0,1,0))
    }

    override func update(deltaTime: Float) {
        super.update(deltaTime: deltaTime)
        camera.updateRotation(angle: leftCameraAngle, displacement: leftCameraDisplacement)
        camera.updateMovement(deltaTime: deltaTime, angle: rightCameraAngle, displacement: rightCameraDisplacement)

        //cameraRotation += deltaTime * 10
        //camera.rotateAroundPoint(distance: 10, viewpoint: mushroom.position, angle: cameraRotation, y: 0)
        spotLight.point.position = camera.position
        spotLight.direction = camera.front

        //cube.materialColor = float4(1)
        //cube.position = light.position
        //cube.scale = float3(0.8)
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
}
