//
//  Shader.fsh
//  test
//
//  Created by ramemiso on 2013/09/23.
//  Copyright (c) 2013年 ramemiso. All rights reserved.
//

#version 300 es

in mediump vec2 texcoord;

out mediump vec4 fragColor;

uniform lowp sampler2D colorTexture;
uniform mediump sampler2D normalDepthTexture;

void main()
{
	// 水平方向
	mediump vec4 h0 = textureOffset(normalDepthTexture, texcoord, ivec2(-1, 1)) * -1.0;
	mediump vec4 h1 = textureOffset(normalDepthTexture, texcoord, ivec2(-1, 0)) * -2.0;
	mediump vec4 h2 = textureOffset(normalDepthTexture, texcoord, ivec2(-1, -1)) * -1.0;
	mediump vec4 h3 = textureOffset(normalDepthTexture, texcoord, ivec2(1, 1)) * 1.0;
	mediump vec4 h4 = textureOffset(normalDepthTexture, texcoord, ivec2(1, 0)) * 2.0;
	mediump vec4 h5 = textureOffset(normalDepthTexture, texcoord, ivec2(1, -1)) * 1.0;
	mediump vec4 h = h0 + h1 + h2 + h3 + h4 + h5;
	
	// 垂直方向
	mediump vec4 v0 = textureOffset(normalDepthTexture, texcoord, ivec2(-1, 1)) * -1.0;
	mediump vec4 v1 = textureOffset(normalDepthTexture, texcoord, ivec2(0, 1)) * -2.0;
	mediump vec4 v2 = textureOffset(normalDepthTexture, texcoord, ivec2(1, 1)) * -1.0;
	mediump vec4 v3 = textureOffset(normalDepthTexture, texcoord, ivec2(-1, -1)) * 1.0;
	mediump vec4 v4 = textureOffset(normalDepthTexture, texcoord, ivec2(0, -1)) * 2.0;
	mediump vec4 v5 = textureOffset(normalDepthTexture, texcoord, ivec2(1, -1)) * 1.0;
	mediump vec4 v = v0 + v1 + v2 + v3 + v4 + v5;
	
	mediump float edge = sqrt(dot(h,h) + dot(v,v));
	edge = step(edge, 0.1);
	
//	fragColor = vec4(edge);
	fragColor = texture(colorTexture, texcoord) * edge;
}
