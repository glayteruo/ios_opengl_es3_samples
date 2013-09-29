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
    PASS1_UNIFORM_MODELVIEWPROJECTION_MATRIX,
    PASS1_NUM_UNIFORMS
};
GLint uniformsPass1[PASS1_NUM_UNIFORMS];
enum
{
    PASS2_UNFIROM_TARGET_TEXTURE,
    PASS2_NUM_UNIFORMS
};
GLint uniformsPass2[PASS2_NUM_UNIFORMS];
enum
{
    PASS3_UNFIROM_TARGET_TEXTURE,
    PASS3_NUM_UNIFORMS
};
GLint uniformsPass3[PASS3_NUM_UNIFORMS];
enum
{
    PASS4_UNIFORM_MODELVIEWPROJECTION_MATRIX,
    PASS4_UNIFORM_NORMAL_MATRIX,
    PASS4_UNIFORM_LIGHT_POSITION,
	PASS4_UNIFORM_SHADOWPROJECTION_MATRIX,
	PASS4_UNFIROM_SHADOW_TEXTURE,
    PASS4_NUM_UNIFORMS
};
GLint uniformsPass4[PASS4_NUM_UNIFORMS];


enum
{
	ATTRIB_POSITION,
	ATTRIB_NORMAL,
};

static const GLsizei SHADOW_TEXTURE_SIZE = 256;

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
    -2.5f, 0.0f, -2.5f,        -1.0f, 1.0f, -1.0f,
    -2.5f, 0.0f, 2.5f,       -1.0f, 1.0f, 1.0f,
    2.5f, 0.0f, -2.5f,         1.0f, 1.0f, -1.0f,
    2.5f, 0.0f, 2.5f,        1.0f, 1.0f, 1.0f,
};

GLfloat gBlurVertexData[] =
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     texCoordX, texCoordY, texCoordZ,
    -1.0f, -1.0f, 0.0f,      0.0f, 0.0f, 0.0f,
    1.0f, -1.0f, 0.0f,       1.0f, 0.0f, 0.0f,
    -1.0f, 1.0f, 0.0f,       0.0f, 1.0f, 0.0f,
    1.0f, 1.0f, 0.0f,        1.0f, 1.0f, 0.0f,
};

struct DrawObject
{
    GLuint vao;
    GLuint vbo;

    GLKMatrix4 mMat;
};

@interface RMViewController () {
    GLuint _programPass1;
    GLuint _programPass2;
    GLuint _programPass3;
    GLuint _programPass4;
	
    float _rotation;
	GLKVector3 _lightPosition;
	
	DrawObject _cubeObject;
	DrawObject _blurObject;
	DrawObject _groundObject;
	
	GLuint _shadowFBO;
	GLuint _shadowTexture;
	GLuint _shadowRBO;
	GLuint _shadowSampler;
	
	GLuint _blurFBO;
	GLuint _blurTexture;
	GLuint _blurSampler;
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
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
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
    
    [self loadShaders:&_programPass1 path:@"ShaderPass1"];
    [self loadShaders:&_programPass2 path:@"ShaderPass2"];
    [self loadShaders:&_programPass3 path:@"ShaderPass3"];
    [self loadShaders:&_programPass4 path:@"ShaderPass4"];

	uniformsPass1[PASS1_UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_programPass1, "modelViewProjectionMatrix");

	uniformsPass2[PASS2_UNFIROM_TARGET_TEXTURE] = glGetUniformLocation(_programPass2, "targetTexture");

	uniformsPass3[PASS3_UNFIROM_TARGET_TEXTURE] = glGetUniformLocation(_programPass3, "targetTexture");

    uniformsPass4[PASS4_UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_programPass4, "modelViewProjectionMatrix");
    uniformsPass4[PASS4_UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_programPass4, "normalMatrix");
	uniformsPass4[PASS4_UNIFORM_LIGHT_POSITION] = glGetUniformLocation(_programPass4, "lightPosition");
    uniformsPass4[PASS4_UNIFORM_SHADOWPROJECTION_MATRIX] = glGetUniformLocation(_programPass4, "shadowProjectionMatrix");
	uniformsPass4[PASS4_UNFIROM_SHADOW_TEXTURE] = glGetUniformLocation(_programPass4, "shadowTexture");

	glEnable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);
	
	auto makeFunc = [](DrawObject& obj, size_t dataSize, void* data)
	{
		glGenVertexArrays(1, &obj.vao);
		glBindVertexArray(obj.vao);
		
		glGenBuffers(1, &obj.vbo);
		glBindBuffer(GL_ARRAY_BUFFER, obj.vbo);
		glBufferData(GL_ARRAY_BUFFER, dataSize, data, GL_STATIC_DRAW);
		
		glEnableVertexAttribArray(ATTRIB_POSITION);
		glVertexAttribPointer(ATTRIB_POSITION, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
		glEnableVertexAttribArray(ATTRIB_NORMAL);
		glVertexAttribPointer(ATTRIB_NORMAL, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
		
		glBindVertexArray(0);
	};
	
	// オブジェクト作成
	makeFunc(_cubeObject, sizeof(gCubeVertexData), gCubeVertexData);
	makeFunc(_blurObject, sizeof(gBlurVertexData), gBlurVertexData);
	makeFunc(_groundObject, sizeof(gGroundVertexData), gGroundVertexData);
	
	// ライト位置
	_lightPosition = GLKVector3Make(3.0f, 4.0f, 3.0f);
		
	
	// シャドウマップ用テクスチャ作成
	glGenTextures(1, &_shadowTexture);
	glBindTexture(GL_TEXTURE_2D, _shadowTexture);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RG16F, SHADOW_TEXTURE_SIZE, SHADOW_TEXTURE_SIZE, 0, GL_RG, GL_HALF_FLOAT, NULL);

	glBindTexture(GL_TEXTURE_2D, 0);
	
	// シャドウマップ用RBO作成
	glGenRenderbuffers(1, &_shadowRBO);
	glBindRenderbuffer(GL_RENDERBUFFER, _shadowRBO);
	glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, SHADOW_TEXTURE_SIZE, SHADOW_TEXTURE_SIZE);
		
	// シャドウマップ用FBO作成
	glGenFramebuffers(1, &_shadowFBO);
	glBindFramebuffer(GL_FRAMEBUFFER, _shadowFBO);
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _shadowTexture, 0);
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _shadowRBO);
	assert(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE);
	
	glBindFramebuffer(GL_FRAMEBUFFER, 0);
	
	// ブラー用テクスチャ作成
	glGenTextures(1, &_blurTexture);
	glBindTexture(GL_TEXTURE_2D, _blurTexture);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RG16F, SHADOW_TEXTURE_SIZE, SHADOW_TEXTURE_SIZE, 0, GL_RG, GL_HALF_FLOAT, NULL);
	
	glBindTexture(GL_TEXTURE_2D, 0);
	
	// ブラー用FBO作成
	glGenFramebuffers(1, &_blurFBO);
	glBindFramebuffer(GL_FRAMEBUFFER, _blurFBO);
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _blurTexture, 0);
	assert(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE);
	
	glBindFramebuffer(GL_FRAMEBUFFER, 0);
	
	
	// シャドウマップ用サンプラー作成
	glGenSamplers(1, &_shadowSampler);
	glSamplerParameteri(_shadowSampler, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glSamplerParameteri(_shadowSampler, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glSamplerParameteri(_shadowSampler, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glSamplerParameteri(_shadowSampler, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	
	// ブラー用サンプラー作成
	glGenSamplers(1, &_blurSampler);
	glSamplerParameteri(_blurSampler, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glSamplerParameteri(_blurSampler, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glSamplerParameteri(_blurSampler, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glSamplerParameteri(_blurSampler, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_groundObject.vbo);
    glDeleteVertexArrays(1, &_groundObject.vao);
    glDeleteBuffers(1, &_cubeObject.vbo);
    glDeleteVertexArrays(1, &_cubeObject.vao);
	
	glDeleteSamplers(1, &_shadowSampler);
	glDeleteTextures(1, &_shadowTexture);
	glDeleteRenderbuffers(1, &_shadowRBO);
	glDeleteFramebuffers(1, &_shadowFBO);

	glDeleteSamplers(1, &_blurSampler);
	glDeleteTextures(1, &_blurTexture);
	glDeleteFramebuffers(1, &_blurFBO);

    glDeleteProgram(_programPass1);
    glDeleteProgram(_programPass2);
    glDeleteProgram(_programPass3);
    glDeleteProgram(_programPass4);
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
	_cubeObject.mMat = GLKMatrix4MakeRotation(_rotation, 0.0f, 1.0f, 0.0f);
	_groundObject.mMat = GLKMatrix4MakeTranslation(0.0f, -1.0f, -1.0f);
	
    _rotation += self.timeSinceLastUpdate * 2.0f;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
	auto drawFunc = [&](int passNo, const DrawObject& obj, const GLKMatrix4& mvMat, const GLKMatrix4& shadowMat, GLenum mode, GLsizei count)
	{
		GLKMatrix3 nMat = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(obj.mMat), NULL);
		GLKMatrix4 mvpMat = GLKMatrix4Multiply(mvMat, obj.mMat);
		
		if (passNo == 1)
		{
			glUseProgram(_programPass1);
			glUniformMatrix4fv(uniformsPass1[PASS1_UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, GL_FALSE, mvpMat.m);
		}
		else if (passNo == 2)
		{
			glUseProgram(_programPass2);
			
			glActiveTexture(GL_TEXTURE0);
			glBindTexture(GL_TEXTURE_2D, _shadowTexture);
			glBindSampler(0, _blurSampler);
			glUniform1i(uniformsPass2[PASS2_UNFIROM_TARGET_TEXTURE], 0);
		}
		else if (passNo == 3)
		{
			glUseProgram(_programPass3);
			
			glActiveTexture(GL_TEXTURE0);
			glBindTexture(GL_TEXTURE_2D, _blurTexture);
			glBindSampler(0, _blurSampler);
			glUniform1i(uniformsPass3[PASS3_UNFIROM_TARGET_TEXTURE], 0);
		}
		else
		{
			GLKMatrix4 svpMat = GLKMatrix4Multiply(shadowMat, obj.mMat);
			
			glUseProgram(_programPass4);
			glUniformMatrix4fv(uniformsPass4[PASS4_UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, GL_FALSE, mvpMat.m);
			glUniformMatrix3fv(uniformsPass4[PASS4_UNIFORM_NORMAL_MATRIX], 1, GL_TRUE, nMat.m);
			glUniform3fv(uniformsPass4[PASS4_UNIFORM_LIGHT_POSITION], 1, _lightPosition.v);
			glUniformMatrix4fv(uniformsPass4[PASS4_UNIFORM_SHADOWPROJECTION_MATRIX], 1, GL_FALSE, svpMat.m);

			glActiveTexture(GL_TEXTURE0);
			glBindTexture(GL_TEXTURE_2D, _shadowTexture);
			glBindSampler(0, _shadowSampler);
			glUniform1i(uniformsPass4[PASS4_UNFIROM_SHADOW_TEXTURE], 0);
		}
		
		glBindVertexArray(obj.vao);
		glDrawArrays(mode, 0, count);
	};
	
	// デフォルトのFBO、ビューポートを取得しておく
	GLint defaultFBO = -1;
	glGetIntegerv(GL_FRAMEBUFFER_BINDING, &defaultFBO);
	GLint defaultViewport[4];
	glGetIntegerv(GL_VIEWPORT, defaultViewport);
	
	
	// pass1 - シャドウマップ描画
	glBindFramebuffer(GL_FRAMEBUFFER, _shadowFBO);
	glViewport(0, 0, SHADOW_TEXTURE_SIZE, SHADOW_TEXTURE_SIZE);
	
	glColorMask(GL_TRUE, GL_TRUE, GL_FALSE, GL_FALSE);
	glCullFace(GL_FRONT);
	glPolygonOffset(1.1f, 4.0f);
	glEnable(GL_POLYGON_OFFSET_FILL);
	
    glClearColor(1.0f, 1.0f, 0.0f, 0.0f);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	GLKMatrix4 shadowViewMat = GLKMatrix4MakeLookAt(_lightPosition.x, _lightPosition.y, _lightPosition.z, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f);
    GLKMatrix4 shadowProjMat = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), 1.0f, 1.0f, 100.0f);
    GLKMatrix4 shadowViewProjMat = GLKMatrix4Multiply(shadowProjMat, shadowViewMat);

	drawFunc(1, _cubeObject, shadowViewProjMat, GLKMatrix4Identity, GL_TRIANGLES, 36);
	
	// pass2 - シャドウマップにブラーをかける：横方向
	glBindFramebuffer(GL_FRAMEBUFFER, _blurFBO);
	glViewport(0, 0, SHADOW_TEXTURE_SIZE, SHADOW_TEXTURE_SIZE);
	
	glColorMask(GL_TRUE, GL_TRUE, GL_FALSE, GL_FALSE);
	glCullFace(GL_BACK);
	glDisable(GL_POLYGON_OFFSET_FILL);
	glDisable(GL_DEPTH_TEST);
	
    glClearColor(1.0f, 1.0f, 0.0f, 0.0f);
	glClear(GL_COLOR_BUFFER_BIT);
		
	drawFunc(2, _blurObject, GLKMatrix4Identity, GLKMatrix4Identity, GL_TRIANGLE_STRIP, 4);
	
	// pass3 - シャドウマップにブラーをかける：縦方向
	glBindFramebuffer(GL_FRAMEBUFFER, _shadowFBO);
	glViewport(0, 0, SHADOW_TEXTURE_SIZE, SHADOW_TEXTURE_SIZE);
		
    glClearColor(1.0f, 1.0f, 0.0f, 0.0f);
	glClear(GL_COLOR_BUFFER_BIT);
	
	drawFunc(3, _blurObject, GLKMatrix4Identity, GLKMatrix4Identity, GL_TRIANGLE_STRIP, 4);

	// pass4 - 通常描画
	glBindFramebuffer(GL_FRAMEBUFFER, defaultFBO);
	glViewport(defaultViewport[0], defaultViewport[1], defaultViewport[2], defaultViewport[3]);
	
	glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
	glEnable(GL_DEPTH_TEST);
	
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projMat = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 1.0f, 100.0f);
	GLKMatrix4 viewMat = GLKMatrix4MakeLookAt(0.0f, 2.5f, 3.5f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f);
	GLKMatrix4 viewProjMat = GLKMatrix4Multiply(projMat, viewMat);
	
	GLKMatrix4 biasMat = GLKMatrix4Make(0.5, 0, 0, 0,
										0, 0.5, 0, 0,
										0, 0, 0.5, 0,
										0.5, 0.5, 0.5, 1.0);
	GLKMatrix4 shadowViewProjMatBias = GLKMatrix4Multiply(biasMat, shadowViewProjMat);
	
	drawFunc(4, _cubeObject, viewProjMat, shadowViewProjMatBias, GL_TRIANGLES, 36);
	drawFunc(4, _groundObject, viewProjMat, shadowViewProjMatBias, GL_TRIANGLE_STRIP, 4);
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders:(GLuint*)program path:(NSString*)path
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    GLuint programTmp = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:path ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:path ofType:@"fsh"];
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
