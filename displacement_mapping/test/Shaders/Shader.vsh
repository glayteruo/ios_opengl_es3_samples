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
layout (location = ATTRIB_TEXCOORD) in vec2 vertexTexcoord;

out mediump vec2 texcoord;
out mediump vec3 view;
out mediump vec3 light;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 invNormalMatrix;
uniform mediump sampler2D heightTexture;
uniform mediump float height;

const vec3 LightDirection = vec3(0.0, 0.0, 1.0);

void main()
{
	vec4 pos = vertexPosition;
	pos.z = texture(heightTexture, vertexTexcoord).r * height;
	gl_Position = modelViewProjectionMatrix * pos;

	texcoord = vertexTexcoord;
	view = invNormalMatrix * -normalize(gl_Position.xyz);
	light = invNormalMatrix * normalize(LightDirection);
}
