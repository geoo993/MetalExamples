//
//  BoxRenderer.swift
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 16/08/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

// https://developer.apple.com/videos/play/wwdc2016/602

import Foundation
import Metal
import simd
import MetalKit
import AppCore

//struct Constants {
//    var modelViewProjectionMatrix = matrix_identity_float4x4
//    var normalMatrix = matrix_identity_float3x3
//}

public class BoxRenderer: NSObject {
    weak var view: MTKView!

    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let renderPipelineState: MTLRenderPipelineState
    let depthStencilState: MTLDepthStencilState
    let sampler: MTLSamplerState
    let texture: MTLTexture
    let mesh: Mesh

    var time = TimeInterval(0.0)
    var constants = Uniform()

    init(mtkView: MTKView) {

        view = mtkView

        // Use 4x MSAA multisampling
        view.sampleCount = 4
        // Clear to solid white
        view.clearColor = MTLClearColorMake(1, 1, 1, 1)
        // Use a BGRA 8-bit normalized texture for the drawable
        view.colorPixelFormat = .bgra8Unorm
        // Use a 32-bit depth buffer
        view.depthStencilPixelFormat = .depth32Float

        // Ask for the default Metal device; this represents our GPU.
        if let defaultDevice = MTLCreateSystemDefaultDevice() {
            device = defaultDevice
        }
        else {
            fatalError("Metal is not supported")
        }

        // Create the command queue we will be using to submit work to the GPU.
        commandQueue = device.makeCommandQueue()!

        // Compile the functions and other state into a pipeline object.
        do {
            renderPipelineState = try BoxRenderer.buildRenderPipelineWithDevice(device, view: mtkView)
        }
        catch let error {
            fatalError("Unable to compile render pipeline state, \(error)")
        }

        mesh = Mesh(cubeWithSize: 1.0, device: device)!

        do {
            texture = try BoxRenderer.buildTexture(name: "checkerboard", device)
        }
        catch let error {
            fatalError("Unable to load texture from main bundle, \(error)")
        }

        // Make a depth-stencil state that passes when fragments are nearer to the camera than previous fragments
        depthStencilState = BoxRenderer.buildDepthStencilStateWithDevice(device, compareFunc: .less, isWriteEnabled: true)

        // Make a texture sampler that wraps in both directions and performs bilinear filtering
        sampler = BoxRenderer.buildSamplerStateWithDevice(device, addressMode: .repeat, filter: .linear)

        super.init()

        // Now that all of our members are initialized, set ourselves as the drawing delegate of the view
        view.delegate = self
        view.device = device
    }

    class func buildRenderPipelineWithDevice(_ device: MTLDevice, view: MTKView) throws -> MTLRenderPipelineState {
        // The default library contains all of the shader functions that were compiled into our app bundle
        let library = device.makeDefaultLibrary()!

        // Retrieve the functions that will comprise our pipeline
        let vertexFunction = library.makeFunction(name: "vertex_transform")
        let fragmentFunction = library.makeFunction(name: "fragment_lit_textured")

        // A render pipeline descriptor describes the configuration of our programmable pipeline
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.label = "Render Pipeline"
        pipelineDescriptor.sampleCount = view.sampleCount
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = view.depthStencilPixelFormat

        return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }

    class func buildTexture(name: String, _ device: MTLDevice) throws -> MTLTexture {
        let textureLoader = MTKTextureLoader(device: device)
        let asset = NSDataAsset.init(name: name)
        if let data = asset?.data {
            return try textureLoader.newTexture(data: data, options: [:])
        } else {
            fatalError("Could not load image \(name) from an asset catalog in the main bundle")
        }
    }

    class func buildSamplerStateWithDevice(_ device: MTLDevice,
                                           addressMode: MTLSamplerAddressMode,
                                           filter: MTLSamplerMinMagFilter) -> MTLSamplerState
    {
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.sAddressMode = addressMode
        samplerDescriptor.tAddressMode = addressMode
        samplerDescriptor.minFilter = filter
        samplerDescriptor.magFilter = filter
        return device.makeSamplerState(descriptor: samplerDescriptor)!
    }

    class func buildDepthStencilStateWithDevice(_ device: MTLDevice,
                                                compareFunc: MTLCompareFunction,
                                                isWriteEnabled: Bool) -> MTLDepthStencilState
    {
        let desc = MTLDepthStencilDescriptor()
        desc.depthCompareFunction = compareFunc
        desc.isDepthWriteEnabled = isWriteEnabled
        return device.makeDepthStencilState(descriptor: desc)!
    }

    func updateWithTimestep(_ timestep: TimeInterval)
    {
        // We keep track of time so we can animate the various transformations
        time = time + timestep

        let modelMatrix = matrix_float4x4.init(rotationAbout: vector_float3(0.7, 1, 0), by:  Float(time) * 0.5)

        // So that the figure doesn't get distorted when the window changes size or rotates,
        // we factor the current aspect ration into our projection matrix. We also select
        // sensible values for the vertical view angle and the distances to the near and far planes.
        let viewSize = self.view.bounds.size
        let aspectRatio = Float(viewSize.width / viewSize.height)
        let verticalViewAngle: Float = Float(65).toRadians
        let nearZ: Float = 0.1
        let farZ: Float = 100.0
        constants.projectionMatrix = matrix_float4x4(perspectiveProjectionFov: verticalViewAngle, aspectRatio: aspectRatio, nearZ: nearZ, farZ: farZ)

        constants.viewMatrix = matrix_float4x4.makeLookAt(eyeX: 0, 0, 2.5, 0, 0, 0, 0, 1, 0)

        // The combined model-view-projection matrix moves our vertices from model space into clip space
        constants.modelMatrix = modelMatrix
        constants.normalMatrix = modelMatrix.upperLeft3x3().transpose.inverse
    }

    func render(_ view: MTKView) {
        // Our animation will be dependent on the frame time, so that regardless of how
        // fast we're animating, the speed of the transformations will be roughly constant.
        let timestep = 1.0 / TimeInterval(view.preferredFramesPerSecond)
        updateWithTimestep(timestep)

        // Our command buffer is a container for the work we want to perform with the GPU.
        let commandBuffer = commandQueue.makeCommandBuffer()!

        // Ask the view for a configured render pass descriptor. It will have a loadAction of
        // MTLLoadActionClear and have the clear color of the drawable set to our desired clear color.
        let renderPassDescriptor = view.currentRenderPassDescriptor

        if let renderPassDescriptor = renderPassDescriptor {
            // Create a render encoder to clear the screen and draw our objects
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!

            renderEncoder.pushDebugGroup("Draw Cube")

            // Since we specified the vertices of our triangles in counter-clockwise
            // order, we need to switch from the default of clockwise winding.
            renderEncoder.setFrontFacing(.counterClockwise)

            renderEncoder.setDepthStencilState(depthStencilState)

            // Set the pipeline state so the GPU knows which vertex and fragment function to invoke.
            renderEncoder.setRenderPipelineState(renderPipelineState)

            // Bind the buffer containing the array of vertex structures so we can
            // read it in our vertex shader.
            renderEncoder.setVertexBuffer(mesh.vertexBuffer, offset:0, index:0)

            // Bind the uniform buffer so we can read our model-view-projection matrix in the shader.
            renderEncoder.setVertexBytes(&constants, length: MemoryLayout<Uniform>.size, index: 1)

            // Bind our texture so we can sample from it in the fragment shader
            renderEncoder.setFragmentTexture(texture, index: 0)

            // Bind our sampler state so we can use it to sample the texture in the fragment shader
            renderEncoder.setFragmentSamplerState(sampler, index: 0)

            // Issue the draw call to draw the indexed geometry of the mesh
            renderEncoder.drawIndexedPrimitives(type: mesh.primitiveType,
                                                indexCount: mesh.indexCount,
                                                indexType: mesh.indexType,
                                                indexBuffer: mesh.indexBuffer,
                                                indexBufferOffset: 0)

            renderEncoder.popDebugGroup()

            // We are finished with this render command encoder, so end it.
            renderEncoder.endEncoding()

            // Tell the system to present the cleared drawable to the screen.
            if let drawable = view.currentDrawable
            {
                commandBuffer.present(drawable)
            }
        }

        // Now that we're done issuing commands, we commit our buffer so the GPU can get to work.
        commandBuffer.commit()
    }
}

extension BoxRenderer: MTKViewDelegate {
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {

    }

    public func draw(in metalView: MTKView)
    {
        render(metalView)
    }
}
