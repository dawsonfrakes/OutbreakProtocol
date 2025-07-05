module basic.opengl;

import basic;

@uda struct gl_version {
  u32 major;
  u32 minor;
}

// 1.0
enum GL_COLOR_BUFFER_BIT = 0x00004000;
enum GL_TRIANGLES = 0x0004;
enum GL_GREATER = 0x0204;
enum GL_GEQUAL = 0x0206;
enum GL_SRC_ALPHA = 0x0302;
enum GL_ONE_MINUS_SRC_ALPHA = 0x0303;
enum GL_FRONT_AND_BACK = 0x0408;
enum GL_CW = 0x0900;
enum GL_CULL_FACE = 0x0B44;
enum GL_DEPTH_TEST = 0x0B71;
enum GL_BLEND = 0x0BE2;
enum GL_TEXTURE_2D = 0x0DE1;
enum GL_UNSIGNED_BYTE = 0x1401;
enum GL_UNSIGNED_SHORT = 0x1403;
enum GL_UNSIGNED_INT = 0x1405;
enum GL_FLOAT = 0x1406;
enum GL_COLOR = 0x1800;
enum GL_DEPTH = 0x1801;
enum GL_RGB = 0x1907;
enum GL_RGBA = 0x1908;
enum GL_POINT = 0x1B00;
enum GL_LINE = 0x1B01;
enum GL_FILL = 0x1B02;
enum GL_VENDOR = 0x1F00;
enum GL_RENDERER = 0x1F01;
enum GL_VERSION = 0x1F02;
enum GL_NEAREST = 0x2600;
enum GL_LINEAR = 0x2601;

@gl_version(1, 0) extern(System) void glEnable(u32);
@gl_version(1, 0) extern(System) void glDisable(u32);
@gl_version(1, 0) extern(System) void glClear(u32);
@gl_version(1, 0) extern(System) void glClearColor(f32, f32, f32, f32);
@gl_version(1, 0) extern(System) void glGetIntegerv(u32, s32*);
@gl_version(1, 0) extern(System) void glFrontFace(u32);
@gl_version(1, 0) extern(System) void glDepthFunc(u32);
@gl_version(1, 0) extern(System) void glViewport(s32, s32, u32, u32);
@gl_version(1, 0) extern(System) const(char)* glGetString(u32);

// 1.1
@gl_version(1, 1) extern(System) void glDrawElements(u32, u32, u32, const(void)*);

// 1.5
enum GL_STATIC_DRAW = 0x88E4;
enum GL_DYNAMIC_DRAW = 0x88E8;

// 2.0
enum GL_FRAGMENT_SHADER = 0x8B30;
enum GL_VERTEX_SHADER = 0x8B31;
enum GL_LOWER_LEFT = 0x8CA1;

@gl_version(2, 0) extern(System) u32 glCreateProgram();
@gl_version(2, 0) extern(System) void glAttachShader(u32, u32);
@gl_version(2, 0) extern(System) void glDetachShader(u32, u32);
@gl_version(2, 0) extern(System) void glLinkProgram(u32);
@gl_version(2, 0) extern(System) void glUseProgram(u32);
@gl_version(2, 0) extern(System) u32 glCreateShader(u32);
@gl_version(2, 0) extern(System) void glDeleteShader(u32);
@gl_version(2, 0) extern(System) void glShaderSource(u32, u32, const(char*)*, const(s32)*);
@gl_version(2, 0) extern(System) void glCompileShader(u32);

// 3.0
enum GL_RGBA16F = 0x881A;
enum GL_DEPTH_COMPONENT32F = 0x8CAC;
enum GL_COLOR_ATTACHMENT0 = 0x8CE0;
enum GL_COLOR_ATTACHMENT1 = 0x8CE1;
enum GL_DEPTH_ATTACHMENT = 0x8D00;
enum GL_FRAMEBUFFER = 0x8D40;
enum GL_RENDERBUFFER = 0x8D41;
enum GL_FRAMEBUFFER_SRGB = 0x8DB9;

@gl_version(3, 0) extern(System) void glBindFramebuffer(u32, u32);
@gl_version(3, 0) extern(System) void glBindVertexArray(u32);

// 3.1
@gl_version(3, 1) extern(System) void glDrawElementsInstanced(u32, u32, u32, const(void)*, u32);

// 3.2
enum GL_MAX_COLOR_TEXTURE_SAMPLES = 0x910E;
enum GL_MAX_DEPTH_TEXTURE_SAMPLES = 0x910F;

// 4.3
enum GL_DEBUG_TYPE_ERROR = 0x824C;
enum GL_DEBUG_OUTPUT = 0x92E0;

alias GLDEBUGPROC = extern(System) void function(u32, u32, u32, u32, u32, const(char)*, const(void)*);

@gl_version(4, 3) void glDebugMessageCallback(GLDEBUGPROC, const(void)*);

// 4.5
enum GL_ZERO_TO_ONE = 0x935F;

@gl_version(4, 5) extern(System) void glClipControl(u32, u32);
@gl_version(4, 5) extern(System) void glCreateFramebuffers(u32, u32*);
@gl_version(4, 5) extern(System) void glNamedFramebufferRenderbuffer(u32, u32, u32, u32);
@gl_version(4, 5) extern(System) void glClearNamedFramebufferfv(u32, u32, s32, const(float)*);
@gl_version(4, 5) extern(System) void glBlitNamedFramebuffer(u32, u32, s32, s32, s32, s32, s32, s32, s32, s32, u32, u32);
@gl_version(4, 5) extern(System) void glCreateRenderbuffers(u32, u32*);
@gl_version(4, 5) extern(System) void glNamedRenderbufferStorageMultisample(u32, u32, u32, u32, u32);
@gl_version(4, 5) extern(System) void glCreateVertexArrays(u32, u32*);
@gl_version(4, 5) extern(System) void glVertexArrayElementBuffer(u32, u32);
@gl_version(4, 5) extern(System) void glVertexArrayVertexBuffer(u32, u32, u32, ssize, u32);
@gl_version(4, 5) extern(System) void glEnableVertexArrayAttrib(u32, u32);
@gl_version(4, 5) extern(System) void glVertexArrayAttribBinding(u32, u32, u32);
@gl_version(4, 5) extern(System) void glVertexArrayAttribFormat(u32, u32, s32, u32, bool, u32);
@gl_version(4, 5) extern(System) void glVertexArrayBindingDivisor(u32, u32, u32);
@gl_version(4, 5) extern(System) void glCreateBuffers(u32, u32*);
@gl_version(4, 5) extern(System) void glNamedBufferData(u32, usize, const(void)*, u32);
