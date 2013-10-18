//
//  Shader.fsh
//  test
//
//  Created by ramemiso on 2013/09/23.
//  Copyright (c) 2013年 ramemiso. All rights reserved.
//

#version 300 es

in mediump vec3 normal;

out mediump vec4 fragColor;

const mediump vec3 l = normalize(vec3(1.0, 1.0, 1.0));
const lowp vec4 diffuse = vec4(0.3, 0.3, 1.0, 1.0);

void main()
{
	mediump vec3 n = normalize(normal);
	mediump float ln = max(0.05, dot(l, n));
	
	fragColor = diffuse * ln;
}
