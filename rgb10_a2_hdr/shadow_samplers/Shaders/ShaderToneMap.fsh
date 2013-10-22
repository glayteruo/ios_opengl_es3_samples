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

uniform mediump sampler2D hdrTexture;
uniform mediump float exposure;

void main()
{
	fragColor = texture(hdrTexture, texcoord);
	fragColor.rgb *= 4.0;
	
	fragColor.rgb = 1.0 - exp(-fragColor.rgb * exposure);
}
