
// ------ Textures -------
// The Metal sampler state, tells the GPU how to use the texture.
// just like building the pipelineState, we build the sampler state using an MTLSamplerDescriptor,
// and then describe its properties.
// The filetring mode describes how the missing pixels are filled when you resize an image.
// This can be either linear or nearest, when you make an image bigger, if its an photo you want
// the missing pixels to be averaged from neabouring pixels.
// This smooths the missing data, this filtering mode is Linear.
// However if you are doing pixel art, you probably want to repeat each pixels,
// and this filtering mode is Nearest.
// Mipmapping is used for the Level Of Detail. Mipmaps are images of different sizes.
// If your model is at the front of the scene, you probably want a detailed smooth texture.
// And if that texture is at the back of the scene, you might get unwanted artifacs when the image is resized
// The sampler state has some properties where you can set the filtering mode for resizing between mipmap levels
// We address our texturing coordinates using values between 0 and 1, but you can mipmap outside 0 and 1.
// Which you can map outside 0 and 1, and the sampler state has properties
// where you can describe what happens outside those limits. you just repeat the edges of the texture,
// or repeat the whole texture.


import MetalKit

protocol Texturable {
  var texture: MTLTexture? { get set }
}

extension Texturable {
    func setTexture(device: MTLDevice, imageName: String) -> MTLTexture? {
        let textureLoader = MTKTextureLoader(device: device)

        // Loading texure
        var texture: MTLTexture? = nil
        let textureLoaderOptions: [MTKTextureLoader.Option: Any]

        if #available(iOS 10.0, *) {
            textureLoaderOptions = [.origin : MTKTextureLoader.Origin.bottomLeft]
        } else {
            textureLoaderOptions = [:]
        }

        // load texture using the passed in image name
        if let textureURL = Bundle.main.url(forResource: imageName, withExtension: nil) {
            do {
                texture = try textureLoader.newTexture(URL: textureURL, options: textureLoaderOptions)
            } catch {
                print("texture not created")
            }
        }

        // when you notice that the image is pixelated, this is becuase the default sampler uses filter mode Nearest
        return texture
    }
}
