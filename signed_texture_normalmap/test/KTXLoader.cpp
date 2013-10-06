//
//  KTXLoader.cpp
//  etc2_eac
//
//  Created by ramemiso on 2013/09/30.
//  Copyright (c) 2013年 ramemiso. All rights reserved.
//

#include "KTXLoader.h"

#include <stdexcept>

static const std::array<uint8_t, 12> KTXIdentifier = { 0xAB, 0x4B, 0x54, 0x58, 0x20, 0x31, 0x31, 0xBB, 0x0D, 0x0A, 0x1A, 0x0A };
static const std::array<uint8_t, 4> KTXEndianness = { 0x01, 0x02, 0x03, 0x04 };

struct KTXHeader
{
	std::array<uint8_t, 12> identifier;
	std::array<uint8_t, 4> endianness;
	uint32_t glType;
	uint32_t glTypeSize;
	uint32_t glFormat;
	uint32_t glInternalFormat;
	uint32_t glBaseInternalFormat;
	uint32_t pixelWidth;
	uint32_t pixelHeight;
	uint32_t pixelDepth;
	uint32_t numberOfArrayElements;
	uint32_t numberOfFaces;
	uint32_t numberOfMipmapLevels;
	uint32_t bytesOfKeyValueData;
} KTX_header;

KTXInfo KTXLoader::Load(const void* data, size_t dataSize)
{
	if ((data == nullptr) || (dataSize < sizeof(KTXHeader)))
	{
		throw std::runtime_error("empty data");
	}
		
	auto buf = reinterpret_cast<const uint8_t*>(data);
	
	// ヘッダー取得
	auto header = reinterpret_cast<const KTXHeader*>(buf);
	buf += sizeof(KTXHeader);
	
	// 識別子確認
	if (header->identifier != KTXIdentifier)
	{
		throw std::runtime_error("invalid ktx identifier");
	}
	
	// リトルエンディアン以外はサポートしない
	if (header->endianness != KTXEndianness)
	{
		throw std::runtime_error("endianness not support");
	}
	
	// テクスチャ配列には対応しない
	if (header->numberOfArrayElements != 0)
	{
		throw std::runtime_error("texture array not support");
	}
	
	// キューブマップには対応しない
	if (header->numberOfFaces != 1)
	{
		throw std::runtime_error("cubemap not support");
	}
	
	// 3Dテクスチャには対応しない
	if (header->pixelDepth != 0)
	{
		throw std::runtime_error("3d texture not support");
	}

	// イメージが格納されている位置へ
	buf += header->bytesOfKeyValueData;
	
	// 4バイトアラインメントに変更
	GLint unpackAlignment;
	glGetIntegerv(GL_UNPACK_ALIGNMENT, &unpackAlignment);
	if (unpackAlignment != 4) {
		glPixelStorei(GL_UNPACK_ALIGNMENT, 4);
	}
	
	// OpenGLテクスチャ作成
	GLuint texName;
	glGenTextures(1, &texName);
	
	if (glGetError() != GL_NO_ERROR)
	{
		throw std::runtime_error("faild to gen glTexture");
	}
	
	glBindTexture(GL_TEXTURE_2D, texName);
	
	auto width = header->pixelWidth;
	auto height = header->pixelHeight;
	
	for (auto i = 0u; i < header->numberOfMipmapLevels; ++i)
	{
		// イメージ取得
		auto imageSize = *reinterpret_cast<const uint32_t*>(buf);
		buf += sizeof(uint32_t);
		auto image = buf;
		
		// glTypeが0なら圧縮テクスチャ
		if (header->glType == 0u)
		{
			glCompressedTexImage2D(GL_TEXTURE_2D, i, header->glInternalFormat, width, height, 0, imageSize, image);
		}
		else
		{
			glTexImage2D(GL_TEXTURE_2D, i, header->glInternalFormat, width, height, 0, header->glFormat, header->glType, image);
		}

		if (glGetError() != GL_NO_ERROR)
		{
			throw std::runtime_error("faild to texImage2d");
		}
		
		// 次のレベルへ
		width = std::max(width / 2, 1u);
		height = std::max(height / 2, 1u);
		
		// 4バイトアラインメント
		buf += imageSize + (3 - ((imageSize + 3) % 4));
	}
	
	// テクスチャ情報を返す
	KTXInfo info;
	info.name = texName;
	info.width = header->pixelWidth;
	info.height = header->pixelHeight;
	info.hasMipmap = header->numberOfMipmapLevels != 1;

	return info;
}
