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

layout (location = ATTRIB_POSITION) in vec4 vertexPosition;
layout (location = ATTRIB_NORMAL) in vec3 vertexNormal;

out mediump vec3 normal;
out mediump vec2 texcoord;
out mediump vec3 view;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;
uniform vec3 minPosition;
uniform vec3 maxPosition;

const highp float PI = 3.14159265359;

void main()
{
	normal = normalMatrix * vertexNormal;
	
	vec3 sub = maxPosition - minPosition;
	vec3 center = vec3(0.0, sub.y * 0.5, 0.0);
	vec3 posv = vertexPosition.xyz - center;
    
	vec2 posv_xz = normalize(posv.xz);
	texcoord.x = atan(posv_xz.y, posv_xz.x) / PI * 0.5 + 0.5;
	texcoord.y = 1.0 - (posv.y / sub.y) + 0.5;

    gl_Position = modelViewProjectionMatrix * vertexPosition;
	
	view = -normalize(gl_Position.xyz);
}
