//
//  LightMixShader.metal
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 21/07/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

/*
    A shader is a small program that runs on the GPU, and in our sample project,
    we’ll need to deal with two flavors of shaders: vertex and fragment shaders.
    A vertex shader runs once per vertex, each time we draw our geometry.
    The vertex shader’s job is to transform vertex data from the coordinate space
    in which it was modeled into the coordinate space expected by the rest of the Metal rendering pipeline,
    which is called clip space.

    Clip Space
    Clip space is a coordinate space that describes which portion of the scene is visible to our virtual camera. Specifically, coordinates that are between -1 and 1 in the x and y axes and between 0 and 1 in the z axis in clip space are within the camera’s field of view. Any triangles outside of this box will not appear on the screen, and any triangle that intersects this box will be modified so that only its visible portion continues to the later stages of the pipeline. The process of removing invisible triangles entirely is called culling, and the process of preserving only the visible portion of partially-visible triangles is called clipping, hence the name of clip space.

    How we actually get from so-called model space to clip space is beyond the scope of this guide, but briefly, we do it by multiplying the positions of our vertices by a sequence of specially-computed matrices that result in our desired transformation. We’ll see some examples of transformation matrices below, including the projection matrix, which represents the last step that takes our vertices into clip space.

 */



// These lines import the Metal Standard Library into the global namespace.
// The Metal Standard Library contains many types and functions for doing vertex and matrix math,
// which is most of what you’ll be doing in the shaders.
#include <metal_stdlib>
#include "Main/Shader.h"
using namespace metal;

// http://metalbyexample.com/modern-metal-2/
// https://www.tomdalling.com/blog/modern-opengl/06-diffuse-point-lighting/
/* AMBIENT ILLUMINATION

 The ambient term in our lighting equation accounts for indirect illumination: light that arrives at a surface after it has “bounced” off another surface. Imagine a desk illuminated above by a fluorescent light: even if the light is the only source of illumination around, the floor beneath the desk will still receive some light that has bounced off the walls and floor. Since modeling indirect light is expensive, simplified lighting models such as ours include an ambient term as a “fudge factor,” a hack that makes the scene look more plausible despite being a gross simplification of reality.

 */

/* DIFFUSE ILLUMINATION

 Diffuse illumination represents the portion of light that arrives at a surface and then scatters uniformly in all directions. Think of a concrete surface or a matte wall. These surfaces scatter light instead of reflecting it like a mirror.

 Since we thought ahead and already have the surface normal and position in world space available in our fragment shader, we can compute the diffuse lighting term on a per-pixel basis.

 It turns out that there is a fairly simple relation between how much light is reflected diffusely from a surface and its orientation relative to the light source: the diffuse intensity is the dot product of the surface normal (N) and the light direction (L). Intuitively, this means that more light is reflected by a surface that is facing “toward” a light source than one to which the incident light is “glancing.”

 */

/* SPECULAR ILLUMINATION
 There is another component to illumination that is important for surfaces that reflect light in a more coherent fashion: the specular term. Surfaces where specular illumination dominates include metals, polished marble, and glass.

 In order to compute specular lighting, we need to know a couple of vector quantities in addition to the surface normal and light direction.

 The reason we need the world position of the vertex is that the vector from the viewing position to the surface affects the shape and position of the specular highlight, the exceptionally bright point on the surface where the most light is reflected from.

 Specifically, we’ll use an approximation to specular highlighting devised by Blinn that uses the so-called halfway vector, the vector that points midway between the direction to the light and the direction to the camera position. By taking the dot product of this halfway vector and the surface normal, we get an approximation to the shiny highlights that appear on reflective surfaces. Raising this dot product to a quantity called the specular power controls how “tight” the highlight is. A low specular power (near 1) creates very broad highlights, while a high specular power (say, 150) creates pinpoint highlights. If you’re interested in the theoretical grounding of the halfway vector, consult papers on the microfacet model of surfaces, first popularized by Cook and Torrance in 1982.

 We can update the fragment shader to compute the view vector (the vector that points from the surface to the camera) and the halfway vector. The dot product of these vectors indicates the “amount” of specular reflection the surface generates. We raise this value to the specular power as mentioned before to get the final specular factor, which is multiplied by the light color (not the base color 3) to get the specular term, which we add to the previously computed ambient-diffuse combination:
 
 */
fragment float4 fragment_light_mix_shader(VertexOut vertexIn [[ stage_in ]],
                                          constant CameraInfo &camera [[ buffer(BufferIndexCameraInfo) ]],
                                          constant MaterialInfo &material [[ buffer(BufferIndexMaterialInfo) ]],
                                          constant PointLight *lights [[buffer(BufferIndexPointLightInfo)]],
                                          texture2d<float, access::sample> texture [[ texture(TextureIndexColor) ]],
                                          sampler sampler2d [[sampler(0)]])
{

    float3 textcolor = texture.sample(sampler2d, vertexIn.textureCoordinates).rgb;
    float3 baseColor = material.useTexture ?  textcolor : material.color.xyz;
    float3 P = vertexIn.fragPosition.xyz;
    float3 N = normalize(vertexIn.normal);
    float3 V = normalize(camera.position - P);

    float3 finalColor(0, 0, 0);
    for (int i = 0; i < NUMBER_OF_POINT_LIGHTS; ++i) {
        PointLight light = lights[i];
        // Ambient
        float ambientCoefficient = light.base.ambient;
        float3 ambientIntensity = float3(ambientCoefficient, ambientCoefficient, ambientCoefficient);

        // Diffuse
        float3 L = normalize(light.position - P);
        float diffuseCoefficient = saturate(dot(N, L)); // we use the saturate function to clamp the result to the range of [0, 1].
        float3 diffuseIntensity = light.base.intensity * diffuseCoefficient;

        // Specular
        float3 H = normalize(L + V);
        float specularCoefficient = powr(saturate(dot(N, H)), material.shininess);
        float3 specularIntensity = light.base.specular * specularCoefficient;

        // Attenuation
        float D = length(light.position - P);
        float attenuation = 1.0 / (light.atten.continual + light.atten.linear * D + light.atten.exponent * (D * D));

        finalColor += attenuation * saturate(ambientIntensity + diffuseIntensity)
        * baseColor * light.base.color
        + specularIntensity * light.base.color;
    }
    return float4(finalColor, 1);
}
