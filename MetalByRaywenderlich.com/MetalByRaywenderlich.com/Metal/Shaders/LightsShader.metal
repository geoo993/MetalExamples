//
//  MultiLightsShader.metal
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 23/07/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

// http://metalbyexample.com/modern-metal-2/
// https://learnopengl.com/Lighting/Multiple-lights

#include <metal_stdlib>
#include "Shader.h"
using namespace metal;


float4 CalcLight(BaseLight base, MaterialInfo material, float3 lightDirection, float3 viewDirection, float3 normal)
{

    // Ambient
    float3 ambientColor = base.ambient;

    // Diffuse
    float3 diffuseFactor = saturate(dot(normal, lightDirection));
    float3 diffuseColor = diffuseFactor * base.diffuse * base.intensity;

    // Specular
    float3 halfWay = normalize(lightDirection + viewDirection);
    float specularFactor = powr(saturate(dot(normal, halfWay)), material.shininess);
    float3 specularColor = specularFactor * base.specular * base.intensity;

    float3 color =  saturate(ambientColor + diffuseColor)
    * material.color.xyz * base.color
    + specularColor * base.color;

    return float4(color, 1);
}

float4 CalcDirectionalLight(DirectionalLight directionalLight, MaterialInfo material, float3 viewDirection, float3 normal)
{
    return CalcLight(directionalLight.base, material, -directionalLight.direction, viewDirection, normal);
}

float4 CalcPointLight(PointLight pointLight, MaterialInfo material, float3 vertexPosition, float3 viewDirection, float3 normal)
{
    float3 lightDirection = pointLight.position - vertexPosition;
    float distanceToPoint = length(lightDirection);

    if(distanceToPoint > pointLight.range) {
        return float4(0.0, 0.0, 0.0, 0.0);
    }

    float4 color = CalcLight(pointLight.base, material, normalize(lightDirection), viewDirection, normal);

    // Attenuation
    /*
    float attenuation =
    pointLight.atten.continual +
    pointLight.atten.linear *
    distanceToPoint +
    pointLight.atten.exponent *
    (distanceToPoint * distanceToPoint) +
    0.0001f;
    return color / attenuation;
    */

     float attenuation =
     1.0f / (pointLight.atten.continual +
     pointLight.atten.linear *
     distanceToPoint +
     pointLight.atten.exponent *
     (distanceToPoint * distanceToPoint));
     return color * attenuation;
}

float4 CalcSpotLight(SpotLight spotLight, MaterialInfo material, float3 vertexPosition, float3 viewDirection, float3 normal)
{
    float3 lightDirection = normalize(vertexPosition - spotLight.pointLight.position);

    // Intensity
    float spotFactor = dot(lightDirection, spotLight.direction);
    float4 color = float4(0.0,0,0,0);

    if(spotFactor > spotLight.cutOff)
    {
        float epsilon = spotLight.cutOff - spotLight.outerCutOff;
        float intensity = clamp((spotFactor - spotLight.outerCutOff) / epsilon, 0.0f, 1.0f);
        //float intensity = (1.0f - (1.0f - spotFactor) / (1.0 - spotLight.cutOff));

        color = CalcPointLight(spotLight.pointLight, material, vertexPosition, viewDirection, normal) * intensity;
    }

    return color;
}


fragment float4 lighting_fragment_shader(VertexOut vertexIn [[ stage_in ]],
                                        constant CameraInfo &camera [[ buffer(BufferIndexCameraInfo) ]],
                                        constant MaterialInfo &material [[ buffer(BufferIndexMaterialInfo) ]],
                                        constant DirectionalLight *dirlights [[ buffer(BufferIndexDirectionalLightInfo) ]],
                                        constant PointLight *pointlights [[ buffer(BufferIndexPointLightInfo) ]],
                                        constant SpotLight *spotlights [[ buffer(BufferIndexSpotLightInfo) ]],
                                        texture2d<float> texture [[ texture(TextureIndexColor) ]],
                                        sampler sampler2d [[ sampler(0) ]]) {

    // Properties
    // extract color from current fragmnet coordinates
    float4 textcolor = texture.sample(sampler2d, vertexIn.textureCoordinates);

    //float4 c = material.color;
    float3 p = vertexIn.fragPosition; // Eye coordinates are computed as part of the camera model
    float3 n = normalize(vertexIn.normal);
    float3 v = normalize(camera.position - vertexIn.fragPosition.xyz); // viewDirection

    float4 finalColor = float4(0.0,0,0,0);
    const int NUMBER_OF_DIRECTIONAL_LIGHTS = 1;
    const int NUMBER_OF_POINT_LIGHTS = 5;
    const int NUMBER_OF_SPOT_LIGHTS = 1;

    // Directional lighting
    for (int i = 0; i < NUMBER_OF_DIRECTIONAL_LIGHTS; i++) {
        float4 directionalLight = CalcDirectionalLight(dirlights[i], material, v, n);
        finalColor += directionalLight;
    }

    // Point lights
    for (int i = 0; i < NUMBER_OF_POINT_LIGHTS; i++) {
        float4 pointL = CalcPointLight(pointlights[i], material, p, v, n);
        //finalColor += pointL;
    }

    // Spot light
    for (int i = 0; i < NUMBER_OF_SPOT_LIGHTS; i++) {
        float4 spotL = CalcSpotLight(spotlights[i], material, p, v, n);
        finalColor += spotL;
    }

    //if (material.useTexture == true) {
    //    return textcolor * finalColor;
    //} else {
        return finalColor;
    //}
}
