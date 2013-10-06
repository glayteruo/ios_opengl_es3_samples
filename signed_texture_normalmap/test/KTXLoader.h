//
//  KTXLoader.h
//  etc2_eac
//
//  Created by ramemiso on 2013/09/30.
//  Copyright (c) 2013年 ramemiso. All rights reserved.
//

#pragma once

#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>

#include <cstdint>
#include <vector>
#include <array>

struct KTXInfo
{
	uint32_t name;
	uint32_t width;
	uint32_t height;
	bool hasMipmap;
};

class KTXLoader
{
public:
	
	static KTXInfo Load(const void* data, size_t dataSize);
};
