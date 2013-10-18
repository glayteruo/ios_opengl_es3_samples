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

#include "teapot.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

#define MAX_INSTANCE_COUNT 3

// Uniform index.
enum
{
    UNIFORM_VIEWPROJECTION_MATRIX,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];


enum
{
	ATTRIB_POSITION,
	ATTRIB_NORMAL,
	ATTRIB_OFFSET,
	ATTRIB_DIFFUSE,
};

static GLKVector3 offsetList[MAX_INSTANCE_COUNT] =
{
	{0.0f, 0.2f, 0.0f},
	{0.0f, 0.0f, 0.0f},
	{0.0f, -0.2f, 0.0f},
};

static GLKVector4 diffuseList[MAX_INSTANCE_COUNT] =
{
	{0.3f, 0.1f, 0.1f, 1.0f},
	{0.1f, 0.3f, 0.1f, 1.0f},
	{0.1f, 0.1f, 0.3f, 1.0f},
};

@interface RMViewController () {
    GLuint _program;
    
    GLKMatrix4 _viewProjectionMatrix;
    
    GLuint _vao;
	
    GLuint _vbo_position;
    GLuint _vbo_normal;
	GLuint _vbo_offset;
	GLuint _vbo_diffuse;
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
    
    [self loadShaders];
    
    glEnable(GL_DEPTH_TEST);
	glEnable(GL_PRIMITIVE_RESTART_FIXED_INDEX);
	
    glGenVertexArrays(1, &_vao);
    glBindVertexArray(_vao);
    
    glGenBuffers(1, &_vbo_position);
    glBindBuffer(GL_ARRAY_BUFFER, _vbo_position);
    glBufferData(GL_ARRAY_BUFFER, sizeof(teapot_vertices), teapot_vertices, GL_STATIC_DRAW);
    glEnableVertexAttribArray(ATTRIB_POSITION);
    glVertexAttribPointer(ATTRIB_POSITION, 3, GL_FLOAT, GL_FALSE, 12, BUFFER_OFFSET(0));

	glGenBuffers(1, &_vbo_normal);
    glBindBuffer(GL_ARRAY_BUFFER, _vbo_normal);
    glBufferData(GL_ARRAY_BUFFER, sizeof(teapot_normals), teapot_normals, GL_STATIC_DRAW);
    glEnableVertexAttribArray(ATTRIB_NORMAL);
    glVertexAttribPointer(ATTRIB_NORMAL, 3, GL_FLOAT, GL_FALSE, 12, BUFFER_OFFSET(0));
	
	glGenBuffers(1, &_vbo_offset);
	glBindBuffer(GL_ARRAY_BUFFER, _vbo_offset);
	glBufferData(GL_ARRAY_BUFFER, sizeof(offsetList), offsetList, GL_STATIC_DRAW);
	glEnableVertexAttribArray(ATTRIB_OFFSET);
	glVertexAttribPointer(ATTRIB_OFFSET, 3, GL_FLOAT, GL_FALSE, 12, BUFFER_OFFSET(0));
	glVertexAttribDivisor(ATTRIB_OFFSET, 1);

	glGenBuffers(1, &_vbo_diffuse);
	glBindBuffer(GL_ARRAY_BUFFER, _vbo_diffuse);
	glBufferData(GL_ARRAY_BUFFER, sizeof(diffuseList), diffuseList, GL_STATIC_DRAW);
	glEnableVertexAttribArray(ATTRIB_DIFFUSE);
	glVertexAttribPointer(ATTRIB_DIFFUSE, 4, GL_FLOAT, GL_FALSE, 16, BUFFER_OFFSET(0));
	glVertexAttribDivisor(ATTRIB_DIFFUSE, 1);

	glGenBuffers(1, &_ibo);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _ibo);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(teapot_indices), teapot_indices, GL_STATIC_DRAW);
    glBindVertexArray(0);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
	glDeleteBuffers(1, &_ibo);
    glDeleteBuffers(1, &_vbo_normal);
    glDeleteBuffers(1, &_vbo_position);
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
	GLKMatrix4 viewMatrix = GLKMatrix4MakeLookAt(0.0f, 0.2f, 0.6f, 0.0f, 0.1f, 0.0f, 0.0f, 1.0f, 0.0f);

	_viewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, viewMatrix);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.4f, 0.4f, 0.4f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glBindVertexArray(_vao);
    
    glUseProgram(_program);
    
    glUniformMatrix4fv(uniforms[UNIFORM_VIEWPROJECTION_MATRIX], 1, GL_FALSE, _viewProjectionMatrix.m);
	
	uint32_t indexCount = sizeof(teapot_indices) / sizeof(teapot_indices[0]);
	glDrawElementsInstanced(GL_TRIANGLE_STRIP, indexCount, GL_UNSIGNED_SHORT, NULL, MAX_INSTANCE_COUNT);
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
    uniforms[UNIFORM_VIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "viewProjectionMatrix");
    
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
