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

uniform highp sampler2DShadow shadowTexture;
uniform highp vec3 lightPosition;

const lowp vec4 defuseColor = vec4(0.4, 0.4, 1.0, 1.0);
const lowp float shadowRate = 0.25;

void main()
{
    mediump vec3 n = normalize(normal);
    mediump vec3 l = normalize(lightPosition);
    
    mediump float nl = max(0.5, dot(n, l));
	lowp vec4 color = defuseColor * nl;
	
	lowp float shadow = textureProj(shadowTexture, shadowCoord);
	
    fragColor = color * ((1.0 - shadowRate) + shadow * shadowRate);
}
