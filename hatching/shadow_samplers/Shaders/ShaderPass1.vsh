//
//  Shader.vsh
//  test
//
//  Created by ramemiso on 2013/09/23.
//  Copyright (c) 2013年 ramemiso. All rights reserved.
//

#version 300 es

#define ATTRIB_POSITION 0

layout (location = ATTRIB_POSITION) in vec4 position;

uniform mat4 modelViewProjectionMatrix;

void main()
{    
    gl_Position = modelViewProjectionMatrix * position;
}
