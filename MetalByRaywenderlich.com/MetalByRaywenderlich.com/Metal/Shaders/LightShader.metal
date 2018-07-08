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
    //float diffuseFactor = dot(normal, -direction); //diff
    float diffuseFactor = max(dot(normal, -direction), 0.0f);
//    float diffuseFactor = max(dot(direction, normal), 0.0);

    float3 diffuseColor = float3(0.0);
    float3 specularColor = float3(0.0);
    float3 ambientColor = float3(0.0);

    if(diffuseFactor > 0.0f)
    {
        // Diffuse
        diffuseColor = base.ambient * base.color * base.intensity * diffuseFactor;
        //diffuseColor = base.diffuse * material.diffuse * diffuseFactor;

        // Ambient
        ambientColor = base.diffuse * diffuseColor;
        //ambientColor = base.ambient * material.ambient;

        // Specular
        float3 directionToEye = normalize(camera.view - position); // viewDirection

        float3 halfDirection = normalize(direction + directionToEye);

        float specularFactor = dot(halfDirection, normal); // spec

        //float specularFactor = dot(directionToEye, reflectDirection);
        specularFactor = pow(specularFactor, material.shininess);

        if(specularFactor > 0.0)
        //if(diffuseFactor > 0.0)
        {
            specularColor = base.specular * base.color * base.intensity * specularFactor ;
            //specularColor = base.specular * material.specular * pow(max(specularFactor, 0.0), material.shininess);
        }
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

    float3 lightDirection = normalize(position - pointLight.position);
    //float3 lightDirection = normalize(pointLight.position - position);
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
    float3 lightDirection = normalize(position - spotLight.point.position);
    //float3 lightDirection = normalize(spotLight.point.position - position);

    // Intensity
    float spotFactor = dot(lightDirection, spotLight.direction);
    float3 color = float3(0.0);

    if(spotFactor > spotLight.cutoff)
    {
        //float epsilon = (1.0 - spotLight.cutoff);
        //float intensity = (1.0 - (1.0 - spotFactor) / epsilon);

        float epsilon = (spotLight.cutoff - spotLight.outerCutoff);
        float intensity = clamp( (spotLight.outerCutoff - spotFactor ) / epsilon, 0.0, 1.0);

        color = CalcPointLight(spotLight.point, material, camera, normal, position) * intensity;
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
    float3 d = light.direction; // d is the spotlight direction (in eye coordinates)
    float3 s = normalize(light.point.position - p); // light direction is the normalised vector pointing to the light source
    //float3 v = normalize(-p);
    float3 v = normalize(camera.view - p);  // view direction is the normalised vector pointing to the camera
    float3 n = normalize(vertexIn.normal);   // normal, normalizing makes sure that the normal is a unit vector
    float3 h = normalize(s + v); // halfway vector between the vector pointing to the camera with the one pointing to light source
    float3 finalColor = float3(0.0f);

    /*
    // Ambient
    float3 ambientColor = light.point.base.color * light.point.base.ambient;

    // Diffuse lighting
    float3 normal = normalize(vertexIn.normal);
    float3 viewDirection = normalize(light.position - vertexIn.eyePosition); //lightDirection
    float3 lightDirection = normalize(-light.direction);
    //float diffuseFactor = max( dot( normal, lightDirection ), 0.0f);
    float diffuseFactor = saturate(-dot(normal, lightDirection));
    float3 diffuseColor = light.color * light.diffuse * diffuseFactor;

    // Specular lighting
    float3 reflectDirection = reflect(-lightDirection, normal);
    float specularFactor = pow( max( dot( viewDirection, reflectDirection ), 0.0f), material.shininess);

    float3 specularColor = light.color * light.specular * specularFactor;

*/

    float3 spotL = CalcSpotLight(light, material, camera, n, p);
    finalColor += spotL;

    textcolor = textcolor * float4(finalColor, 1);

    if (textcolor.a == 0.0)
    discard_fragment();

    return half4(textcolor.r, textcolor.g, textcolor.b, 1);
}
