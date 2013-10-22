//
//  Shader.fsh
//  test
//
//  Created by ramemiso on 2013/09/23.
//  Copyright (c) 2013年 ramemiso. All rights reserved.
//

#version 300 es

in mediump vec2 texcoord;

out mediump vec4 fragColor;

uniform highp sampler2D targetTexture;

void main()
{
	mediump vec4 color = vec4(0.0);
    color += textureOffset(targetTexture, texcoord, ivec2(0, -3)) * 0.015625;
    color += textureOffset(targetTexture, texcoord, ivec2(0, -2)) * 0.09375;
    color += textureOffset(targetTexture, texcoord, ivec2(0, -1)) * 0.234375;
	color += texture(targetTexture, texcoord) * 0.3125;
    color += textureOffset(targetTexture, texcoord, ivec2(0, 1)) * 0.234375;
    color += textureOffset(targetTexture, texcoord, ivec2(0, 2)) * 0.09375;
    color += textureOffset(targetTexture, texcoord, ivec2(0, 3)) * 0.015625;

	fragColor = color;
}
