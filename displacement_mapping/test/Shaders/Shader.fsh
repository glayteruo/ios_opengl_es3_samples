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

uniform mediump sampler2D heightTexture;
uniform mediump float height;

const lowp vec4 diffuseColor = vec4(0.8, 0.8, 1.0, 1.0);
const lowp vec4 specularColor = vec4(1.0, 1.0, 1.0, 1.0);
const mediump float specularPower = 8.0;

void main()
{
	mediump vec2 texSize = vec2(textureSize(heightTexture, 0));

	mediump float t0 = textureOffset(heightTexture, texcoord, ivec2(-1.0, 0.0)).r;
	mediump float t1 = textureOffset(heightTexture, texcoord, ivec2( 1.0, 0.0)).r;
	mediump vec3 t = vec3(2.0 / texSize.x, 0.0, (t1 - t0) * height);

	mediump float b0 = textureOffset(heightTexture, texcoord, ivec2(0.0, -1.0)).r;
	mediump float b1 = textureOffset(heightTexture, texcoord, ivec2(0.0,  1.0)).r;
	mediump vec3 b = vec3(0.0, 2.0 / texSize.y, (b1 - b0) * height);
	
	mediump vec3 n = normalize(cross(t, b));
	mediump vec3 l = normalize(light);
	mediump vec3 v = normalize(view);
	mediump vec3 h = normalize(l + v);
	
	mediump float nl = max(dot(n, l), 0.0);
	mediump float nh = max(dot(n, h), 0.0);
	
	lowp vec4 diffuse = diffuseColor * nl;
	lowp vec4 specular = specularColor * pow(nh, specularPower);
	
    fragColor = diffuse + specular;
}
