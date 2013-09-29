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
out highp vec4 shadowCoord;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;
uniform mat4 shadowProjectionMatrix;


void main()
{	
	normal = normalMatrix * vertexNormal;
	
	shadowCoord = shadowProjectionMatrix * vertexPosition;
    
    gl_Position = modelViewProjectionMatrix * vertexPosition;
}
