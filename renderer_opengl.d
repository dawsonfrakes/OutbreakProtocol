import basic;
static import game;
import renderer : Platform_Renderer;

version (Windows) {
  import basic.windows;

  enum WGL_CONTEXT_MAJOR_VERSION_ARB = 0x2091;
  enum WGL_CONTEXT_MINOR_VERSION_ARB = 0x2092;
  enum WGL_CONTEXT_FLAGS_ARB = 0x2094;
  enum WGL_CONTEXT_PROFILE_MASK_ARB = 0x9126;
  enum WGL_CONTEXT_DEBUG_BIT_ARB = 0x0001;
  enum WGL_CONTEXT_CORE_PROFILE_BIT_ARB = 0x00000001;

  struct OpenGL_Platform_Data {
    HGLRC ctx;
    HDC hdc;
  }

  __gshared OpenGL_Platform_Data opengl_platform;

  static import basic.opengl;
  static foreach (member; __traits(allMembers, basic.opengl)) {
    static if (is(typeof(__traits(getMember, basic.opengl, member)) == function) &&
      (__traits(getAttributes, __traits(getMember, basic.opengl, member))[0].major != 1 ||
      __traits(getAttributes, __traits(getMember, basic.opengl, member))[0].minor > 1))
    {
      mixin("__gshared typeof(basic.opengl."~member~")* "~member~";");
    } else static if (!__traits(isModule, __traits(getMember, basic.opengl, member))) {
      mixin("alias "~member~" = basic.opengl."~member~";");
    }
  }

  bool opengl_platform_init(Platform_Renderer.Init_Data* init_data) {
    opengl_platform.hdc = init_data.hdc;

    PIXELFORMATDESCRIPTOR pfd;
    pfd.nSize = PIXELFORMATDESCRIPTOR.sizeof;
    pfd.nVersion = 1;
    pfd.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER | PFD_DEPTH_DONTCARE;
    pfd.cColorBits = 24;
    s32 format = ChoosePixelFormat(init_data.hdc, &pfd);
    SetPixelFormat(init_data.hdc, format, &pfd);

    HGLRC temp_ctx = wglCreateContext(init_data.hdc);
    wglMakeCurrent(init_data.hdc, temp_ctx);

    alias PFN_wglCreateContextAttribsARB = extern(Windows) HGLRC function(HDC, HGLRC, const(s32)*);
    auto wglCreateContextAttribsARB =
      cast(PFN_wglCreateContextAttribsARB)
      wglGetProcAddress("wglCreateContextAttribsARB");

    debug enum flags = WGL_CONTEXT_DEBUG_BIT_ARB;
    else  enum flags = 0;
    __gshared immutable s32[9] attribs = [
      WGL_CONTEXT_MAJOR_VERSION_ARB, 4,
      WGL_CONTEXT_MINOR_VERSION_ARB, 5,
      WGL_CONTEXT_FLAGS_ARB, flags,
      WGL_CONTEXT_PROFILE_MASK_ARB, WGL_CONTEXT_CORE_PROFILE_BIT_ARB,
      0,
    ];
    opengl_platform.ctx = wglCreateContextAttribsARB(init_data.hdc, null, attribs.ptr);
    wglMakeCurrent(init_data.hdc, opengl_platform.ctx);

    wglDeleteContext(temp_ctx);

    static foreach (member; __traits(allMembers, basic.opengl)) {
      static if (is(typeof(__traits(getMember, basic.opengl, member)) == function) &&
        (__traits(getAttributes, __traits(getMember, basic.opengl, member))[0].major != 1 ||
        __traits(getAttributes, __traits(getMember, basic.opengl, member))[0].minor > 1))
      {
        mixin(member~" = cast(typeof("~member~")) wglGetProcAddress(\""~member~"\");");
      }
    }

    return true;
  }

  void opengl_platform_deinit() {
    wglDeleteContext(opengl_platform.ctx);
    opengl_platform = opengl_platform.init;
  }

  void opengl_platform_present() {
    if (!opengl_platform.hdc) return;
    SwapBuffers(opengl_platform.hdc);
  }

  pragma(lib, "gdi32");
  pragma(lib, "opengl32");
}

struct OpenGL_Data {
  bool initted;
  u16[2] size;

  u32 main_fbo;
  u32 main_fbo_color0;
  u32 main_fbo_depth;
}

__gshared OpenGL_Data opengl;

void opengl_init(Platform_Renderer.Init_Data* init_data) {
  opengl.initted = opengl_platform_init(init_data);

  glClipControl(GL_LOWER_LEFT, GL_ZERO_TO_ONE);

  glCreateFramebuffers(1, &opengl.main_fbo);
  glCreateRenderbuffers(1, &opengl.main_fbo_color0);
  glCreateRenderbuffers(1, &opengl.main_fbo_depth);
}

void opengl_deinit() {
  opengl = opengl.init;
  opengl_platform_deinit();
}

void opengl_resize(u16[2] size) {
  opengl.size = size;
  if (!opengl.initted || opengl.size[0] == 0 || opengl.size[1] == 0) return;

  s32 fbo_color_samples_max = void;
  glGetIntegerv(GL_MAX_COLOR_TEXTURE_SAMPLES, &fbo_color_samples_max);
  s32 fbo_depth_samples_max = void;
  glGetIntegerv(GL_MAX_DEPTH_TEXTURE_SAMPLES, &fbo_depth_samples_max);
  u32 fbo_samples = cast(u32) max(0, min(fbo_color_samples_max, fbo_depth_samples_max));

  glNamedRenderbufferStorageMultisample(opengl.main_fbo_color0, fbo_samples, GL_RGBA16F, size[0], size[1]);
  glNamedFramebufferRenderbuffer(opengl.main_fbo, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, opengl.main_fbo_color0);

  glNamedRenderbufferStorageMultisample(opengl.main_fbo_depth, fbo_samples, GL_DEPTH_COMPONENT32F, size[0], size[1]);
  glNamedFramebufferRenderbuffer(opengl.main_fbo, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, opengl.main_fbo_depth);
}

void opengl_present(game.Game_Renderer* game_renderer) {
  if (!opengl.initted || opengl.size[0] == 0 || opengl.size[1] == 0) return;

  glClearNamedFramebufferfv(opengl.main_fbo, GL_COLOR, 0, game_renderer.clear_color0.ptr);

  glBindFramebuffer(GL_FRAMEBUFFER, opengl.main_fbo);

  glClear(0); // NOTE(dfra): this fixes intel default framebuffer resize bug.

  glEnable(GL_FRAMEBUFFER_SRGB);
  glBlitNamedFramebuffer(opengl.main_fbo, 0,
    0, 0, opengl.size[0], opengl.size[1],
    0, 0, opengl.size[0], opengl.size[1],
    GL_COLOR_BUFFER_BIT, GL_NEAREST);
  glDisable(GL_FRAMEBUFFER_SRGB);

  opengl_platform_present();
}

immutable opengl_renderer = Platform_Renderer(
  &opengl_init,
  &opengl_deinit,
  &opengl_resize,
  &opengl_present,
);

version (DLL) mixin DLLExport!opengl_renderer;
