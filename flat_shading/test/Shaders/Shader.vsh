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

layout (location = ATTRIB_POSITION) in vec4 vertexPosition;
layout (location = ATTRIB_NORMAL) in vec3 vertexNormal;

flat out lowp vec4 color;
flat out int vertexId;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;

const vec3 l = normalize(vec3(1.0, 1.0, 1.0));
const vec4 diffuse = vec4(0.3, 0.3, 1.0, 1.0);


void main()
{
	vec3 n = normalMatrix * vertexNormal;
	float ln = max(0.0, dot(l, n));

	color = diffuse * ln;
	vertexId = gl_VertexID;
	
    gl_Position = modelViewProjectionMatrix * vertexPosition;
}
