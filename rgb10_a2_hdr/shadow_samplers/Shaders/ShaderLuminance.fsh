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

uniform mediump sampler2D targetTexture;

const mediump vec3 luminance = vec3(0.27, 0.67, 0.06);

void main()
{
	mediump vec3 color = texture(targetTexture, texcoord).rgb * 4.0;
	fragColor.r = dot(color, luminance);
}
