module basic.opengl;

import basic : uda;

@uda struct gl_version {
  uint major;
  uint minor;
}

// 1.0
@gl_version(1, 0) extern(System) void glClearColor(float, float, float, float);
@gl_version(1, 0) extern(System) void glClear(uint);

// 2.0
enum GL_LOWER_LEFT = 0x8CA1;

// 4.5
enum GL_ZERO_TO_ONE = 0x935F;

@gl_version(4, 5) extern(System) void glClipControl(uint, uint);
