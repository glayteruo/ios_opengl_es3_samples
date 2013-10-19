//
//  Shader.fsh
//  test
//
//  Created by ramemiso on 2013/09/23.
//  Copyright (c) 2013年 ramemiso. All rights reserved.
//

#version 300 es

in lowp vec4 color;
in mediump vec3 normal;
in mediump float depth;

layout (location = 0) out mediump vec4 fragColor;
layout (location = 1) out mediump vec4 fragNormalDepth;

void main()
{
    fragColor = color;
	fragNormalDepth = vec4(normalize(normal), depth);
}
