//
//  Shader.vsh
//  test
//
//  Created by ramemiso on 2013/09/23.
//  Copyright (c) 2013年 ramemiso. All rights reserved.
//

#version 300 es

#define ATTRIB_POSITION 0
#define ATTRIB_VELOCITY 1
#define ATTRIB_COLOR 2
#define ATTRIB_SIZE 3

layout (location = ATTRIB_POSITION) in vec4 vertexPosition;
layout (location = ATTRIB_VELOCITY) in vec3 vertexVelocity;
layout (location = ATTRIB_COLOR) in vec4 vertexColor;
layout (location = ATTRIB_SIZE) in float vertexSize;

out vec3 feedbackPosition;
out vec3 feedbackVelocity;
out vec3 feedbackColor;
out float feedbackSize;

out lowp vec4 color;

uniform mat4 modelViewProjectionMatrix;
uniform float deltaTime;

const vec3 Accel = vec3(0.0, -0.98, 0.0);
const float SizeSpeed = 100.0;
const float MaxSize = 50.0;

// -1.0〜1.0の乱数を取得
float rand_m1_1(vec2 seed)
{
	return sin(dot(seed.xy, vec2(12.9898, 78.233))* 43758.5453);
}

// 0.0〜1.0の乱数を取得
float rand_0_1(vec2 seed)
{
	return rand_m1_1(seed) * 0.5 + 0.5;
}

void main()
{
	// 位置更新
	vec4 newPosition = vertexPosition;
	newPosition.xyz += vertexVelocity * deltaTime;
	
	// 速度更新
	vec3 newVelocity = vertexVelocity;
	newVelocity += Accel * deltaTime;
	
	// 色更新
	vec4 newColor = vertexColor;
	
	// サイズ更新
	float newSize = vertexSize;
	newSize += SizeSpeed * deltaTime;
	if (newSize > MaxSize)
	{
		newSize = MaxSize;
	}
	
	// 適当な位置まで落ちたら初期化して再利用
	if (newPosition.y < -2.0)
	{
		newVelocity = vec3(rand_0_1(newColor.rg) * 0.2 + 0.2, rand_0_1(newColor.gb) * 0.5 + 0.5, rand_0_1(newColor.gr) * 0.05);
		newColor.rgb = vec3(rand_0_1(newColor.rr), rand_0_1(newColor.bb), rand_0_1(newColor.gg));
		newSize = 0.0f;
		newPosition.xyz = vec3(0.0, 0.0, 0.0);
	}

	// トランスフォームフィードバック
	feedbackPosition = newPosition.xyz;
	feedbackVelocity = newVelocity;
	feedbackColor = newColor.rgb;
	feedbackSize = newSize;
	
	
	// フラグメントシェーダへ
	color = newColor * newSize / MaxSize;
    gl_Position = modelViewProjectionMatrix * newPosition;
	gl_PointSize = newSize / gl_Position.w;
}
