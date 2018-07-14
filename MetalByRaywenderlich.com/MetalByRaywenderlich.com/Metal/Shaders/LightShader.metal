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


float radians(float degree) {
    return degree * 3.14159265359 / 180.0;
}

// This function implements the Phong shading model
// The code is based on the OpenGL 4.0 Shading Language Cookbook, pp. 67 - 68, with a few tweaks.
// Please see Chapter 2 of the book for a detailed discussion.
fragment half4 phong_fragment_shader(VertexOut vertexIn [[ stage_in ]],
                                     constant CameraInfo &camera [[ buffer(3) ]],
                                     constant MaterialInfo &material [[ buffer(4) ]],
                                     constant DirectionalLight &light [[ buffer(5) ]],
                                     texture2d<float> texture [[ texture(0) ]],
                                     sampler sampler2d [[ sampler(0) ]]) {

    // extract color from current fragmnet coordinates
    float4 textcolor = texture.sample(sampler2d, vertexIn.textureCoordinates);
    //float4 color = vertexIn.color;

    float3 p = vertexIn.fragPosition; // Eye coordinates are computed as part of the camera model
    float3 s = normalize(-light.direction); // light direction is the normalised vector pointing to the light source
    //float3 v = normalize(-p);
    float3 view =  camera.position + camera.front;
    float3 v = normalize(view - p);  // view direction is the normalised vector pointing to the camera
    float3 n = normalize(vertexIn.normal);   // normal, normalizing makes sure that the normal is a unit vector
    float3 r = reflect(-s, n);   // reflection direction, is the normalised reflection vector
    float shininess = material.shininess;

    // diffuse
    // the dot function gives us the dot product between the normal and the light direction
    // and this gives us the angle so that we know how much lighting the fragment should receive.
    // its negative because when the normal is -1, the fragment should receive the most light, i.e.
    // diffuseFactor would be 1.
    float diffuseFactor = max(dot(s, n), 0.0f);
    float3 diffuseColor = light.base.diffuse * light.base.color * light.base.intensity * diffuseFactor;

    // Ambient
    float3 ambientColor = light.base.ambient * diffuseColor;

    // specular
    float3 specularColor = float3(0.0f,0,0);
    float specularFactor = pow(max(dot(v, r), 0.0f), shininess);

    if (diffuseFactor > 0.0f) {
        specularColor = light.base.specular * light.base.color * light.base.power * specularFactor;
    }

    if (material.useTexture) {
        textcolor = textcolor * material.color * float4(ambientColor + diffuseColor + specularColor, 1);

        if (textcolor.a == 0.0f)
            discard_fragment();

        return half4(textcolor.r, textcolor.g, textcolor.b, 1);
    } else {
        float4 finalColor = material.color * float4(ambientColor + diffuseColor + specularColor, 1);
        return half4(finalColor.r, finalColor.g, finalColor.b, 1);
    }

}


// This function implements the Blinn Phong shading model
// The code is based on the OpenGL 4.0 Shading Language Cookbook, pp. 67 - 68, with a few tweaks.
// Please see Chapter 2 of the book for a detailed discussion.
fragment half4 blinn_phong_fragment_shader(VertexOut vertexIn [[ stage_in ]],
                                           constant CameraInfo &camera [[ buffer(3) ]],
                                           constant MaterialInfo &material [[ buffer(4) ]],
                                           constant SpotLight &light [[ buffer(7) ]],
                                           texture2d<float> texture [[ texture(0) ]],
                                           sampler sampler2d [[ sampler(0) ]]) {


    // extract color from current fragmnet coordinates
    float4 textcolor = texture.sample(sampler2d, vertexIn.textureCoordinates);
    //float4 color = vertexIn.color;

    float3 p = vertexIn.fragPosition; // Eye coordinates are computed as part of the camera model
    float3 d = light.direction; // d is the spotlight direction (in eye coordinates)
    float3 s = normalize(light.pointLight.position - p); // light direction is the normalised vector pointing to the light source
    //float3 v = normalize(-p);
    float3 view = camera.position + camera.front;
    float3 v = normalize(view - p);  // view direction is the normalised vector pointing to the camera
    float3 n = normalize(vertexIn.normal);   // normal, normalizing makes sure that the normal is a unit vector
    float3 h = normalize(s + v); // halfway vector between the vector pointing to the camera with the one pointing to light source
    float angle = acos(dot(-s, d));
    float cutoff = radians(clamp(light.cutOff, 0.0f, 90.0f));
    float shininess = material.shininess;
    float4 finalColor = float4(1.0f,1,1,1);

    // diffuse
    float diffuseFactor = max(dot(s, n), 0.0f);
    float3 diffuseColor = light.pointLight.base.diffuse * light.pointLight.base.color *
    light.pointLight.base.intensity * diffuseFactor;

    // ambient
    float3 ambientColor = light.pointLight.base.ambient * diffuseColor;

    if (angle < cutoff) {

        // specular
        float spotFactor = pow(dot(-s, d), light.pointLight.atten.exponent);
        float3 specularColor = float3(0.0f);
        if (diffuseFactor > 0.0f) {
            specularColor = light.pointLight.base.specular * pow(max(dot(h, n), 0.0f), shininess);
        }

        finalColor = float4(ambientColor + spotFactor * (diffuseColor + specularColor), 1.0f);
    } else  {
        finalColor = float4(ambientColor, 1.0f);
    }

    if (material.useTexture) {
        textcolor = textcolor * material.color * finalColor;
        if (textcolor.a == 0.0f)
            discard_fragment();

        return half4(textcolor.r, textcolor.g, textcolor.b, 1);
    } else {
        finalColor = material.color * finalColor;
        return half4(finalColor.r, finalColor.g, finalColor.b, 1);
    }
}

float4 CalcLight(BaseLight base, MaterialInfo material, float3 lightDirection, float3 viewDirection, float3 normal)
{
    float diffuseFactor = max(dot(normal, lightDirection), 0.0f);

    float4 baseColor = float4(base.color.x, base.color.y, base.color.z, 1);
    float4 diffuseColor = float4(0.0,0,0,0);
    float4 specularColor = float4(0.0,0,0,0);
    float4 ambientColor = float4(0.0,0,0,0);

    if(diffuseFactor > 0.0f)
    {
        // Diffuse
        float4 baseDiff = float4(base.diffuse.x, base.diffuse.y, base.diffuse.z, 1);
        diffuseColor = baseDiff * baseColor * base.intensity * diffuseFactor;

        // Ambient
        float4 baseAmb = float4(base.ambient.x, base.ambient.y, base.ambient.z, 1);
        ambientColor = baseAmb * diffuseColor;

        // Specular
        float3 reflectDirection = reflect(-lightDirection, normal);
        float specularFactor = pow(max(dot(viewDirection, reflectDirection), 0.0), material.shininess);

        if(diffuseFactor > 0.0f)
        {
            float4 baseSpec = float4(base.specular.x, base.specular.y, base.specular.z, 1);
            specularColor = baseSpec * baseColor * base.power * specularFactor;
        }
    }

    return ambientColor + diffuseColor + specularColor;
}

float4 CalcDirectionalLight(DirectionalLight directionalLight, MaterialInfo material, float3 viewDirection, float3 normal)
{
    return CalcLight(directionalLight.base, material, -directionalLight.direction, viewDirection, normal);
}

float4 CalcPointLight(PointLight pointLight, MaterialInfo material, float3 vertexPosition, float3 viewDirection, float3 normal)
{

    float3 lightDirection = pointLight.position - vertexPosition;
    float distanceToPoint = length(lightDirection);


    //if(distanceToPoint > pointLight.range) {
    //    return float4(0.0, 0.0, 0.0, 0.0);
    //}

    float4 color = CalcLight(pointLight.base, material, normalize(lightDirection), viewDirection, normal);

    // Attenuation
    float attenuation =
    pointLight.atten.continual +
    pointLight.atten.linear *
    distanceToPoint +
    pointLight.atten.exponent *
    (distanceToPoint * distanceToPoint) +
    0.0001f;
     return color / attenuation;

    /*
     float attenuation =
     1.0f / (pointLight.atten.continual +
     pointLight.atten.linear *
     distanceToPoint +
     pointLight.atten.exponent *
     (distanceToPoint * distanceToPoint));
     return color * attenuation;
     */
}


float4 CalcSpotLight(SpotLight spotLight, MaterialInfo material, float3 vertexPosition, float3 viewDirection, float3 normal)
{
    float3 lightDirection = normalize(spotLight.pointLight.position - vertexPosition);

    // Intensity
    //float spotFactor = dot(lightDirection, normalize(-spotLight.direction));
    float spotFactor = max(dot(lightDirection, normalize(-spotLight.direction)), 0.0f); //// no difference
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


fragment half4 lighting_fragment_shader(VertexOut vertexIn [[ stage_in ]],
                                        constant CameraInfo &camera [[ buffer(3) ]],
                                        constant MaterialInfo &material [[ buffer(4) ]],
                                        constant DirectionalLight *dirlights [[ buffer(5) ]],
                                        constant PointLight *pointlights [[ buffer(6) ]],
                                        constant SpotLight *spotlights [[ buffer(7) ]],
                                        texture2d<float> texture [[ texture(0) ]],
                                        sampler sampler2d [[ sampler(0) ]]) {

    // Properties
    // extract color from current fragmnet coordinates
    float4 textcolor = texture.sample(sampler2d, vertexIn.textureCoordinates);
    float4 c = material.color;
    float3 p = vertexIn.fragPosition; // Eye coordinates are computed as part of the camera model
    float3 n = normalize(vertexIn.normal);
    float3 view = camera.position + camera.front;
    float3 v = normalize(view - vertexIn.fragPosition); // viewDirection
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
        finalColor += pointL;
    }

    // Spot light
    for (int i = 0; i < NUMBER_OF_SPOT_LIGHTS; i++) {
        float4 spotL = CalcSpotLight(spotlights[i], material, p, v, n);
        finalColor += spotL;
    }

    if (material.useTexture == true) {
        textcolor = textcolor * finalColor;

        return half4(textcolor.r, textcolor.g, textcolor.b, 1);
    } else {
        //finalColor = c * finalColor;
        return half4(finalColor.x, finalColor.y, finalColor.z, 1);
    }


}
