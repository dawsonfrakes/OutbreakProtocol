// 1.0
#define GL_COLOR_BUFFER_BIT 0x00004000

#define GL10_FUNCTIONS \
  X(void, glEnable, u32) \
  X(void, glDisable, u32) \
  X(void, glClearColor, f32, f32, f32, f32) \
  X(void, glClear, u32)

#if OP_OS_WINDOWS
  #define WGL_CONTEXT_MAJOR_VERSION_ARB 0x2091
  #define WGL_CONTEXT_MINOR_VERSION_ARB 0x2092
  #define WGL_CONTEXT_LAYER_PLANE_ARB 0x2093
  #define WGL_CONTEXT_FLAGS_ARB 0x2094
  #define WGL_CONTEXT_PROFILE_MASK_ARB 0x9126
  #define WGL_CONTEXT_DEBUG_BIT_ARB 0x0001
  #define WGL_CONTEXT_CORE_PROFILE_BIT_ARB 0x00000001

  static HGLRC platform_hglrc;

  #define X(RET, NAME, ...) extern "C" RET WINAPI NAME(__VA_ARGS__);
  GL10_FUNCTIONS
  #undef X

  static void opengl_platform_init() {
    PIXELFORMATDESCRIPTOR pfd = {};
    pfd.nSize = sizeof(PIXELFORMATDESCRIPTOR);
    pfd.nVersion = 1;
    pfd.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER | PFD_DEPTH_DONTCARE;
    pfd.cColorBits = 24;
    s32 format = ChoosePixelFormat(platform_hdc, &pfd);
    SetPixelFormat(platform_hdc, format, &pfd);

    HGLRC temp_ctx = wglCreateContext(platform_hdc);
    wglMakeCurrent(platform_hdc, temp_ctx);

    typedef HGLRC (WINAPI* PFN_wglCreateContextAttribsARB)(HDC, HGLRC, s32*);
    auto wglCreateContextAttribsARB = cast(
      PFN_wglCreateContextAttribsARB,
      wglGetProcAddress("wglCreateContextAttribsARB"));

    static s32 attribs[] = {
      WGL_CONTEXT_MAJOR_VERSION_ARB, 4,
      WGL_CONTEXT_MINOR_VERSION_ARB, 5,
      WGL_CONTEXT_FLAGS_ARB, OP_DEBUG ? WGL_CONTEXT_DEBUG_BIT_ARB : 0,
      WGL_CONTEXT_PROFILE_MASK_ARB, WGL_CONTEXT_CORE_PROFILE_BIT_ARB,
      0,
    };
    platform_hglrc = wglCreateContextAttribsARB(platform_hdc, nullptr, attribs);
    wglMakeCurrent(platform_hdc, platform_hglrc);

    wglDeleteContext(temp_ctx);
  }

  static void opengl_platform_deinit() {
    if (platform_hglrc) {
      wglMakeCurrent(platform_hdc, nullptr);
      wglDeleteContext(platform_hglrc);
    }
    platform_hglrc = nullptr;
  }

  static void opengl_platform_present() {
    SwapBuffers(platform_hdc);
  }
#endif

static void opengl_init() {
  opengl_platform_init();
}

static void opengl_deinit() {
  opengl_platform_deinit();
}

static void opengl_resize() {

}

static void opengl_present(Game_Renderer* game_renderer) {
  (void) game_renderer;

  glClearColor(game_renderer->clear_color0[0],
    game_renderer->clear_color0[1],
    game_renderer->clear_color0[2],
    game_renderer->clear_color0[3]);
  glClear(GL_COLOR_BUFFER_BIT);

  opengl_platform_present();
}

static Platform_Renderer opengl_renderer = {
  opengl_init,
  opengl_deinit,
  opengl_resize,
  opengl_present,
};
