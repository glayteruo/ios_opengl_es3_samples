//
//  Shader.vsh
//  test
//
//  Created by ramemiso on 2013/09/23.
//  Copyright (c) 2013年 ramemiso. All rights reserved.
//

#version 300 es

#define ATTRIB_POSITION 0
#define ATTRIB_NORMAL 1

layout (location = ATTRIB_POSITION) in vec4 position;
layout (location = ATTRIB_NORMAL) in vec3 vertexNormal;

out lowp vec4 color;
out mediump vec3 normal;
out mediump float depth;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;

const vec4 defuseColor = vec4(0.2, 0.2, 1.0, 1.0);
const vec3 l = normalize(vec3(0.5, 0.7, 1.0));

void main()
{    
	vec3 n = normalize(normalMatrix * vertexNormal);
	float ln = max(0.1, dot(l, n));
	
    gl_Position = modelViewProjectionMatrix * position;
	color = defuseColor * ln;
	normal = n;
	depth = gl_Position.z / gl_Position.w;
}
