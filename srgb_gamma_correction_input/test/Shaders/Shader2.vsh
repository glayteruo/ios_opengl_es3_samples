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
#define ATTRIB_TEXCOORD 2

layout (location = ATTRIB_POSITION) in vec4 vertexPosition;
layout (location = ATTRIB_TEXCOORD) in vec2 vertexTexcoord;

out mediump vec2 texcoord;

void main()
{
	texcoord = vertexTexcoord;
    gl_Position = vertexPosition;
}
