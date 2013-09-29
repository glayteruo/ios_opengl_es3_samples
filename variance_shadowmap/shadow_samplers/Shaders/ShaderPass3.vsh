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
layout (location = ATTRIB_TEXCOORD) in vec3 vertexTexcoord;

out mediump vec2 texcoord;

void main()
{
	texcoord = vertexTexcoord.xy;
    gl_Position = vertexPosition;
}

