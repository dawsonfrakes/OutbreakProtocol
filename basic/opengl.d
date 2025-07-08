module basic.opengl;

import basic;

@uda struct gl_version {
  u8 major;
  u8 minor;
}

// 1.0
enum GL_COLOR_BUFFER_BIT = 0x00004000;

@gl_version(1, 0) extern(System) {
  const(char)* glGetString(u32);
  void glGetIntegerv(u32, s32*);
  void glEnable(u32);
  void glDisable(u32);
  void glDepthFunc(u32);
  void glFrontFace(u32);
  void glBlendFunc(u32, u32);
  void glPolygonMode(u32, u32);
  void glClear(u32);
  void glClearColor(f32, f32, f32, f32);
}

// 2.0
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

// 4.5
enum GL_ZERO_TO_ONE = 0x935F;

@gl_version(4, 5) extern(System) {
  void glClipControl(u32, u32);
  void glCreateFramebuffers(u32, u32*);
  void glCreateRenderbuffers(u32, u32*);
  void glCreateVertexArrays(u32, u32*);
  void glCreateBuffers(u32, u32*);
  void glCreateTextures(u32, u32, u32*);
}
