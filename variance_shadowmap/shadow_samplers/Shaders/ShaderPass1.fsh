//
//  Shader.fsh
//  test
//
//  Created by ramemiso on 2013/09/23.
//  Copyright (c) 2013年 ramemiso. All rights reserved.
//

#version 300 es

in highp float depth;

out mediump vec4 fragColor;

void main()
{
	highp float dx = dFdx(depth);
	highp float dy = dFdy(depth);
	highp float depthSq = (depth * depth) + (0.25 * (dx * dx + dy * dy));

	fragColor = vec4(depth, depthSq, 0.0, 0.0);
}
