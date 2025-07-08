import basic;

enum Platform_Renderer_Bits : u32 {
  NULL = 0,
  D3D11 = 1 << 0,
  OPENGL = 1 << 1,
}

struct Platform_Renderer {
  void function() init_;
  void function() deinit;
  void function() resize;
  void function() present;
}
