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
	UNIFORM_NORMAL_MATRIX,
    UNIFORM_NORMAL_TEXTURE,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];


enum
{
	ATTRIB_POSITION,
	ATTRIB_NORMAL,
	ATTRIB_TANGENT,
	ATTRIB_TEXCOORD,
};

GLfloat gPolyData[] =
{
    // Data layout for each line below is:
    // position,           normal,              tangent,              texcoord
    -0.5f, -0.5f, 0.0f,    0.0f, 0.0f, 1.0f,    1.0f, 0.0f, 0.0f,     0.0f, 1.0f,
     0.5f, -0.5f, 0.0f,    0.0f, 0.0f, 1.0f,    1.0f, 0.0f, 0.0f,     1.0f, 1.0f,
    -0.5f,  0.5f, 0.0f,    0.0f, 0.0f, 1.0f,    1.0f, 0.0f, 0.0f,     0.0f, 0.0f,
     0.5f,  0.5f, 0.0f,    0.0f, 0.0f, 1.0f,    1.0f, 0.0f, 0.0f,     1.0f, 0.0f,
};

@interface RMViewController () {
    GLuint _program;
    
    GLKMatrix4 _modelViewProjectionMatrix;
	GLKMatrix3 _normalMatrix;
	
	GLuint _normalTexture;
	GLuint _normalSampler;
	
    float _rotation;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
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
	
    glGenVertexArrays(1, &_vertexArray);
    glBindVertexArray(_vertexArray);
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(gPolyData), gPolyData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(ATTRIB_POSITION);
    glVertexAttribPointer(ATTRIB_POSITION, 3, GL_FLOAT, GL_FALSE, 44, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(ATTRIB_NORMAL);
    glVertexAttribPointer(ATTRIB_NORMAL, 3, GL_FLOAT, GL_FALSE, 44, BUFFER_OFFSET(12));
    glEnableVertexAttribArray(ATTRIB_TANGENT);
    glVertexAttribPointer(ATTRIB_TANGENT, 3, GL_FLOAT, GL_FALSE, 44, BUFFER_OFFSET(24));
    glEnableVertexAttribArray(ATTRIB_TEXCOORD);
    glVertexAttribPointer(ATTRIB_TEXCOORD, 2, GL_FLOAT, GL_FALSE, 44, BUFFER_OFFSET(36));
    
    glBindVertexArray(0);
	
	// テクスチャ読み込み
	NSString* texPath = [[NSBundle mainBundle] pathForResource:@"normalmap" ofType:@"ktx"];
	NSData* texData = [NSData dataWithContentsOfFile:texPath];
	
	bool hasMipmap = false;
	try
	{
		KTXInfo texInfo = KTXLoader::Load(texData.bytes, texData.length);
		_normalTexture = texInfo.name;
		hasMipmap = texInfo.hasMipmap;
	}
	catch (std::exception& e)
	{
		NSLog(@"%s", e.what());
	}
	
	// サンプラー作成
	glGenSamplers(1, &_normalSampler);
	glSamplerParameteri(_normalSampler, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glSamplerParameteri(_normalSampler, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glSamplerParameteri(_normalSampler, GL_TEXTURE_MIN_FILTER, (hasMipmap) ? GL_LINEAR_MIPMAP_LINEAR : GL_LINEAR);
	glSamplerParameteri(_normalSampler, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArrays(1, &_vertexArray);
    
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
    
	_normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelMatrix), NULL);
    
	GLKMatrix4 modelViewMatrix = GLKMatrix4Multiply(viewMatrix, modelMatrix);
	_modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
    
	_rotation += self.timeSinceLastUpdate * 1.0f;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glBindVertexArray(_vertexArray);
    
    glUseProgram(_program);
    
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, GL_FALSE, _modelViewProjectionMatrix.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, GL_FALSE, _normalMatrix.m);

	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, _normalTexture);
	glBindSampler(0, _normalSampler);
	glUniform1i(uniforms[UNIFORM_NORMAL_TEXTURE], 0);
	
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
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
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
    uniforms[UNIFORM_NORMAL_TEXTURE] = glGetUniformLocation(_program, "normalTexture");
    
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
