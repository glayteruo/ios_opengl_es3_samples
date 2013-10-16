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

#include <algorithm>
#include <vector>

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

static const int32_t ParticleCount = 100;

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
	UNIFORM_DELTA_TIME,
	UNIFORM_STAR_TEXTURE,

	NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];


enum
{
	ATTRIB_POSITION,
	ATTRIB_VELOCITY,
	ATTRIB_COLOR,
	ATTRIB_SIZE,
};

struct ParticleVertex
{
	GLfloat posX, posY, posZ;
	GLfloat velX, velY, velZ;
	GLfloat colR, colG, colB;
	GLfloat size;
};

struct ParticleBuffer
{
    GLuint vao;
    GLuint vbo;
	GLuint feedback;
};

@interface RMViewController () {
    GLuint _program;
    
    GLKMatrix4 _modelViewProjectionMatrix;
    
	uint32_t _drawBufferIndex;
	ParticleBuffer _particleBuffer[2];
		
	GLuint _starTexture;
	GLuint _starSampler;
}
@property (strong, nonatomic) EAGLContext *context;

- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders:(GLuint*)program path:(NSString*)path;
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
    
	self.preferredFramesPerSecond = 60;
	
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
	view.drawableColorFormat = GLKViewDrawableColorFormatSRGBA8888;
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
    
    [self loadShaders:&_program path:@"Shader"];
	
	uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
	uniforms[UNIFORM_DELTA_TIME] = glGetUniformLocation(_program, "deltaTime");
    uniforms[UNIFORM_STAR_TEXTURE] = glGetUniformLocation(_program, "starTexture");

	glEnable(GL_BLEND);
	glBlendEquation(GL_FUNC_ADD);
	glBlendFunc(GL_ONE, GL_ONE);
	
	
	auto getRand_0_1 = [] {
		float val = rand();
		val /= RAND_MAX;
		
		return val;
	};
	auto getRand_m1_1 = [&] {
		float val = getRand_0_1();
		return val * 2.0f - 1.0f;
	};
	
	std::vector<ParticleVertex> vertexList(ParticleCount);
	for (auto& vertex : vertexList)
	{
		vertex.posX = 0.0f;
		vertex.posY = 0.0f;
		vertex.posZ = 0.0f;
		
		vertex.velX = getRand_m1_1() * 0.2 + 0.2;
		vertex.velY = getRand_m1_1() * 0.5 + 0.5;
		vertex.velZ = getRand_m1_1() * 0.05;
		
		vertex.colR = getRand_0_1();
		vertex.colG = getRand_0_1();
		vertex.colB = getRand_0_1();
		
		vertex.size = 0.0f;
	}
	
	_drawBufferIndex = 0;
	
	for (auto& particleBuffer : _particleBuffer)
	{
		glGenVertexArrays(1, &particleBuffer.vao);
		glBindVertexArray(particleBuffer.vao);
		
		glGenBuffers(1, &particleBuffer.vbo);
		glBindBuffer(GL_ARRAY_BUFFER, particleBuffer.vbo);
		glBufferData(GL_ARRAY_BUFFER, vertexList.size() * sizeof(vertexList[0]), vertexList.data(), GL_STATIC_DRAW);
		
		glEnableVertexAttribArray(ATTRIB_POSITION);
		glEnableVertexAttribArray(ATTRIB_VELOCITY);
		glEnableVertexAttribArray(ATTRIB_COLOR);
		glEnableVertexAttribArray(ATTRIB_SIZE);
		
		glVertexAttribPointer(ATTRIB_POSITION, 3, GL_FLOAT, GL_FALSE, sizeof(ParticleVertex), BUFFER_OFFSET(0));
		glVertexAttribPointer(ATTRIB_VELOCITY, 3, GL_FLOAT, GL_FALSE, sizeof(ParticleVertex), BUFFER_OFFSET(12));
		glVertexAttribPointer(ATTRIB_COLOR, 3, GL_FLOAT, GL_FALSE, sizeof(ParticleVertex), BUFFER_OFFSET(24));
		glVertexAttribPointer(ATTRIB_SIZE, 1, GL_FLOAT, GL_FALSE, sizeof(ParticleVertex), BUFFER_OFFSET(36));
		
		glBindVertexArray(0);

		
		glGenTransformFeedbacks(1, &particleBuffer.feedback);
		glBindTransformFeedback(GL_TRANSFORM_FEEDBACK, particleBuffer.feedback);
		glBindBufferBase(GL_TRANSFORM_FEEDBACK_BUFFER, 0, particleBuffer.vbo);
		
		glBindTransformFeedback(GL_TRANSFORM_FEEDBACK, 0);
	}
	
	NSString* starPath = [[NSBundle mainBundle] pathForResource:@"star" ofType:@"ktx" inDirectory:@"Textures"];
	NSData* starData = [NSData dataWithContentsOfFile:starPath];
	
	bool hasMipmap = false;
	try
	{
		auto info = KTXLoader::Load(starData.bytes, starData.length, false);
		_starTexture = info.name;
		hasMipmap = info.hasMipmap;
	}
	catch (std::exception e)
	{
		NSLog(@"%s", e.what());
	}
	
	glGenSamplers(1, &_starSampler);
	glSamplerParameteri(_starSampler, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glSamplerParameteri(_starSampler, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glSamplerParameteri(_starSampler, GL_TEXTURE_MIN_FILTER, (hasMipmap) ? GL_LINEAR_MIPMAP_LINEAR : GL_LINEAR);
	glSamplerParameteri(_starSampler, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
	for (auto& particleBuffer : _particleBuffer)
	{
		glDeleteTransformFeedbacks(1, &particleBuffer.feedback);
	    glDeleteBuffers(1, &particleBuffer.vbo);
    	glDeleteVertexArrays(1, &particleBuffer.vao);
	}
	
	glDeleteTextures(1, &_starTexture);
    
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
	
	GLKMatrix4 viewMatrix = GLKMatrix4MakeLookAt(0.0f, 0.2f, 0.5f, 0.0f, 0.05f, 0.0f, 0.0f, 1.0f, 0.0f);
    
	GLKMatrix4 modelMatrix = GLKMatrix4MakeTranslation(-0.2f, -0.2f, 0.0f);
    
	GLKMatrix4 modelViewMatrix = GLKMatrix4Multiply(viewMatrix, modelMatrix);
    
    _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glBindVertexArray(_particleBuffer[_drawBufferIndex].vao);
    glUseProgram(_program);
	
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
	glUniform1f(uniforms[UNIFORM_DELTA_TIME], self.timeSinceLastDraw);
	
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, _starTexture);
	glUniform1i(uniforms[UNIFORM_STAR_TEXTURE], 0);
	glBindSampler(0, _starSampler);
	
	glBindTransformFeedback(GL_TRANSFORM_FEEDBACK, _particleBuffer[_drawBufferIndex ^ 1].feedback);
	glBeginTransformFeedback(GL_POINTS);
	{
		glDrawArrays(GL_POINTS, 0, ParticleCount);
	}
	glEndTransformFeedback();
	
	_drawBufferIndex ^= 1;
	
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
	
	// Transform Feedback
	const char* feedbackNames[] = {
		"feedbackPosition",
		"feedbackVelocity",
		"feedbackColor",
		"feedbackSize",
	};
	GLsizei count = sizeof(feedbackNames) / sizeof(feedbackNames[0]);
	glTransformFeedbackVaryings(programTmp, count, feedbackNames, GL_INTERLEAVED_ATTRIBS);

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
