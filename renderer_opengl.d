import basic;
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

  void opengl_platform_init(Platform_Renderer.Init_Data* init_data) {
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

void opengl_init(Platform_Renderer.Init_Data* init_data) {
  opengl_platform_init(init_data);

  glClipControl(GL_LOWER_LEFT, GL_ZERO_TO_ONE);
}

void opengl_deinit() {
  opengl_platform_deinit();
}

void opengl_resize(ushort[2] size) {

}

void opengl_present() {
  glClearColor(0.6, 0.2, 0.2, 1.0);
  glClear(GL_COLOR_BUFFER_BIT);
  opengl_platform_present();
}

extern(C) export immutable opengl_renderer = Platform_Renderer(
  &opengl_init,
  &opengl_deinit,
  &opengl_resize,
  &opengl_present,
);
