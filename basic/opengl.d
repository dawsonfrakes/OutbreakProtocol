module basic.opengl;

import basic : uda;

@uda struct gl_version {
  uint major;
  uint minor;
}

// 1.0
enum GL_COLOR_BUFFER_BIT = 0x00004000;
enum GL_TRIANGLES = 0x0004;
enum GL_GEQUAL = 0x0206;
enum GL_SRC_ALPHA = 0x0302;
enum GL_ONE_MINUS_SRC_ALPHA = 0x0303;
enum GL_FRONT_AND_BACK = 0x0408;
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
enum GL_RGBA = 0x1908;
enum GL_POINT = 0x1B00;
enum GL_LINE = 0x1B01;
enum GL_FILL = 0x1B02;
enum GL_NEAREST = 0x2600;
enum GL_LINEAR = 0x2601;

@gl_version(1, 0) extern(System) void glEnable(uint);
@gl_version(1, 0) extern(System) void glDisable(uint);
@gl_version(1, 0) extern(System) void glClearColor(float, float, float, float);
@gl_version(1, 0) extern(System) void glClear(uint);
@gl_version(1, 0) extern(System) void glGetIntegerv(uint, int*);

// 2.0
enum GL_LOWER_LEFT = 0x8CA1;

// 3.0
enum GL_RGBA16F = 0x881A;
enum GL_DEPTH_COMPONENT32F = 0x8CAC;
enum GL_COLOR_ATTACHMENT0 = 0x8CE0;
enum GL_DEPTH_ATTACHMENT = 0x8D00;
enum GL_FRAMEBUFFER = 0x8D40;
enum GL_RENDERBUFFER = 0x8D41;
enum GL_FRAMEBUFFER_SRGB = 0x8DB9;

// 3.2
enum GL_MAX_COLOR_TEXTURE_SAMPLES = 0x910E;
enum GL_MAX_DEPTH_TEXTURE_SAMPLES = 0x910F;

// 4.5
enum GL_ZERO_TO_ONE = 0x935F;

@gl_version(4, 5) extern(System) void glClipControl(uint, uint);
@gl_version(4, 5) extern(System) void glCreateFramebuffers(uint, uint*);
@gl_version(4, 5) extern(System) void glNamedFramebufferRenderbuffer(uint, uint, uint, uint);
@gl_version(4, 5) extern(System) void glClearNamedFramebufferfv(uint, uint, int, const(float)*);
@gl_version(4, 5) extern(System) void glBlitNamedFramebuffer(uint, uint, int, int, int, int, int, int, int, int, uint, uint);
@gl_version(4, 5) extern(System) void glCreateRenderbuffers(uint, uint*);
@gl_version(4, 5) extern(System) void glNamedRenderbufferStorageMultisample(uint, uint, uint, uint, uint);
