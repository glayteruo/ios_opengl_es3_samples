//
//  Shader.fsh
//  test
//
//  Created by ramemiso on 2013/09/23.
//  Copyright (c) 2013年 ramemiso. All rights reserved.
//

#version 300 es

in lowp vec4 colorVarying;
in mediump vec3 woodCoord;
out mediump vec4 fragColor;

uniform lowp sampler3D woodTexture;

void main()
{
	lowp float wood = texture(woodTexture, woodCoord).r;
	fragColor = colorVarying * wood;
}
