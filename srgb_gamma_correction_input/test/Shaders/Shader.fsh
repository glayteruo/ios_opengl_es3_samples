//
//  Shader.fsh
//  test
//
//  Created by ramemiso on 2013/09/23.
//  Copyright (c) 2013年 ramemiso. All rights reserved.
//

#version 300 es

in mediump vec3 normal;
in mediump vec2 texcoord;
in mediump vec3 view;

out mediump vec4 fragColor;

uniform bool gammaCorrectionEnabled;
uniform mediump float gamma;
uniform lowp sampler2D diffuseTexture;

const mediump vec3 l = normalize(vec3(0.5, 1.0, 1.0));
const mediump float specularPower = 20.0;

void main()
{
	lowp vec4 diffuse = texture(diffuseTexture, texcoord);
	if (gammaCorrectionEnabled)
	{
		diffuse.rgb = pow(diffuse.rgb, vec3(gamma));
	}
	
    mediump vec3 n = normalize(normal);
	mediump vec3 v = normalize(view);
	mediump vec3 r = reflect(l, n);

	mediump float nl = max(0.1, dot(n, l));
	mediump float vr = max(0.0, dot(v, r));

	diffuse.rgb *= nl;
	
	mediump float specular = pow(vr, specularPower);
	
	fragColor = diffuse;
	fragColor.rgb += specular;
		
	if (gammaCorrectionEnabled)
	{
		fragColor.rgb = pow(fragColor.rgb, vec3(1.0 / gamma));
	}
}
