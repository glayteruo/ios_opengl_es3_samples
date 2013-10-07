//
//  Shader.vsh
//  test
//
//  Created by ramemiso on 2013/09/23.
//  Copyright (c) 2013年 ramemiso. All rights reserved.
//

#version 300 es

#define ATTRIB_POSITION 0
#define ATTRIB_TEXCOORD 1

layout (location = ATTRIB_POSITION) in vec4 vertexPosition;
layout (location = ATTRIB_TEXCOORD) in ivec2 vertexTexcoord;

out mediump vec3 normal;
out mediump vec3 view;
out mediump vec3 light;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;
uniform highp sampler2D heightTexture;

const float Height = 0.2;
const vec3 LightDirection = vec3(0.0, 0.0, 1.0);

void main()
{
	vec4 pos = vertexPosition;
	pos.z = texelFetch(heightTexture, vertexTexcoord, 0).r * Height;
	gl_Position = modelViewProjectionMatrix * pos;
	
	vec2 texSize = vec2(textureSize(heightTexture, 0));
	
	float t0 = texelFetchOffset(heightTexture, vertexTexcoord, 0, ivec2(-1.0, 0.0)).r;
	float t1 = texelFetchOffset(heightTexture, vertexTexcoord, 0, ivec2( 1.0, 0.0)).r;
	vec3 t = vec3(2.0 / texSize.x, 0.0, (t1 - t0) * Height);
	
	float b0 = texelFetchOffset(heightTexture, vertexTexcoord, 0, ivec2(0.0, -1.0)).r;
	float b1 = texelFetchOffset(heightTexture, vertexTexcoord, 0, ivec2(0.0,  1.0)).r;
	vec3 b = vec3(0.0, 2.0 / texSize.y, (b1 - b0) * Height);
	
	normal = normalize(normalMatrix * cross(t, b));
	
	view = -normalize(gl_Position.xyz);
	light = normalize(LightDirection);
}
