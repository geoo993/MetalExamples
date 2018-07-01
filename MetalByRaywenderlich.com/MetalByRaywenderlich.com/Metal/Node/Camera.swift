//
//  Camera.swift
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 30/06/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import MetalKit

class Camera {

    var position: float3       // The position of the camera's centre of projection

    //view and projection matrix
    var perspectiveProjectionMatrix: matrix_float4x4 // Perspective projection matrix
    var orthographicProjectionMatrix: matrix_float4x4 // Orthographic projection matrix
    var viewMatrix: matrix_float4x4

    var view: float3 // The camera's viewpoint (point where the camera is looking)

    var strafe: float3        // The camera's strafe vector

    var front: float3               // The camera's forward vector
    var back: float3                // The camera's backward vector
    var left: float3               // The camera's left vector
    var right: float3               // The camera's right vector
    var up: float3                  // The camera's up vector
    var down: float3                // The camera's down vector

    var worldUp: float3            // The worlds up vector, the original position of the world

    // Eular Angles
    var fieldOfView: Float           // The view from the camera
    var yaw: Float
    var pitch: Float

    // Camera options
    var movementSpeed: Float         // How fast the camera moves
    var sensitivity: Float      // How sensitive mouse is

    // Screen
    var screenSize: CGSize           // size of the screen window

    init(fov: Float, size: CGSize, zNear: Float, zFar: Float) {
        screenSize = size
        perspectiveProjectionMatrix = matrix_identity_float4x4
        orthographicProjectionMatrix = matrix_identity_float4x4
        viewMatrix = matrix_identity_float4x4
        view = float3(0.0)
        front = float3(0.0, 0.0, -1.0)
        back = float3(0.0, 0.0, 1.0)
        left = float3(-1.0, 0.0, 0.0)
        right = float3(10.0, 0.0, 0.0)
        up = float3(0.0, 1.0, 0.0)
        down = float3(0.0, -1.0, 0.0)
        worldUp = float3( 0.0, 1.0, 0.0)
        pitch = 0.1
        yaw = -90
        fieldOfView = fov
        strafe = float3( 0.0, 0.0, 0.0)
        movementSpeed = 50
        sensitivity = 0.25
        screenSize = size
        position = float3(0)

        //rotation = float3(0)
        //scale = float3(1)
        setPerspectiveProjectionMatrix(fieldOfView: fov, aspectRatio: Float(screenSize.width / screenSize.height), nearClippingPlane: 0.1, farClippingPlane: 1000)
        setOrthographicProjectionMatrix(width: Float(screenSize.width), height: Float(screenSize.height), zNear: zNear, zFar: zFar)

        updateCameraVectors()
    }


    // Calculates the front vector from the Camera's (updated) Eular Angles
    func updateCameraVectors()
    {

        back = normalize(front) * -1.0

        // Also re-calculate the Right and Up vector
        right = normalize(cross(front, worldUp))  // Normalize the vectors, because their length gets closer to 0 the more you look up or down which results in slower movement.
        left = normalize(right) * -1.0

        // Up vector : perpendicular to both direction and right
        up = normalize( cross(right, front ) )
        down = normalize(up) * -1.0

        view = position + front
        viewMatrix = lookAt(
            eye: position, // what position you want the camera to be at when looking at something in World Space
            center: view, // // what position you want the camera to be  looking at in World Space, meaning look at what(using vec3) ?  // meaning the camera view point
            up: up  //which direction is up, you can set to (0,-1,0) to look upside-down
        )

        // https://gamedev.stackexchange.com/questions/50963/how-to-extract-euler-angles-from-transformation-matrix
        //let xRotation = rota

    }


    // Set the camera at a specific position, looking at the view point, with a given up vector
    func set(position: float3, viewpoint: float3, up: float3) {
        self.position = position
        self.front = normalize(viewpoint - position) // finding front vector
        self.up = up
        self.worldUp = float3( 0.0, 1.0, 0.0 )

        updateCameraVectors()
    }


    // Rotate the camera view point -- this effectively rotates the camera since it is looking at the view point
    func rotateViewPoint(angle: Float, vPoint: float3) {
        let vView = view - position;// direction vector

        let rotation = rotate(m: matrix_identity_float4x4, angle: radians(degrees: angle), axis: vPoint)
        let newView = rotation * float4(vView, 1)

        self.front = normalize(float3(newView))

        updateCameraVectors()
    }

    func rotateAroundPoint(distance: Float, viewpoint: float3, angle: Float, y: Float) {

        let radian = radians(degrees: angle)

        let camX = viewpoint.x + (distance * cosf(radian))
        let camY = y
        let camZ = viewpoint.z + (distance * sinf(radian))

        // Set the camera position and lookat point
        let position = float3(camX, camY, camZ)   // Camera position
        let look = viewpoint // Look at point
        let upV = float3(0.0, 1.0, 0.0) // Up vector

        set(position: position, viewpoint: look, up: upV);

    }

    func PositionInFrontOfCamera(distance: Float) -> float3 {
        return position + front * distance
    }

    // Strafe the camera (side to side motion) (Left - Right Motion)
    func strafe(direction: Float)
    {
        let speedratio: Float = 0.025
        let speed = speedratio * direction

        position.x = position.x + strafe.x * speed;
        position.z = position.z + strafe.z * speed;

        updateCameraVectors();
    }

    // Advance the camera (forward / backward motion)
    func advance(direction: Float)
    {
        let speedratio: Float = 0.025
        let speed = speedratio * direction
        let forwardView = normalize(view - position)
        position = position + forwardView * speed

        updateCameraVectors()
    }

    // Update the camera to respond to mouse motion for rotations and keyboard for translation
    func Update(deltaTime: Float)
    {
        let vector = cross(view - position, up);
        strafe = normalize(vector);

        updateCameraVectors()
    }


    // Set the camera perspective projection matrix to produce a view frustum with a specific field of view, aspect ratio,
    // and near / far clipping planes
    func setPerspectiveProjectionMatrix(fieldOfView: Float, aspectRatio: Float, nearClippingPlane: Float, farClippingPlane: Float){
        self.fieldOfView = fieldOfView;
        self.perspectiveProjectionMatrix = matrix_float4x4(projectionFov: radians(degrees: fieldOfView), aspect: aspectRatio, nearZ: nearClippingPlane,
        farZ: farClippingPlane)

    }

    // The the camera orthographic projection matrix to match the width and height passed in
    func setOrthographicProjectionMatrix(width: Float, height: Float, zNear: Float, zFar: Float){
        orthographicProjectionMatrix = ortho(left: 0, right: width, bottom: 0, top: height, zNear: zNear, zFar: zFar)
    }

    func setOrthographicProjectionMatrix(value: Float, zNear: Float, zFar: Float)
    {
        orthographicProjectionMatrix = ortho(left: -value, right: value, bottom: -value, top: value, zNear: zNear, zFar: zFar)
    }


    // The normal matrix is used to transform normals to eye coordinates -- part of lighting calculations
    func ComputeNormalMatrix(modelMatrix: matrix_float4x4) -> matrix_float3x3
    {
        //return glm::transpose(glm::inverse(glm::mat3(modelMatrix)));
        return matrix_float3x3(modelMatrix).inverse.transpose
    }


}
