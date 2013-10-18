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

layout (location = ATTRIB_POSITION) in vec4 vertexPosition;
layout (location = ATTRIB_NORMAL) in vec3 vertexNormal;

out mediump vec3 normal;

uniform mat4 viewProjectionMatrix;

uniform mat4 modelMatrixList[MAX_INSTANCE_COUNT];
uniform mat3 normalMatrixList[MAX_INSTANCE_COUNT];

void main()
{
	normal = normalMatrixList[gl_InstanceID] * vertexNormal;
	
	mat4 modelViewProjectionMatrix = viewProjectionMatrix * modelMatrixList[gl_InstanceID];
    gl_Position = modelViewProjectionMatrix * vertexPosition;
}
