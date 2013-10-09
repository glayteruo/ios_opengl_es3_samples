//
//  Shader.vsh
//  test
//
//  Created by ramemiso on 2013/09/23.
//  Copyright (c) 2013年 ramemiso. All rights reserved.
//

#version 300 es

#define ATTRIB_POSITION 0
#define ATTRIB_NORMAL 1
#define ATTRIB_TANGENT 2
#define ATTRIB_TEXCOORD 3

layout (location = ATTRIB_POSITION) in vec4 vertexPosition;
layout (location = ATTRIB_NORMAL) in vec3 vertexNormal;
layout (location = ATTRIB_TANGENT) in vec3 vertexTangent;
layout (location = ATTRIB_TEXCOORD) in vec2 vertexTexcoord;

out mediump vec2 texcoord;
out mediump vec3 view;
out mediump vec3 light;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;
uniform mediump sampler2D heightTexture;
uniform mediump float height;

const vec3 LightDirection = vec3(0.0, 0.0, 1.0);

void main()
{
	vec4 pos = vertexPosition;
	pos.xyz += vertexNormal * texture(heightTexture, vertexTexcoord).r * height;
	gl_Position = modelViewProjectionMatrix * pos;

	texcoord = vertexTexcoord;
	
	vec3 n = normalize(normalMatrix * vertexNormal);
	vec3 t = normalize(normalMatrix * vertexTangent);
	vec3 b = cross(n, t);
	
	view = vec3(dot(gl_Position.xyz, t), dot(gl_Position.xyz, b), dot(gl_Position.xyz, n));
	view = -normalize(gl_Position.xyz);
	
	light = vec3(dot(LightDirection, t), dot(LightDirection, b), dot(LightDirection, n));
	light = normalize(light);
}
