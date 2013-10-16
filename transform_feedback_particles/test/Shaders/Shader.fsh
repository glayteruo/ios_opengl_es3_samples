//
//  Shader.fsh
//  test
//
//  Created by ramemiso on 2013/09/23.
//  Copyright (c) 2013年 ramemiso. All rights reserved.
//

#version 300 es

in lowp vec4 color;

out mediump vec4 fragColor;

uniform lowp sampler2D starTexture;

void main()
{
	fragColor = color * texture(starTexture, gl_PointCoord).r;
}
