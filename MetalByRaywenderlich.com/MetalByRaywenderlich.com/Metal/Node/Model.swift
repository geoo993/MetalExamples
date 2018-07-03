//
//  Model.swift
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 01/07/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//
// in 2015 Apple intoduced the Model IO framework
// using this framework we can import 3D assets of various types and describe how they should be rendered
// You can alos describe realistic lighting and materials.
// We use Model IO to process 3D model files.
// The .OBJ Format was developed many years ago by wavefront technologies.
// Its a format thta describes geometry in 3D.
// Model IO is an easy way of importing OBJ files, The WWDC 2015 video on Model IO is a recommened watch
// to see the posibilies of realistic rendering.
// To import a model you use a model url and a VertexDescriptor to define what attributes you
// need to create an MDLAsset. this MDLAsset is a container for objects, the objects could be lights for
// cameras or even matrix transform heirachy. The MDLAssets contains MDLMesh objects which have vertex buffers
// Using this MDLMesh you can generate stuff like, normals, or lighting information.
// We create MTKMesh for these Model IO Mesh objects and we are going to be able to send the MTK vertex buffers
// to the GPU


import MetalKit

class Model: Node {

    //MARK: - Renderable
    var pipelineState: MTLRenderPipelineState!
    var samplerState: MTLSamplerState!
    var depthStencilState: MTLDepthStencilState!
    var fragmentFunctionName: String = "fragment_shader"
    var vertexFunctionName: String = "vertex_shader"

    var vertexDescriptor: MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()

        // describe the position data
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0

        // describe the texture data
        vertexDescriptor.attributes[1].format = .float2
        vertexDescriptor.attributes[1].offset = MemoryLayout<Float>.stride * 3
        vertexDescriptor.attributes[1].bufferIndex = 0

        // describe the color data
        vertexDescriptor.attributes[2].format = .float4
        vertexDescriptor.attributes[2].offset = MemoryLayout<Float>.stride * 5
        vertexDescriptor.attributes[2].bufferIndex = 0

        // describe the normal data
        vertexDescriptor.attributes[3].format = .float3
        vertexDescriptor.attributes[3].offset = MemoryLayout<Float>.stride * 9
        vertexDescriptor.attributes[3].bufferIndex = 0

        // tell the vertex descriptor the size of the information held for each vertex
        vertexDescriptor.layouts[0].stride = MemoryLayout<Float>.stride * 12

        return vertexDescriptor
    }

    var uniform = Uniform()

    var drawType: MTLPrimitiveType = .triangle


    //MARK: - Properties
    var meshes: [AnyObject]?

    var texture: MTLTexture?

    //MARK: - initialise the Renderer with a device
    init(device:MTLDevice, modelName: String) {
        super.init()
        name = modelName
        loadModel(device: device, modelName: modelName)

        let imageName = modelName + ".png"
        if let texture = setTexture(device: device, imageName: imageName) {
            self.texture = texture
            fragmentFunctionName = "lit_textured_fragment"
        }

        pipelineState = buildPipelineState(device: device)
        samplerState = buildSamplerState(device: device)
        depthStencilState = buildDepthStencilState(device: device)
    }

    init(device:MTLDevice, modelName: String, imageName: String) {
        super.init()
        name = modelName
        loadModel(device: device, modelName: modelName)

        if let texture = setTexture(device: device, imageName: imageName) {
            self.texture = texture
            fragmentFunctionName = "lit_textured_fragment"
        }

        pipelineState = buildPipelineState(device: device)
        samplerState = buildSamplerState(device: device)
        depthStencilState = buildDepthStencilState(device: device)
    }

    func loadModel(device: MTLDevice, modelName: String) {
        guard let assetURL = Bundle.main.url(forResource: modelName, withExtension: "obj") else {
            fatalError("Asset \(modelName) does not exist.")
        }

        // Model IO requires a special Model IO vertex descriptor, we can use the MTKModel vertex descriptor
        let descriptor = MTKModelIOVertexDescriptorFromMetal(vertexDescriptor)

        // Model IO needs some further details about the model
        // these are description of the attributes
        // this is the position attributes
        let attributePosition = descriptor.attributes[0] as! MDLVertexAttribute
        attributePosition.name = MDLVertexAttributePosition
        descriptor.attributes[0] = attributePosition

        // here is the texture attributes
        let attributeTexture = descriptor.attributes[1] as! MDLVertexAttribute
        attributeTexture.name = MDLVertexAttributeTextureCoordinate
        descriptor.attributes[1] = attributeTexture

        // here is the color attributes
        let attributeColor = descriptor.attributes[2] as! MDLVertexAttribute
        attributeColor.name = MDLVertexAttributeColor
        descriptor.attributes[2] = attributeColor

        // here is the normals attributes
        let attributeNormal = descriptor.attributes[3] as! MDLVertexAttribute
        attributeNormal.name = MDLVertexAttributeNormal
        descriptor.attributes[3] = attributeNormal

        // to load the asset we need to create a MeshBuffer allocator
        // this handles all the loading and managing on the GPU of the vertex and index data
        let bufferAllocator = MTKMeshBufferAllocator(device: device)

        // load asset using the asset URL
        let asset = MDLAsset(url: assetURL,
                             vertexDescriptor: descriptor,
                             bufferAllocator: bufferAllocator)

        // asset bounding box
        let boundingBox = asset.boundingBox
        width = boundingBox.maxBounds.x - boundingBox.minBounds.x
        height = boundingBox.maxBounds.y - boundingBox.minBounds.y

        do {
            meshes = try MTKMesh.newMeshes(asset: asset, device: device).metalKitMeshes
        } catch {
            print("mesh error")
        }
    }


}

extension Model: Renderable {

    func doRender(commandEncoder: MTLRenderCommandEncoder, modelMatrix: matrix_float4x4, camera: Camera) {

        commandEncoder.setRenderPipelineState(pipelineState)
        commandEncoder.setFragmentSamplerState(samplerState, index: 0)

        
        commandEncoder.setFrontFacing(.counterClockwise)
        commandEncoder.setCullMode(.back)
        commandEncoder.setDepthStencilState(depthStencilState)

        // setup the matrices attributes
        // projection matrix
        // the projecttion matrix will project all the vertices back into clipping space
        uniform.projectionMatrix = camera.perspectiveProjectionMatrix

        // view matrix
        uniform.viewMatrix = camera.viewMatrix

        // model matrix
        uniform.modelMatrix = modelMatrix

        // normal matrix
        uniform.normalMatrix = camera.computeNormalMatrix(modelMatrix: modelMatrix)

        // materials
        uniform.materialColor = materialColor
        uniform.shininess = shininess
        uniform.specularIntensity = specularIntensity
        uniform.useTexture = useTexture

        commandEncoder.setVertexBytes(&uniform,
                                      length: MemoryLayout<Uniform>.stride,
                                      index: 1)

        if texture != nil {
            commandEncoder.setFragmentTexture(texture, index: 0)
        }


        guard let meshes = meshes as? [MTKMesh], meshes.count > 0 else { return }

        // Each MLKMesh will have one or more sub meshes with the index information.
        // To render the object we loop through MetalKit meshes, we get the VertexBuffer from the mesh
        // and set that as the GPU vertex buffer.
        for mesh in meshes {
            let vertexBuffer = mesh.vertexBuffers[0]
            commandEncoder.setVertexBuffer(vertexBuffer.buffer, offset: vertexBuffer.offset, index: 0)

            // then we loop through the MTLMesh sub meshes, and draw the group of meshes that belongs to the MTLMesh
            // using the submesh indicies.
            for submesh in mesh.submeshes {
                drawType = submesh.primitiveType
                commandEncoder.drawIndexedPrimitives(type: submesh.primitiveType,
                                                     indexCount: submesh.indexCount,
                                                     indexType: submesh.indexType,
                                                     indexBuffer: submesh.indexBuffer.buffer,
                                                     indexBufferOffset: submesh.indexBuffer.offset)
            }
        }

    }

}


extension Model: Texturable {
}
