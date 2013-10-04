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

uniform lowp sampler2DShadow shadowTexture;
uniform highp vec3 lightPosition;
uniform lowp sampler3D hatchingTexture;
uniform mediump vec2 hatchingOffset;

const lowp vec4 defuseColor = vec4(0.9, 0.85, 0.65, 1.0);

const mediump float angle = -0.785;
const mediump float cosA = cos(angle);
const mediump float sinA = sin(angle);
const mediump float scale = 0.008;
const mediump mat2 textureMatrix = mat2(cosA * scale, -sinA * scale,
										sinA * scale, cosA * scale);

void main()
{
    mediump vec3 n = normalize(normal);
    mediump vec3 l = normalize(lightPosition);
    
    mediump float nl = max(0.0, dot(n, l));
	lowp float shadow = textureProj(shadowTexture, shadowCoord) * nl;
	mediump vec2 st = textureMatrix * gl_FragCoord.xy;
	lowp float hatching = texture(hatchingTexture, vec3(hatchingOffset + st, 1.0 - shadow)).r;
	
    fragColor = defuseColor * hatching;
}
