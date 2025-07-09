module basic.opengl;

import basic;

@uda struct gl_version {
  u8 major;
  u8 minor;
}

// 1.0
enum GL_COLOR_BUFFER_BIT = 0x00004000;
enum GL_TRIANGLES = 0x0004;
enum GL_LEQUAL = 0x0203;
enum GL_SRC_ALPHA = 0x0302;
enum GL_ONE_MINUS_SRC_ALPHA = 0x0303;
enum GL_FRONT_AND_BACK = 0x0408;
enum GL_CW = 0x0900;
enum GL_CCW = 0x0901;
enum GL_CULL_FACE = 0x0B44;
enum GL_DEPTH_TEST = 0x0B71;
enum GL_BLEND = 0x0BE2;
enum GL_SCISSOR_TEST = 0x0C11;
enum GL_TEXTURE_2D = 0x0DE1;
enum GL_UNSIGNED_BYTE = 0x1401;
enum GL_UNSIGNED_SHORT = 0x1403;
enum GL_UNSIGNED_INT = 0x1405;
enum GL_FLOAT = 0x1406;
enum GL_COLOR = 0x1800;
enum GL_DEPTH = 0x1801;
enum GL_RED = 0x1903;
enum GL_GREEN = 0x1904;
enum GL_BLUE = 0x1905;
enum GL_ALPHA = 0x1906;
enum GL_RGB = 0x1907;
enum GL_RGBA = 0x1908;
enum GL_POINT = 0x1B00;
enum GL_LINE = 0x1B01;
enum GL_FILL = 0x1B02;
enum GL_VENDOR = 0x1F00;
enum GL_RENDERER = 0x1F01;
enum GL_VERSION = 0x1F02;
enum GL_EXTENSIONS = 0x1F03;
enum GL_NEAREST = 0x2600;
enum GL_LINEAR = 0x2601;
enum GL_NEAREST_MIPMAP_NEAREST = 0x2700;
enum GL_LINEAR_MIPMAP_NEAREST = 0x2701;
enum GL_NEAREST_MIPMAP_LINEAR = 0x2702;
enum GL_LINEAR_MIPMAP_LINEAR = 0x2703;
enum GL_TEXTURE_MAG_FILTER = 0x2800;
enum GL_TEXTURE_MIN_FILTER = 0x2801;
enum GL_TEXTURE_WRAP_S = 0x2802;
enum GL_TEXTURE_WRAP_T = 0x2803;
enum GL_REPEAT = 0x2901;

@gl_version(1, 0) extern(System) {
  const(char)* glGetString(u32);
  void glGetIntegerv(u32, s32*);
  void glEnable(u32);
  void glDisable(u32);
  void glDepthFunc(u32);
  void glFrontFace(u32);
  void glBlendFunc(u32, u32);
  void glPolygonMode(u32, u32);
  void glViewport(s32, s32, u32, u32);
  void glClear(u32);
  void glClearColor(f32, f32, f32, f32);
}

// 1.1
@gl_version(1, 1) extern(System) {
  void glDrawElements(u32, u32, u32, const(void)*);
}

// 1.5
enum GL_STATIC_DRAW = 0x88E4;
enum GL_DYNAMIC_DRAW = 0x88E8;

// 2.0
enum GL_FRAGMENT_SHADER = 0x8B30;
enum GL_VERTEX_SHADER = 0x8B31;
enum GL_LOWER_LEFT = 0x8CA1;

@gl_version(2, 0) extern(System) {
  u32 glCreateProgram();
  void glAttachShader(u32, u32);
  void glDetachShader(u32, u32);
  void glLinkProgram(u32);
  void glUseProgram(u32);
  u32 glCreateShader(u32);
  void glDeleteShader(u32);
  void glShaderSource(u32, u32, const(char*)*, const(s32)*);
  void glCompileShader(u32);
}

// 3.0
enum GL_RGBA16F = 0x881A;
enum GL_DEPTH_COMPONENT32F = 0x8CAC;
enum GL_COLOR_ATTACHMENT0 = 0x8CE0;
enum GL_COLOR_ATTACHMENT1 = 0x8CE1;
enum GL_DEPTH_ATTACHMENT = 0x8D00;
enum GL_FRAMEBUFFER = 0x8D40;
enum GL_RENDERBUFFER = 0x8D41;
enum GL_FRAMEBUFFER_SRGB = 0x8DB9;

@gl_version(3, 0) extern(System) {
  void glBindFramebuffer(u32, u32);
  void glBindVertexArray(u32);
}

// 3.2
enum GL_MAX_COLOR_TEXTURE_SAMPLES = 0x910E;
enum GL_MAX_DEPTH_TEXTURE_SAMPLES = 0x910F;

// 4.3
enum GL_DEBUG_OUTPUT = 0x92E0;

alias GLDEBUGPROC = extern(System) void function(u32, u32, u32, u32, u32, const(char)*, const(void)*);

@gl_version(4, 3) extern(System) {
  void glDebugMessageCallback(GLDEBUGPROC, const(void)*);
}

// 4.5
enum GL_ZERO_TO_ONE = 0x935F;

@gl_version(4, 5) extern(System) {
  void glClipControl(u32, u32);
  void glCreateFramebuffers(u32, u32*);
  void glNamedFramebufferRenderbuffer(u32, u32, u32, u32);
  void glClearNamedFramebufferfv(u32, u32, s32, const(f32)*);
  void glBlitNamedFramebuffer(u32, u32, s32, s32, s32, s32, s32, s32, s32, s32, u32, u32);
  void glCreateRenderbuffers(u32, u32*);
  void glNamedRenderbufferStorageMultisample(u32, u32, u32, u32, u32);
  void glCreateVertexArrays(u32, u32*);
  void glVertexArrayVertexBuffer(u32, u32, u32, ssize, u32);
  void glVertexArrayElementBuffer(u32, u32);
  void glVertexArrayBindingDivisor(u32, u32, u32);
  void glEnableVertexArrayAttrib(u32, u32);
  void glVertexArrayAttribBinding(u32, u32, u32);
  void glVertexArrayAttribFormat(u32, u32, s32, u32, bool, u32);
  void glCreateBuffers(u32, u32*);
  void glNamedBufferData(u32, usize, const(void)*, u32);
  void glNamedBufferSubData(u32, ssize, usize, const(void)*);
  void glCreateTextures(u32, u32, u32*);
}
