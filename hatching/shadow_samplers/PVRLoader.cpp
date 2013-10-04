//
//  KTXLoader.cpp
//  etc2_eac
//
//  Created by ramemiso on 2013/09/30.
//  Copyright (c) 2013年 ramemiso. All rights reserved.
//

#include "PVRLoader.h"

#include <stdexcept>

struct PVRHeader
{
	uint32_t version;
	uint32_t flags;
	uint64_t pixelFormat;
	uint32_t colourSpace;
	uint32_t channelType;
	uint32_t height;
	uint32_t width;
	uint32_t depth;
	uint32_t numSurfaces;
	uint32_t numFaces;
	uint32_t mipMapCount;
	uint32_t metaDataSize;
};

PVRInfo PVRLoader::Load3D(const void* data, size_t dataSize)
{
	if ((data == nullptr) || (dataSize < sizeof(PVRHeader)))
	{
		throw std::runtime_error("empty data");
	}
		
	auto buf = reinterpret_cast<const uint8_t*>(data);
	
	// ヘッダー取得
	auto header = reinterpret_cast<const PVRHeader*>(buf);
	buf += sizeof(PVRHeader);
	
	// メタデータは読み飛ばす
	buf += header->metaDataSize;

	
	// OpenGLテクスチャ作成
	GLuint texName;
	glGenTextures(1, &texName);
	
	if (glGetError() != GL_NO_ERROR)
	{
		throw std::runtime_error("faild to gen glTexture");
	}
	
	glBindTexture(GL_TEXTURE_3D, texName);
	
	auto width = header->width;
	auto height = header->height;
	auto depth = header->numSurfaces;
	
	// イメージ取得
	auto image = buf;
			
	glTexImage3D(GL_TEXTURE_3D, 0, GL_R8, width, height, depth, 0, GL_RED, GL_UNSIGNED_BYTE, image);

	if (glGetError() != GL_NO_ERROR)
	{
		throw std::runtime_error("faild to texImage2d");
	}
	
	// テクスチャ情報を返す
	PVRInfo info;
	info.name = texName;
	info.width = header->width;
	info.height = header->height;
	info.depth = header->numSurfaces;
	info.hasMipmap = header->mipMapCount != 1;

	return info;
}
