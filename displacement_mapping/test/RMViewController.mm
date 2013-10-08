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

#include "KTXLoader.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
	UNIFORM_INVNORMAL_MATRIX,
    UNIFORM_HEIGHT_TEXTURE,
	UNIFORM_HEIGHT,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];


enum
{
	ATTRIB_POSITION,
	ATTRIB_TEXCOORD,
};

struct VertexData
{
	float posX, posY, posZ;
	float texS, texT;
};

static const int32_t DivCount = 256;
static const int32_t GridCount = DivCount * DivCount;
static const int32_t IndexCount = 2 * DivCount * (DivCount + 1) + DivCount;


@interface RMViewController () {
    GLuint _program;
    
    GLKMatrix4 _modelViewProjectionMatrix;
	GLKMatrix3 _invNormalMatrix;
	
	GLuint _heightTexture;
	GLuint _heightSampler;
	
    float _rotation;
    
    GLuint _vao;
    GLuint _vbo;
	GLuint _ibo;
}
@property (strong, nonatomic) EAGLContext *context;

- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
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
    
    [self loadShaders];
    
    glEnable(GL_DEPTH_TEST);
	glEnable(GL_CULL_FACE);
	glEnable(GL_PRIMITIVE_RESTART_FIXED_INDEX);
	
	std::vector<VertexData> vertexBuffer;
	std::vector<uint16_t> indexBuffer;
	
	float vpos = 1.0f / DivCount;
	float vtex = 1.0f / DivCount;
	
	for (int32_t y = 0; y <= DivCount; ++y)
	{
		for (int32_t x = 0; x <= DivCount; ++x)
		{
			VertexData vertex;
			vertex.posX = x * vpos - 0.5f;
			vertex.posY = y * vpos - 0.5f;
			vertex.posZ = 0.0f;
			vertex.texS = x * vtex;
			vertex.texT = 1.0f - y * vtex;
			
			vertexBuffer.push_back(vertex);
		}
	}
			
	int32_t xCount = DivCount + 1;
	
	for (int32_t y = 0; y < DivCount; ++y)
	{
		for (int32_t x = 0; x <= DivCount; ++x)
		{
			auto idx0 = x + y * xCount;
			auto idx1 = idx0 + xCount;
			indexBuffer.push_back(idx1);
			indexBuffer.push_back(idx0);
		}
		
		indexBuffer.push_back(0xFFFF);
	}
	
    glGenVertexArrays(1, &_vao);
    glBindVertexArray(_vao);
    
    glGenBuffers(1, &_vbo);
    glBindBuffer(GL_ARRAY_BUFFER, _vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexBuffer[0]) * vertexBuffer.size(), vertexBuffer.data(), GL_STATIC_DRAW);
	
	glGenBuffers(1, &_ibo);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _ibo);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indexBuffer[0]) * indexBuffer.size(), indexBuffer.data(), GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(ATTRIB_POSITION);
    glVertexAttribPointer(ATTRIB_POSITION, 3, GL_FLOAT, GL_FALSE, sizeof(VertexData), BUFFER_OFFSET(0));
    glEnableVertexAttribArray(ATTRIB_TEXCOORD);
    glVertexAttribPointer(ATTRIB_TEXCOORD, 2, GL_FLOAT, GL_FALSE, sizeof(VertexData), BUFFER_OFFSET(12));
    
    glBindVertexArray(0);
	
	// テクスチャ読み込み
	NSString* texPath = [[NSBundle mainBundle] pathForResource:@"heightmap" ofType:@"ktx"];
	NSData* texData = [NSData dataWithContentsOfFile:texPath];
	
	bool hasMipmap = false;
	try
	{
		KTXInfo texInfo = KTXLoader::Load(texData.bytes, texData.length);
		_heightTexture = texInfo.name;
		hasMipmap = texInfo.hasMipmap;
	}
	catch (std::exception& e)
	{
		NSLog(@"%s", e.what());
	}
	
	// サンプラー作成
	glGenSamplers(1, &_heightSampler);
	glSamplerParameteri(_heightSampler, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glSamplerParameteri(_heightSampler, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glSamplerParameteri(_heightSampler, GL_TEXTURE_MIN_FILTER, (hasMipmap) ? GL_LINEAR_MIPMAP_LINEAR : GL_LINEAR);
	glSamplerParameteri(_heightSampler, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
	glDeleteBuffers(1, &_ibo);
    glDeleteBuffers(1, &_vbo);
    glDeleteVertexArrays(1, &_vao);
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
	float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
	GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
	
	GLKMatrix4 viewMatrix = GLKMatrix4MakeLookAt(0.0f, 0.0f, 2.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f);
    
	GLKMatrix4 modelMatrix = GLKMatrix4MakeRotation(sin(_rotation) * 1.5, 0.0f, 1.0f, 0.0f);
    
	_invNormalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelMatrix), NULL);
	_invNormalMatrix = GLKMatrix3Invert(_invNormalMatrix, NULL);
    
	GLKMatrix4 modelViewMatrix = GLKMatrix4Multiply(viewMatrix, modelMatrix);
	_modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
    
	_rotation += self.timeSinceLastUpdate * 1.0f;
//	_rotation = -0.8f;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glBindVertexArray(_vao);
    
    glUseProgram(_program);
    
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, GL_FALSE, _modelViewProjectionMatrix.m);
    glUniformMatrix3fv(uniforms[UNIFORM_INVNORMAL_MATRIX], 1, GL_FALSE, _invNormalMatrix.m);

	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, _heightTexture);
	glBindSampler(0, _heightSampler);
	glUniform1i(uniforms[UNIFORM_HEIGHT_TEXTURE], 0);
	
	glUniform1f(uniforms[UNIFORM_HEIGHT], 0.2f);
	
    glDrawElements(GL_TRIANGLE_STRIP, IndexCount, GL_UNSIGNED_SHORT, NULL);
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
	   
    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_INVNORMAL_MATRIX] = glGetUniformLocation(_program, "invNormalMatrix");
    uniforms[UNIFORM_HEIGHT_TEXTURE] = glGetUniformLocation(_program, "heightTexture");
    uniforms[UNIFORM_HEIGHT] = glGetUniformLocation(_program, "height");
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
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
