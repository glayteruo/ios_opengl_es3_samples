//
//  Shader.fsh
//  test
//
//  Created by ramemiso on 2013/09/23.
//  Copyright (c) 2013年 ramemiso. All rights reserved.
//

#version 300 es

in mediump vec2 texcoord;
in mediump vec3 view;
in mediump vec3 light;

out mediump vec4 fragColor;

uniform lowp sampler2D normalTexture;

const lowp vec4 diffuseColor = vec4(0.8, 0.8, 1.0, 1.0);
const lowp vec4 specularColor = vec4(1.0, 1.0, 1.0, 1.0);
const mediump float specularPower = 5.0;

void main()
{
	mediump vec3 n;
	n.xy = texture(normalTexture, texcoord).xy;
	n.z = sqrt(1.0 - dot(n.xy, n.xy));
	n = normalize(n);
	
	mediump vec3 l = normalize(light);
	mediump vec3 v = normalize(view);
	mediump vec3 h = normalize(l + v);
	
	mediump float nl = max(dot(n, l), 0.0);
	mediump float nh = max(dot(n, h), 0.0);
	
	lowp vec4 diffuse = diffuseColor * nl;
	lowp vec4 specular = specularColor * pow(nh, specularPower);
	
    fragColor = diffuse + specular;
}
