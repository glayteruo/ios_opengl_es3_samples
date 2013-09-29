//
//  Shader.fsh
//  test
//
//  Created by ramemiso on 2013/09/23.
//  Copyright (c) 2013年 ramemiso. All rights reserved.
//

#version 300 es

in mediump vec3 normal;
in highp vec4 shadowCoord;

out mediump vec4 fragColor;

uniform highp sampler2D shadowTexture;
uniform highp vec3 lightPosition;

const lowp vec4 defuseColor = vec4(0.4, 0.4, 1.0, 1.0);
const lowp float shadowRate = 0.25;

lowp float vsm()
{
	highp vec3 coord = shadowCoord.xyz / shadowCoord.w;
	mediump vec2 moment = texture(shadowTexture, coord.xy).rg;
	
	if (coord.z <= moment.r)
	{
		return 1.0;
	}
	
	highp float variance = moment.g - (moment.r * moment.r);
	variance = max(variance, 0.00002);

	highp float d = coord.z - moment.r;
	return variance / (variance + d * d);
}

void main()
{
    mediump vec3 n = normalize(normal);
    mediump vec3 l = normalize(lightPosition);
    
    mediump float nl = max(0.5, dot(n, l));
	lowp vec4 color = defuseColor * nl;
	
	lowp float shadow = vsm();
	fragColor = color * ((1.0 - shadowRate) + shadow * shadowRate);
}
