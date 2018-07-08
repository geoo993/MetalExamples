//
//  LightShader.metal
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 03/07/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "Shader.h"

float3 CalcLight(BaseLight base, MaterialInfo material, CameraInfo camera,
                 float3 direction, float3 normal, float3 position)
{

    float3 diffuseColor = float3(0.0);
    float3 specularColor = float3(0.0);
    float3 ambientColor = float3(0.0);

    // Ambient
    ambientColor = base.ambient * material.ambient;

    // Diffuse
    float diffuseFactor = max(dot(direction, normal), 0.0);
    diffuseColor = base.diffuse * material.diffuse * diffuseFactor;

    // Specular
    float3 directionToEye = normalize(camera.view - position); // viewDirection
    float3 halfDirection = normalize(direction + directionToEye);

    if(diffuseFactor > 0.0)
    {
        specularColor = base.specular
        * material.specular
        * pow(max(dot(halfDirection, normal), 0.0), material.shininess);
    }

    return ambientColor + diffuseColor + specularColor;
}

float3 CalcDirectionalLight(DirectionalLight directionalLight, MaterialInfo material, CameraInfo camera,
                            float3 normal, float3 fragPosition)
{
    return CalcLight(directionalLight.base, material, camera, -directionalLight.direction, normal, fragPosition);
}

float3 CalcPointLight(PointLight pointLight, MaterialInfo material, CameraInfo camera, float3 normal, float3 position)
{

    float3 lightDirection = normalize(pointLight.position - position);
    float distanceToPoint = length(lightDirection);

    if(distanceToPoint > pointLight.range)
        return float3(0.0, 0.0, 0.0);

    float3 color = CalcLight(pointLight.base, material, camera, lightDirection, normal, position);

    // Attenuation
    float attenuation =
    pointLight.atten.constants +
    pointLight.atten.linear *
    distanceToPoint +
    pointLight.atten.exponent *
    distanceToPoint *
    distanceToPoint +
    0.0001f;

    return color / attenuation;
}

float3 CalcSpotLight(SpotLight spotLight, MaterialInfo material, CameraInfo camera, float3 normal, float3 position)
{
    float3 lightDirection = normalize(spotLight.point.position - position);

    // Intensity
    float angle = acos(dot(-lightDirection, spotLight.direction));
    float cutoff = radians(clamp(spotLight.cutoff, 0.0f, 90.0));

    float3 color = float3(0.0);

    if(angle < cutoff)
    {
        float spotFactor = pow(dot(-lightDirection, spotLight.direction), spotLight.point.atten.exponent);

        color = CalcPointLight(spotLight.point, material, camera, normal, position) * spotFactor;
    }

    return color;
}


fragment half4 spot_light_shader_fragment(VertexOut vertexIn [[ stage_in ]],
                                           constant CameraInfo &camera [[ buffer(3) ]],
                                           constant MaterialInfo &material [[ buffer(4) ]],
                                           constant SpotLight &light [[ buffer(8) ]],
                                           texture2d<float> texture [[ texture(0) ]],
                                           sampler sampler2d [[ sampler(0) ]]) {

    // extract color from current fragmnet coordinates
    float4 textcolor = texture.sample(sampler2d, vertexIn.textureCoordinates);
    //float4 color = vertexIn.color;
    float3 p = vertexIn.fragPosition; // Eye coordinates are computed as part of the camera model
    float3 n = normalize(vertexIn.normal);
    float3 finalColor = float3(0.0f);

    float3 spotL = CalcSpotLight(light, material, camera, n, p);
    finalColor += spotL;

    textcolor = textcolor * float4(finalColor, 1);

    if (textcolor.a == 0.0)
    discard_fragment();

    return half4(textcolor.r, textcolor.g, textcolor.b, 1);
}
