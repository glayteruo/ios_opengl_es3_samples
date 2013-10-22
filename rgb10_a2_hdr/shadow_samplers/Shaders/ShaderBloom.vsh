//
//  Shader.vsh
//  test
//
//  Created by ramemiso on 2013/09/23.
//  Copyright (c) 2013年 ramemiso. All rights reserved.
//

#version 300 es

#define ATTRIB_POSITION 0

layout (location = ATTRIB_POSITION) in vec4 vertexPosition;

out mediump vec2 texcoord;

void main()
{	
    gl_Position = vertexPosition;
	texcoord = vertexPosition.xy * 0.5 + 0.5;
}
