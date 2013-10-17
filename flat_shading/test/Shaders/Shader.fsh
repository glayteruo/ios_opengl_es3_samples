//
//  Shader.fsh
//  test
//
//  Created by ramemiso on 2013/09/23.
//  Copyright (c) 2013年 ramemiso. All rights reserved.
//

#version 300 es

#define DISCARD_ENABLED

flat in lowp vec4 color;
flat in int vertexId;


out mediump vec4 fragColor;


void main()
{
#ifdef DISCARD_ENABLED
	if (vertexId % 2 == 0)
	{
		discard;
	}
#endif
	
	fragColor = color;
}
