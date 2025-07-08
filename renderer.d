import basic;

enum Platform_Renderer_Bits : u32 {
  NULL = 0,
  D3D11 = 1 << 0,
  OPENGL = 1 << 1,
}

struct Platform_Renderer {
  struct Init_Data {
    version (Windows) {
      import basic.windows : HWND;
      HWND hwnd;
    }
    ushort[2] size;
  }

  void function(Init_Data*) init_;
  void function() deinit;
  void function(ushort[2]) resize;
  void function() present;
}
