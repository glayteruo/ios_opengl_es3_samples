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

uniform bool gammaCorrectionEnabled;
uniform mediump float gamma;
uniform lowp sampler2D diffuseTexture;

void main()
{
	lowp vec4 diffuse = texture(diffuseTexture, texcoord);
	if (gammaCorrectionEnabled)
	{
		diffuse.rgb = pow(diffuse.rgb, vec3(gamma));
	}
	
	fragColor = diffuse;
	
	if (gammaCorrectionEnabled)
	{
		fragColor.rgb = pow(fragColor.rgb, vec3(1.0 / gamma));
	}
}
