
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

    let torusKnot: TorusKnot
    let cube: Cube
    let mushroom: Model

    var previousTouchLocation: CGPoint = .zero
    var cameraRotation: Float = 0

    override init(device: MTLDevice, camera: Camera) {
        torusKnot = TorusKnot(device: device, imageName: "blue-frozen-water.jpg")
        cube = Cube(device: device)
        mushroom = Model(device: device, modelName: "mushroom")
        super.init(device: device, camera: camera)
        add(childNode: torusKnot)
        add(childNode: cube)
        add(childNode: mushroom)



        torusKnot.position = float3(0, 0, 0)
        torusKnot.scale = float3(0.8)
        mushroom.shininess = 28.0

        light.position = float3(-5, 10, 0)
        light.color = float3(1, 1, 1)
        light.direction = float3(0, -1, 0)
        light.ambientIntensity = 0.2
        light.diffuseIntensity = 0.8
        light.specularIntensity = 1.0

//        dirLight.ambient = float3(0.2, 0.2, 0.2)
//        dirLight.diffuse = float3(0.8, 0.8, 0.8)
//        dirLight.specular = float3(1, 1.0, 1.0)

        mushroom.position = float3(2, 5, 0)
        mushroom.shininess = 48.0

        camera.set(position: float3(0,0,-19), viewpoint: torusKnot.position, up: float3(0,1,0))

    }

    override func update(deltaTime: Float) {
        super.update(deltaTime: deltaTime)

        cameraRotation += deltaTime * 10
        camera.rotateAroundPoint(distance: 20, viewpoint: torusKnot.position, angle: cameraRotation, y: 0)
        light.position = camera.position
        light.direction = camera.view

        cube.materialColor = float4(1)
        cube.position = light.position
        cube.scale = float3(0.8)
    }

    override func touchesBegan(_ view: UIView, touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        previousTouchLocation = touch.location(in: view)
    }

    override func touchesMoved(_ view: UIView, touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: view)
        let delta = CGPoint(x: previousTouchLocation.x - touchLocation.x,
                            y: previousTouchLocation.y - touchLocation.y)

        torusKnot.rotation.x += Float(delta.y) * camera.sensitivity
        torusKnot.rotation.y += Float(delta.x) * camera.sensitivity

        previousTouchLocation = touchLocation
    }
}
