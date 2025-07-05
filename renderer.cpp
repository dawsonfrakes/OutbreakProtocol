#define OP_RENDERER_FLAG_NULL (0)
#define OP_RENDERER_FLAG_OPENGL (1 << 0)
#define OP_RENDERER_FLAG_D3D11 (1 << 1)

#if OP_OS_WINDOWS
  #define OP_RENDERERS (OP_RENDERER_FLAG_OPENGL | OP_RENDERER_FLAG_D3D11)
#endif

struct Platform_Renderer {
  void (*init)();
  void (*deinit)();
  void (*resize)();
  void (*present)(Game_Renderer*);
};

static void null_renderer_proc() {}
static void null_renderer_present_proc(Game_Renderer* game_renderer) { (void) game_renderer; }
static Platform_Renderer null_renderer = {
  null_renderer_proc,
  null_renderer_proc,
  null_renderer_proc,
  null_renderer_present_proc,
};

#if OP_RENDERERS & OP_RENDERER_FLAG_OPENGL
  #include "renderer_opengl.cpp"
#endif

#if OP_RENDERERS & OP_RENDERER_FLAG_D3D11
  #include "renderer_d3d11.cpp"
#endif
