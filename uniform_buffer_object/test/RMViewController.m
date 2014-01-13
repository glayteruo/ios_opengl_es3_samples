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

#define MAX_INSTANCE_COUNT 2

enum
{
	UNIFORM_BLOCK_INDEX_PROJECTION_MATRIX,
	UNIFORM_BLOCK_INDEX_VIEW_MATRIX,
	
	UNIFORM_BLOCK_INDEX_COUNT
};

// Uniform index.
enum
{
	UNIFORM_PROJECTION_MATRIX,
    UNIFORM_VIEW_MATRIX,
	UNIFORM_MODEL_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];


enum
{
	ATTRIB_POSITION,
	ATTRIB_NORMAL,
};

static GLKVector3 positionList[MAX_INSTANCE_COUNT] =
{
	{0.0f, 0.1f, 0.0f},
	{0.0f, -0.15f, 0.0f},
};

static GLKVector3 rotationList[MAX_INSTANCE_COUNT] =
{
	{0.0f, 1.0, 0.0f},
	{0.0f, -1.0, 0.0f},
};

@interface RMViewController () {
    GLuint _programList[MAX_INSTANCE_COUNT];
	
	GLuint _uniformBlockIndex;
	GLint _uniformBlockSize;
	GLubyte* _uniformBlockBuffer;
	GLuint _uniformBlockIndeces[UNIFORM_BLOCK_INDEX_COUNT];
	GLint _uniformBlockOffsets[UNIFORM_BLOCK_INDEX_COUNT];
	GLuint _ubo;
    
    GLKMatrix4 _projectionMatrix;
    GLKMatrix4 _viewMatrix;
	GLKMatrix4 _modelMatrixList[MAX_INSTANCE_COUNT];
    GLKMatrix3 _normalMatrixList[MAX_INSTANCE_COUNT];
    float _rotation;
    
    GLuint _vao;
	
    GLuint _vbo_position;
    GLuint _vbo_normal;
    GLuint _ibo;
}
@property (strong, nonatomic) EAGLContext *context;

- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders:(GLuint*)program file:(NSString*)file;
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
    
    [self loadShaders:&_programList[0] file:@"Shader0"];
    [self loadShaders:&_programList[1] file:@"Shader1"];
	
    // ユニフォームの取得
	GLuint program = _programList[0];
    uniforms[UNIFORM_PROJECTION_MATRIX] = glGetUniformLocation(program, "projectionMatrix");
    uniforms[UNIFORM_VIEW_MATRIX] = glGetUniformLocation(program, "viewMatrix");
    uniforms[UNIFORM_MODEL_MATRIX] = glGetUniformLocation(program, "modelMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(program, "normalMatrix");
	
	// ユニフォームブロックインデックス取得
	_uniformBlockIndex = glGetUniformBlockIndex(program, "CommonMatrix");
	
	// ユニフォームブロックサイズ取得
	glGetActiveUniformBlockiv(program, _uniformBlockIndex, GL_UNIFORM_BLOCK_DATA_SIZE, &_uniformBlockSize);
    
	// バッファ確保
	_uniformBlockBuffer = (GLubyte*)malloc(_uniformBlockSize);
	
	// 各変数のブロックのインデックスを取得
	const char* names[] = {"projectionMatrix", "viewMatrix"};
	glGetUniformIndices(program, UNIFORM_BLOCK_INDEX_COUNT, names, _uniformBlockIndeces);
	
	// 各変数のオフセットを取得
	glGetActiveUniformsiv(program, UNIFORM_BLOCK_INDEX_COUNT, _uniformBlockIndeces, GL_UNIFORM_OFFSET, _uniformBlockOffsets);
		
	// ユニフォームバッファオブジェクト作成
	glGenBuffers(1, &_ubo);
	glBindBuffer(GL_UNIFORM_BUFFER, _ubo);
	
	
	
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
    
    if (_programList[0]) {
        glDeleteProgram(_programList[0]);
    }
    if (_programList[1]) {
        glDeleteProgram(_programList[1]);
    }
	
	free(_uniformBlockBuffer);
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
	float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
	_projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
	_viewMatrix = GLKMatrix4MakeLookAt(0.0f, 0.0f, 0.8f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f);
	
	for (int i = 0; i < MAX_INSTANCE_COUNT; ++i)
	{
		GLKVector3* position = &positionList[i];
		GLKVector3* rotation = &rotationList[i];
		GLKMatrix4 modelMatrix = GLKMatrix4MakeTranslation(position->x, position->y, position->z);
		modelMatrix = GLKMatrix4Rotate(modelMatrix, _rotation, rotation->x, rotation->y, rotation->z);
		
		_modelMatrixList[i] = modelMatrix;
		_normalMatrixList[i] = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelMatrix), NULL);
	}
	
	_rotation += self.timeSinceLastUpdate * 1.0f;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
	// データを配置
	memcpy(_uniformBlockBuffer + _uniformBlockOffsets[UNIFORM_BLOCK_INDEX_PROJECTION_MATRIX], _projectionMatrix.m, sizeof(_projectionMatrix));
	memcpy(_uniformBlockBuffer + _uniformBlockOffsets[UNIFORM_BLOCK_INDEX_VIEW_MATRIX], _viewMatrix.m, sizeof(_viewMatrix));
	
	// バッファコピー
	glBufferData(GL_UNIFORM_BUFFER, _uniformBlockSize, _uniformBlockBuffer, GL_DYNAMIC_DRAW);
	
	
	
    glClearColor(0.4f, 0.4f, 0.4f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glBindVertexArray(_vao);
    
	uint32_t indexCount = sizeof(teapot_indices) / sizeof(teapot_indices[0]);

	for (uint32_t i = 0; i < MAX_INSTANCE_COUNT; ++i)
	{
		glUseProgram(_programList[i]);
		
		// ユニフォームバッファオブジェクトをバインド
		glBindBufferBase(GL_UNIFORM_BUFFER, _uniformBlockIndex, _ubo);
		
		glUniformMatrix4fv(uniforms[UNIFORM_MODEL_MATRIX], 1, GL_FALSE, _modelMatrixList[i].m);
		glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, GL_FALSE, _normalMatrixList[i].m);
		glDrawElements(GL_TRIANGLE_STRIP, indexCount, GL_UNSIGNED_SHORT, NULL);
	}
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders:(GLuint*)program file:(NSString*)file
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    GLuint tmpProgram = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:file ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:file ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(tmpProgram, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(tmpProgram, fragShader);
	   
    // Link program.
    if (![self linkProgram:tmpProgram]) {
        NSLog(@"Failed to link program: %d", tmpProgram);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (tmpProgram) {
            glDeleteProgram(tmpProgram);
            tmpProgram = 0;
        }
        
        return NO;
    }
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(tmpProgram, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(tmpProgram, fragShader);
        glDeleteShader(fragShader);
    }
    
	*program = tmpProgram;
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
