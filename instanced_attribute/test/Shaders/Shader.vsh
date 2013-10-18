//
//  Shader.vsh
//  test
//
//  Created by ramemiso on 2013/09/23.
//  Copyright (c) 2013年 ramemiso. All rights reserved.
//

#version 300 es

#define MAX_INSTANCE_COUNT 3

#define ATTRIB_POSITION 0
#define ATTRIB_NORMAL 1
#define ATTRIB_OFFSET 2
#define ATTRIB_DIFFUSE 3

layout (location = ATTRIB_POSITION) in vec4 vertexPosition;
layout (location = ATTRIB_NORMAL) in vec3 vertexNormal;
layout (location = ATTRIB_OFFSET) in vec3 vertexOffset;
layout (location = ATTRIB_DIFFUSE) in vec4 vertexDiffuse;


out mediump vec3 normal;
out lowp vec4 diffuse;

uniform mat4 viewProjectionMatrix;


void main()
{
	normal = vertexNormal;
	diffuse = vertexDiffuse;
	
	vec4 position = vertexPosition;
	position.xyz += vertexOffset;
    gl_Position = viewProjectionMatrix * position;
}
