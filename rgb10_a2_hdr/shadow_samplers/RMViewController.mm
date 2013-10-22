//
//  RMViewController.m
//  test
//
//  Created by ramemiso on 2013/09/23.
//  Copyright (c) 2013年 ramemiso. All rights reserved.
//

#import "RMViewController.h"
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

// Uniform index.
enum
{
    MODEL_UNIFORM_VIEWPROJECTION_MATRIX,
    MODEL_UNIFORM_MODEL_MATRIX,
    MODEL_UNIFORM_NORMAL_MATRIX,
	MODEL_UNIFORM_LIGHT_POSITION,
	
	BLOOM_UNFIROM_HDR_TEXTURE,
	
	BLUR_H_UNFIROM_TARGET_TEXTURE,
	BLUR_V_UNFIROM_TARGET_TEXTURE,
	
	THROUGH_UNFIROM_TARGET_TEXTURE,
	
	LUMINANCE_UNFIROM_TARGET_TEXTURE,
	
	TONEMAP_UNFIROM_HDR_TEXTURE,
	TONEMAP_UNFIROM_EXPOSURE,
	
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

enum
{
	ATTRIB_POSITION,
	ATTRIB_NORMAL,
};

GLfloat gCubeVertexData[] =
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
    0.5f, -0.5f, -0.5f,        1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,          1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    
    0.5f, 0.5f, -0.5f,         0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 1.0f, 0.0f,
    
    -0.5f, 0.5f, -0.5f,        -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        -1.0f, 0.0f, 0.0f,
    
    -0.5f, -0.5f, -0.5f,       0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         0.0f, -1.0f, 0.0f,
    
    0.5f, 0.5f, 0.5f,          0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, 0.0f, 1.0f,
    
    0.5f, -0.5f, -0.5f,        0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 0.0f, -1.0f
};

GLfloat gGroundVertexData[] =
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
    -2.5f, 0.0f, 6.5f,        0.0f, 1.0f, 0.0f,
    3.5f, 0.0f, -2.5f,        0.0f, 1.0f, 0.0f,
    -2.5f, 0.0f, -2.5f,       0.0f, 1.0f, 0.0f,
    3.5f, 0.0f, 6.5f,         0.0f, 1.0f, 0.0f,
    3.5f, 0.0f, -2.5f,        0.0f, 1.0f, 0.0f,
    -2.5f, 0.0f, 6.5f,        0.0f, 1.0f, 0.0f,

    -2.5f, 0.0f, -2.5f,       0.0f, 0.0f, 1.0f,
    2.5f, 0.0f, -2.5f,        0.0f, 0.0f, 1.0f,
    -2.5f, 6.0f, -2.5f,       0.0f, 0.0f, 1.0f,
    -2.5f, 6.0f, -2.5f,       0.0f, 0.0f, 1.0f,
    2.5f, 0.0f, -2.5f,        0.0f, 0.0f, 1.0f,
    2.5f, 6.0f, -2.5f,        0.0f, 0.0f, 1.0f,

    -2.5f, 6.0f, -2.5f,       1.0f, 0.0f, 0.0f,
    -2.5f, 0.0f, 2.5f,        1.0f, 0.0f, 0.0f,
    -2.5f, 0.0f, -2.5f,       1.0f, 0.0f, 0.0f,
    -2.5f, 6.0f, 2.5f,        1.0f, 0.0f, 0.0f,
    -2.5f, 0.0f, 2.5f,        1.0f, 0.0f, 0.0f,
    -2.5f, 6.0f, -2.5f,       1.0f, 0.0f, 0.0f,
};

GLfloat gScreenVertexData[] =
{
	-1.0f,  1.0f, 0.0f,
	-1.0f, -1.0f, 0.0f,
	1.0f,  1.0f, 0.0f,
	1.0f, -1.0f, 0.0f,
};

struct DrawObject
{
    GLuint vao;
    GLuint vbo;

    GLKMatrix4 mMat;
};

@interface RMViewController () {
    GLuint _programModel;
    GLuint _programBloom;
    GLuint _programBlurH;
    GLuint _programBlurV;
    GLuint _programThrough;
	GLuint _programLuminance;
    GLuint _programToneMap;
	
	GLint _viewWidth;
	GLint _viewHeight;
	
    float _rotation;
	GLKVector3 _lightPosition;
	float _exposure;
	
	DrawObject _cubeObject;
	DrawObject _groundObject;
	DrawObject _screenObject;
	
	GLuint _hdrFBO;
	GLuint _depthRBO;
	GLuint _hdrTexture;
	
	GLuint _luminanceFBO[5];
	GLuint _luminanceTexture[5];
	
	GLuint _bloomFBOLevel0[2];
	GLuint _bloomTextureLevel0[2];

	GLuint _bloomFBOLevel1[2];
	GLuint _bloomTextureLevel1[2];

	GLuint _nearestSampler;
	GLuint _linearSampler;
}
@property (strong, nonatomic) EAGLContext *context;

- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders:(GLuint*)program path:(NSString*)path;
- (BOOL)compileShader:(GLuint*)shader type:(GLenum)type file:(NSString*)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

@implementation RMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
	
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
	view.drawableColorFormat = GLKViewDrawableColorFormatSRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
	
	_viewWidth = view.frame.size.width * 2;
	_viewHeight = view.frame.size.height * 2;
    
    [self setupGL];
}

- (void)dealloc
{
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
	
    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }
	
    // Dispose of any resources that can be recreated.
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    [self loadShaders:&_programModel path:@"ShaderModel"];
    [self loadShaders:&_programBloom path:@"ShaderBloom"];
    [self loadShaders:&_programBlurH path:@"ShaderBlurH"];
    [self loadShaders:&_programBlurV path:@"ShaderBlurV"];
    [self loadShaders:&_programThrough path:@"ShaderThrough"];
    [self loadShaders:&_programLuminance path:@"ShaderLuminance"];
    [self loadShaders:&_programToneMap path:@"ShaderToneMap"];

	uniforms[MODEL_UNIFORM_VIEWPROJECTION_MATRIX] = glGetUniformLocation(_programModel, "viewProjectionMatrix");
    uniforms[MODEL_UNIFORM_MODEL_MATRIX] = glGetUniformLocation(_programModel, "modelMatrix");
    uniforms[MODEL_UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_programModel, "normalMatrix");
	uniforms[MODEL_UNIFORM_LIGHT_POSITION] = glGetUniformLocation(_programModel, "lightPosition");

	uniforms[BLOOM_UNFIROM_HDR_TEXTURE] = glGetUniformLocation(_programBloom, "hdrTexture");

	uniforms[BLUR_H_UNFIROM_TARGET_TEXTURE] = glGetUniformLocation(_programBlurH, "targetTexture");
	uniforms[BLUR_V_UNFIROM_TARGET_TEXTURE] = glGetUniformLocation(_programBlurV, "targetTexture");

	uniforms[THROUGH_UNFIROM_TARGET_TEXTURE] = glGetUniformLocation(_programThrough, "targetTexture");

	uniforms[LUMINANCE_UNFIROM_TARGET_TEXTURE] = glGetUniformLocation(_programLuminance, "targetTexture");

	uniforms[TONEMAP_UNFIROM_HDR_TEXTURE] = glGetUniformLocation(_programToneMap, "hdrTexture");
	uniforms[TONEMAP_UNFIROM_EXPOSURE] = glGetUniformLocation(_programToneMap, "exposure");

	_exposure = 0.0f;
	
	glEnable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);
	
	auto makeFunc = [](DrawObject& obj, size_t dataSize, void* data, bool isScreen)
	{
		glGenVertexArrays(1, &obj.vao);
		glBindVertexArray(obj.vao);
		
		glGenBuffers(1, &obj.vbo);
		glBindBuffer(GL_ARRAY_BUFFER, obj.vbo);
		glBufferData(GL_ARRAY_BUFFER, dataSize, data, GL_STATIC_DRAW);
				
		if (isScreen)
		{
			glEnableVertexAttribArray(ATTRIB_POSITION);
			glVertexAttribPointer(ATTRIB_POSITION, 3, GL_FLOAT, GL_FALSE, 12, BUFFER_OFFSET(0));
		}
		else
		{
			glEnableVertexAttribArray(ATTRIB_POSITION);
			glEnableVertexAttribArray(ATTRIB_NORMAL);
			glVertexAttribPointer(ATTRIB_POSITION, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
			glVertexAttribPointer(ATTRIB_NORMAL, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
		}
		glBindVertexArray(0);
	};
	
	// オブジェクト作成
	makeFunc(_cubeObject, sizeof(gCubeVertexData), gCubeVertexData, false);
	makeFunc(_groundObject, sizeof(gGroundVertexData), gGroundVertexData, false);
	makeFunc(_screenObject, sizeof(gScreenVertexData), gScreenVertexData, true);
	
	// ライト位置
	_lightPosition = GLKVector3Make(3.0f, 4.0f, 3.0f);
	
	// HDR用テクスチャ作成
	glGenTextures(1, &_hdrTexture);
	glBindTexture(GL_TEXTURE_2D, _hdrTexture);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB10_A2, _viewWidth, _viewHeight, 0, GL_RGBA, GL_UNSIGNED_INT_2_10_10_10_REV, NULL);
//	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, _viewWidth, _viewHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);

	glBindTexture(GL_TEXTURE_2D, 0);

	// デプス用レンダーバッファ作成
	glGenRenderbuffers(1, &_depthRBO);
	glBindRenderbuffer(GL_RENDERBUFFER, _depthRBO);
	glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT24, _viewWidth, _viewHeight);
	
	glBindRenderbuffer(GL_RENDERBUFFER, 0);
		
	// HDR用FBO作成
	glGenFramebuffers(1, &_hdrFBO);
	glBindFramebuffer(GL_FRAMEBUFFER, _hdrFBO);
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _hdrTexture, 0);
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRBO);
	assert(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE);
	
	glBindFramebuffer(GL_FRAMEBUFFER, 0);
	
	// 輝度用テクスチャ作成
	int32_t tex_width = _viewWidth / 4;
	int32_t tex_height = _viewHeight / 4;
	for (int i = 0; i < 5; ++i)
	{
		glGenTextures(1, &_luminanceTexture[i]);
		glBindTexture(GL_TEXTURE_2D, _luminanceTexture[i]);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_R16F, tex_width, tex_height, 0, GL_RED, GL_HALF_FLOAT, NULL);
		
		tex_width = MAX(1, tex_width / 4);
		tex_height = MAX(1, tex_height / 4);
		
		// 輝度用FBO作成
		glGenFramebuffers(1, &_luminanceFBO[i]);
		glBindFramebuffer(GL_FRAMEBUFFER, _luminanceFBO[i]);
		glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _luminanceTexture[i], 0);
		assert(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE);
		
		glBindFramebuffer(GL_FRAMEBUFFER, 0);
	}
	
	// ブルームレベル０
	for (int i = 0; i < 2; ++i)
	{
		// ブルーム用テクスチャ作成
		glGenTextures(1, &_bloomTextureLevel0[i]);
		glBindTexture(GL_TEXTURE_2D, _bloomTextureLevel0[i]);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB10_A2, _viewWidth / 4, _viewHeight / 4, 0, GL_RGBA, GL_UNSIGNED_INT_2_10_10_10_REV, NULL);
		
		glBindTexture(GL_TEXTURE_2D, 0);
		
		// ブルーム用FBO作成
		glGenFramebuffers(1, &_bloomFBOLevel0[i]);
		glBindFramebuffer(GL_FRAMEBUFFER, _bloomFBOLevel0[i]);
		glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _bloomFBOLevel0[i], 0);
		assert(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE);
		
		glBindFramebuffer(GL_FRAMEBUFFER, 0);
	}

	// ブルームレベル１
	for (int i = 0; i < 2; ++i)
	{
		// ブルーム用テクスチャ作成
		glGenTextures(1, &_bloomTextureLevel1[i]);
		glBindTexture(GL_TEXTURE_2D, _bloomTextureLevel1[i]);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB10_A2, _viewWidth / 8, _viewHeight / 8, 0, GL_RGBA, GL_UNSIGNED_INT_2_10_10_10_REV, NULL);
		
		glBindTexture(GL_TEXTURE_2D, 0);
		
		// ブルーム用FBO作成
		glGenFramebuffers(1, &_bloomFBOLevel1[i]);
		glBindFramebuffer(GL_FRAMEBUFFER, _bloomFBOLevel1[i]);
		glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _bloomFBOLevel1[i], 0);
		assert(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE);
		
		glBindFramebuffer(GL_FRAMEBUFFER, 0);
	}
	
	// ニアレストサンプラー作成
	glGenSamplers(1, &_nearestSampler);
	glSamplerParameteri(_nearestSampler, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glSamplerParameteri(_nearestSampler, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glSamplerParameteri(_nearestSampler, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glSamplerParameteri(_nearestSampler, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	
	// リニアサンプラー作成
	glGenSamplers(1, &_linearSampler);
	glSamplerParameteri(_linearSampler, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glSamplerParameteri(_linearSampler, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glSamplerParameteri(_linearSampler, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glSamplerParameteri(_linearSampler, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_groundObject.vbo);
    glDeleteVertexArrays(1, &_groundObject.vao);
    glDeleteBuffers(1, &_cubeObject.vbo);
    glDeleteVertexArrays(1, &_cubeObject.vao);
	
	glDeleteSamplers(1, &_nearestSampler);
	glDeleteTextures(1, &_hdrTexture);
	glDeleteRenderbuffers(1, &_depthRBO);
	glDeleteFramebuffers(1, &_hdrFBO);
    
    glDeleteProgram(_programModel);
    glDeleteProgram(_programBloom);
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
//	_rotation = 4.0f;
	
	_cubeObject.mMat = GLKMatrix4MakeRotation(_rotation, 0.0f, 1.0f, 0.0f);
	_groundObject.mMat = GLKMatrix4MakeTranslation(0.0f, -1.0f, -1.0f);
	
	_lightPosition.x = cosf(_rotation) * 2.0f + 1.0f;
	_lightPosition.y = 0.7f;
	_lightPosition.z = sinf(_rotation) * 2.0f + 1.0f;
	
    _rotation += self.timeSinceLastUpdate * 1.0f;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
	auto drawFunc = [&](int programNo, const DrawObject& obj, const GLKMatrix4& vpMat, GLenum mode, GLsizei count, GLuint texture)
	{
		// モデル描画
		if (programNo == 1)
		{
			GLKMatrix3 nMat = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(obj.mMat), NULL);
			
			glUseProgram(_programModel);
			glUniformMatrix4fv(uniforms[MODEL_UNIFORM_VIEWPROJECTION_MATRIX], 1, GL_FALSE, vpMat.m);
			glUniformMatrix4fv(uniforms[MODEL_UNIFORM_MODEL_MATRIX], 1, GL_FALSE, obj.mMat.m);
			glUniformMatrix3fv(uniforms[MODEL_UNIFORM_NORMAL_MATRIX], 1, GL_FALSE, nMat.m);
			glUniform3f(uniforms[MODEL_UNIFORM_LIGHT_POSITION], _lightPosition.x, _lightPosition.y, _lightPosition.z);
		}
		// ブルーム用テクスチャに描画
		else if (programNo == 2)
		{
			glUseProgram(_programBloom);

			glActiveTexture(GL_TEXTURE0);
			glBindTexture(GL_TEXTURE_2D, texture);
			glBindSampler(0, _linearSampler);
			glUniform1i(uniforms[BLOOM_UNFIROM_HDR_TEXTURE], 0);
		}
		// ブラー水平
		else if (programNo == 3)
		{
			glUseProgram(_programBlurH);

			glActiveTexture(GL_TEXTURE0);
			glBindTexture(GL_TEXTURE_2D, texture);
			glBindSampler(0, _nearestSampler);
			glUniform1i(uniforms[BLUR_H_UNFIROM_TARGET_TEXTURE], 0);
		}
		// ブラー垂直
		else if (programNo == 4)
		{
			glUseProgram(_programBlurV);
			
			glActiveTexture(GL_TEXTURE0);
			glBindTexture(GL_TEXTURE_2D, texture);
			glBindSampler(0, _nearestSampler);
			glUniform1i(uniforms[BLUR_V_UNFIROM_TARGET_TEXTURE], 0);
		}
		// スルー描画
		else if (programNo == 5)
		{
			glUseProgram(_programThrough);
			
			glActiveTexture(GL_TEXTURE0);
			glBindTexture(GL_TEXTURE_2D, texture);
			glBindSampler(0, _linearSampler);
			glUniform1i(uniforms[THROUGH_UNFIROM_TARGET_TEXTURE], 0);
		}
		// 輝度描画
		else if (programNo == 6)
		{
			glUseProgram(_programLuminance);
			
			glActiveTexture(GL_TEXTURE0);
			glBindTexture(GL_TEXTURE_2D, texture);
			glBindSampler(0, _linearSampler);
			glUniform1i(uniforms[THROUGH_UNFIROM_TARGET_TEXTURE], 0);
		}
		// 最終描画結果
		else
		{
			glUseProgram(_programToneMap);
			
			glUniform1f(uniforms[TONEMAP_UNFIROM_EXPOSURE], _exposure);
			
			glActiveTexture(GL_TEXTURE0);
			glBindTexture(GL_TEXTURE_2D, texture);
			glBindSampler(0, _nearestSampler);
			glUniform1i(uniforms[TONEMAP_UNFIROM_HDR_TEXTURE], 0);
		}
		
		glBindVertexArray(obj.vao);
		glDrawArrays(mode, 0, count);
	};
	

	// モデル描画
	GLint defaultFBO = -1;
	GLint defaultViewport[4];
	glGetIntegerv(GL_FRAMEBUFFER_BINDING, &defaultFBO);
	glGetIntegerv(GL_VIEWPORT, defaultViewport);
	glBindFramebuffer(GL_FRAMEBUFFER, _hdrFBO);
	
	glEnable(GL_DEPTH_TEST);
	
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projMat = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 2.0f, 100.0f);
	GLKMatrix4 viewMat = GLKMatrix4MakeLookAt(2.0f, 3.5f, 4.5f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f);
	GLKMatrix4 viewProjMat = GLKMatrix4Multiply(projMat, viewMat);
	
	drawFunc(1, _cubeObject, viewProjMat, GL_TRIANGLES, 36, 0);
	drawFunc(1, _groundObject, viewProjMat, GL_TRIANGLES, 18, 0);
	
	// ブルーム０に描画
	glViewport(defaultViewport[0], defaultViewport[1], defaultViewport[2] / 4, defaultViewport[3] / 4);
	glBindFramebuffer(GL_FRAMEBUFFER, _bloomFBOLevel0[0]);
	glDisable(GL_DEPTH_TEST);
	drawFunc(2, _screenObject, GLKMatrix4Identity, GL_TRIANGLE_STRIP, 4, _hdrTexture);
	
	// ブルーム０ブラー水平
	glBindFramebuffer(GL_FRAMEBUFFER, _bloomFBOLevel0[1]);
	drawFunc(3, _screenObject, GLKMatrix4Identity, GL_TRIANGLE_STRIP, 4, _bloomTextureLevel0[0]);

	// ブルーム０ブラー垂直
	glBindFramebuffer(GL_FRAMEBUFFER, _bloomFBOLevel0[0]);
	drawFunc(4, _screenObject, GLKMatrix4Identity, GL_TRIANGLE_STRIP, 4, _bloomTextureLevel0[1]);

	// ブルーム１に描画
	glViewport(defaultViewport[0], defaultViewport[1], defaultViewport[2] / 8, defaultViewport[3] / 8);
	glBindFramebuffer(GL_FRAMEBUFFER, _bloomFBOLevel1[0]);
	drawFunc(5, _screenObject, GLKMatrix4Identity, GL_TRIANGLE_STRIP, 4, _bloomTextureLevel0[0]);

	// ブルーム１ブラー水平
	glBindFramebuffer(GL_FRAMEBUFFER, _bloomFBOLevel1[1]);
	drawFunc(3, _screenObject, GLKMatrix4Identity, GL_TRIANGLE_STRIP, 4, _bloomTextureLevel1[0]);

	// ブルーム１ブラー垂直
	glBindFramebuffer(GL_FRAMEBUFFER, _bloomFBOLevel1[0]);
	drawFunc(4, _screenObject, GLKMatrix4Identity, GL_TRIANGLE_STRIP, 4, _bloomTextureLevel1[1]);

	// 全てのブルームを加算合成
	glViewport(defaultViewport[0], defaultViewport[1], defaultViewport[2], defaultViewport[3]);
	glBindFramebuffer(GL_FRAMEBUFFER, _hdrTexture);
	glEnable(GL_BLEND);
	glBlendEquation(GL_FUNC_ADD);
	glBlendFunc(GL_ONE, GL_ONE);
	drawFunc(5, _screenObject, GLKMatrix4Identity, GL_TRIANGLE_STRIP, 4, _bloomTextureLevel0[0]);
	drawFunc(5, _screenObject, GLKMatrix4Identity, GL_TRIANGLE_STRIP, 4, _bloomTextureLevel1[0]);
	glDisable(GL_BLEND);
	
	// 輝度描画
	int32_t width = defaultViewport[2] / 4;
	int32_t height = defaultViewport[3] / 4;
	glViewport(defaultViewport[0], defaultViewport[1], width, height);
	glBindFramebuffer(GL_FRAMEBUFFER, _luminanceFBO[0]);
	drawFunc(6, _screenObject, GLKMatrix4Identity, GL_TRIANGLE_STRIP, 4, _hdrTexture);

	for (int i = 1; i < 5; ++i)
	{
		width = MAX(1, width / 4);
		height = MAX(1, height / 4);

		glViewport(defaultViewport[0], defaultViewport[1], width, height);
		glBindFramebuffer(GL_FRAMEBUFFER, _luminanceFBO[i]);
		drawFunc(5, _screenObject, GLKMatrix4Identity, GL_TRIANGLE_STRIP, 4, _luminanceTexture[i - 1]);
	}

	GLfloat buf[4];
	glBindFramebuffer(GL_FRAMEBUFFER, _luminanceFBO[4]);
	glReadPixels(0, 0, 1, 1, GL_RGBA, GL_FLOAT, buf);
	
	if (buf[0] > 0.0f)
	{
		float tmpExposure = 1.0f / buf[0];
		_exposure += (tmpExposure - _exposure) * self.timeSinceLastDraw;
	}
	
	// トーンマッピング
	glViewport(defaultViewport[0], defaultViewport[1], defaultViewport[2], defaultViewport[3]);
	glBindFramebuffer(GL_FRAMEBUFFER, defaultFBO);
	drawFunc(10, _screenObject, GLKMatrix4Identity, GL_TRIANGLE_STRIP, 4, _hdrTexture);
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders:(GLuint*)program path:(NSString*)path
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    GLuint programTmp = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:path ofType:@"vsh" inDirectory:@"Shaders"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:path ofType:@"fsh" inDirectory:@"Shaders"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(programTmp, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(programTmp, fragShader);
	
    // Link program.
    if (![self linkProgram:programTmp]) {
        NSLog(@"Failed to link program: %d", programTmp);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (programTmp) {
            glDeleteProgram(programTmp);
            programTmp = 0;
        }
        
        return NO;
    }
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(programTmp, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(programTmp, fragShader);
        glDeleteShader(fragShader);
    }
    
	*program = programTmp;
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

@end
