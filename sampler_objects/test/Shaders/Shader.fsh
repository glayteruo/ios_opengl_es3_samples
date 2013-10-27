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

void main()
{
    fragColor = texture(colorTexture, texcoord);
}
