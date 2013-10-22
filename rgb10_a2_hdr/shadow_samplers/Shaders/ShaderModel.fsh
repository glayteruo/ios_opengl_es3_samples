//
//  Shader.fsh
//  test
//
//  Created by ramemiso on 2013/09/23.
//  Copyright (c) 2013年 ramemiso. All rights reserved.
//

#version 300 es

in highp vec4 position;
in mediump vec3 normal;

out mediump vec4 fragColor;

uniform highp vec3 lightPosition;

const mediump vec4 defuseColor = vec4(0.2, 0.2, 1.0, 1.0);

const mediump vec4 lightColor = vec4(50.0, 50.0, 50.0, 1.0);
const highp float maxLightDistance = 0.5;

const mediump vec3 maxValue = vec3(4.0f);

void main()
{
	highp vec3 toLight = lightPosition - position.xyz;
	highp float lightDistance = length(toLight);
	mediump vec3 l = normalize(toLight);
	mediump vec3 n = normalize(normal);
	mediump float ln = max(0.02, dot(l, n));
	
	mediump float lightPower = ln * maxLightDistance / lightDistance;
	
    fragColor = defuseColor * lightColor * lightPower;
	fragColor.rgb = min(maxValue, fragColor.rgb);
	fragColor.rgb /= 4.0;
}
