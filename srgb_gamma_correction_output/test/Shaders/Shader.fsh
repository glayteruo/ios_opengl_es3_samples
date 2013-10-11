//
//  Shader.fsh
//  test
//
//  Created by ramemiso on 2013/09/23.
//  Copyright (c) 2013年 ramemiso. All rights reserved.
//

#version 300 es

#define GAMMA_CORRECTION_ENABLED
#define GAMMA 2.2

in mediump vec3 normal;

out mediump vec4 fragColor;

uniform bool gammaCorrectionEnabled;
uniform mediump float gamma;

const mediump vec3 l = normalize(vec3(1.0, 1.0, 0.0));
const lowp vec4 color = vec4(0.4, 0.4, 1.0, 1.0);

void main()
{
    mediump vec3 n = normalize(normal);
    mediump float nl = max(0.0, dot(n, l));
	
	fragColor = vec4(vec3(nl), 1.0);
	
	if (gammaCorrectionEnabled)
	{
		fragColor.rgb = pow(fragColor.rgb, vec3(1.0 / gamma));
	}
}
