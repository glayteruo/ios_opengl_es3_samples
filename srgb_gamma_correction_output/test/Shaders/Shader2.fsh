//
//  Shader.fsh
//  test
//
//  Created by ramemiso on 2013/09/23.
//  Copyright (c) 2013年 ramemiso. All rights reserved.
//

#version 300 es

in mediump vec4 color;

out mediump vec4 fragColor;

uniform bool gammaCorrectionEnabled;
uniform mediump float gamma;

void main()
{
	fragColor = color;
	
	if (gammaCorrectionEnabled)
	{
		fragColor.rgb = pow(fragColor.rgb, vec3(1.0 / gamma));
	}
}
