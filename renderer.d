version (Windows) {
  version = D3D11;
  version = OpenGL;
}

struct Platform_Renderer {
  void function() init;
  void function() deinit;
  void function() resize;
  void function() present;
}

version (D3D11) {
  import main : platform_hwnd, platform_size;
  import basic.windows;

  struct D3D11Data {
    bool initted;
    IDXGISwapChain* swapchain;
    ID3D11Device* device;
    ID3D11DeviceContext* ctx;
  }

  __gshared D3D11Data d3d11;

  void d3d11_init() {
    HRESULT hr = void;
    {
      DXGI_SWAP_CHAIN_DESC swapchain_descriptor;
      swapchain_descriptor.BufferDesc.Width = platform_size[0];
      swapchain_descriptor.BufferDesc.Height = platform_size[1];
      swapchain_descriptor.BufferDesc.RefreshRate.Numerator = 144;
      swapchain_descriptor.BufferDesc.RefreshRate.Denominator = 1;
      swapchain_descriptor.BufferDesc.Format = DXGI_FORMAT.R8G8B8A8_UNORM;
      swapchain_descriptor.SampleDesc.Count = 8;
      swapchain_descriptor.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT;
      swapchain_descriptor.BufferCount = 1;
      swapchain_descriptor.OutputWindow = platform_hwnd;
      swapchain_descriptor.Windowed = true;
      swapchain_descriptor.Flags = DXGI_SWAP_CHAIN_FLAG.ALLOW_MODE_SWITCH;
      hr = D3D11CreateDeviceAndSwapChain(null, D3D_DRIVER_TYPE.HARDWARE, null,
        D3D11_CREATE_DEVICE_FLAG.DEBUG, null, 0, D3D11_SDK_VERSION,
        &swapchain_descriptor, &d3d11.swapchain, &d3d11.device, null, &d3d11.ctx);
      if (hr < 0) goto error;

      IDXGIDevice* dxgi_device = void;
      if (d3d11.swapchain.GetDevice(&dxgi_device.uuidof, cast(void**) &dxgi_device) >= 0) {
        IDXGIAdapter* dxgi_adapter = void;
        if (dxgi_device.GetAdapter(&dxgi_adapter) >= 0) {
          IDXGIFactory* dxgi_factory = void;
          if (dxgi_adapter.GetParent(&dxgi_factory.uuidof, cast(void**) &dxgi_factory) >= 0) {
            dxgi_factory.MakeWindowAssociation(platform_hwnd, DXGI_MWA.NO_ALT_ENTER);
            dxgi_factory.Release();
          }
          dxgi_adapter.Release();
        }
        dxgi_device.Release();
      }

      d3d11.initted = true;
      return;
    }
  error:
    d3d11_deinit();
  }

  void d3d11_deinit() {
    if (d3d11.ctx) d3d11.ctx.Release();
    if (d3d11.device) d3d11.device.Release();
    if (d3d11.swapchain) d3d11.swapchain.Release();
    d3d11 = d3d11.init;
  }

  void d3d11_resize() {

  }

  void d3d11_present() {
    if (!d3d11.initted) return;
    d3d11.swapchain.Present(0, 0);
  }

  __gshared immutable d3d11_renderer = Platform_Renderer(
    &d3d11_init,
    &d3d11_deinit,
    &d3d11_resize,
    &d3d11_present,
  );

  pragma(lib, "d3d11");
  pragma(lib, "dxgi");
}

version (OpenGL) {
  import main : platform_log;
  import basic : max, min, strlen;

  version (Windows) {
    import main : platform_hdc;
    import basic.windows;

    static import basic.opengl;
    static foreach (name; __traits(allMembers, basic.opengl)[1..$]) {
      static if (is(typeof(__traits(getMember, basic.opengl, name)) == function)) {
        static foreach (attribute; __traits(getAttributes, __traits(getMember, basic.opengl, name))) {
          static if (is(typeof(attribute) == basic.opengl.gl_version)) {
            mixin("__gshared typeof(basic.opengl."~name~")* "~name~";");
          }
        }
      } else {
        mixin("alias "~name~" = basic.opengl."~name~";");
      }
    }

    struct OpenGLPlatformData {
      HGLRC ctx;
    }

    __gshared OpenGLPlatformData platform_opengl;

    void opengl_platform_init() {
      PIXELFORMATDESCRIPTOR pfd;
      pfd.nSize = PIXELFORMATDESCRIPTOR.sizeof;
      pfd.nVersion = 1;
      pfd.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER | PFD_DEPTH_DONTCARE;
      pfd.cColorBits = 24;
      const format = ChoosePixelFormat(platform_hdc, &pfd);
      SetPixelFormat(platform_hdc, format, &pfd);

      HGLRC temp_ctx = wglCreateContext(platform_hdc);
      scope(exit) wglDeleteContext(temp_ctx);
      wglMakeCurrent(platform_hdc, temp_ctx);

      alias PFN_wglCreateContextAttribsARB = extern(Windows) HGLRC function(HDC, HGLRC, const(int)*);
      auto wglCreateContextAttribsARB =
        cast(PFN_wglCreateContextAttribsARB)
        wglGetProcAddress("wglCreateContextAttribsARB");

      debug enum flags = WGL_CONTEXT_DEBUG_BIT_ARB;
      else  enum flags = 0;
      immutable int[9] attribs = [
        WGL_CONTEXT_MAJOR_VERSION_ARB, 4,
        WGL_CONTEXT_MINOR_VERSION_ARB, 5,
        WGL_CONTEXT_FLAGS_ARB, flags,
        WGL_CONTEXT_PROFILE_MASK_ARB, WGL_CONTEXT_CORE_PROFILE_BIT_ARB,
        0,
      ];
      platform_opengl.ctx = wglCreateContextAttribsARB(platform_hdc, null, attribs.ptr);
      wglMakeCurrent(platform_hdc, platform_opengl.ctx);

      HMODULE opengl32 = GetModuleHandleW("opengl32");
      static foreach (name; __traits(allMembers, basic.opengl)[1..$]) {
        static if (is(typeof(__traits(getMember, basic.opengl, name)))) {
          static foreach (attribute; __traits(getAttributes, __traits(getMember, basic.opengl, name))) {
            static if (is(typeof(attribute) == basic.opengl.gl_version)) {
              static if (attribute.major == 1 && attribute.minor <= 1) {
                mixin(name~" = cast(typeof("~name~")) GetProcAddress(opengl32, \""~name~"\");");
              } else {
                mixin(name~" = cast(typeof("~name~")) wglGetProcAddress(\""~name~"\");");
              }
            }
          }
        }
      }
    }

    void opengl_platform_deinit() {
      if (platform_opengl.ctx) wglDeleteContext(platform_opengl.ctx);
      platform_opengl = platform_opengl.init;
    }

    void opengl_platform_resize() {

    }

    void opengl_platform_present() {
      SwapBuffers(platform_hdc);
    }

    pragma(lib, "gdi32");
    pragma(lib, "opengl32");
  }

  struct OpenGLData {
    uint main_fbo;
    uint main_fbo_color0;
    uint main_fbo_depth;

    uint triangle_shader;
    uint triangle_vao;
    uint triangle_vbo;
    uint triangle_ebo;
  }

  __gshared OpenGLData opengl;

  struct OpenGLTriangleVertex {
    float[3] position;
    float[4] color;
  }

  extern(System) void opengl_debug_proc(uint source, uint type, uint id, uint severity, uint length, const(char)* message, const(void)* param) {
    platform_log(message[0..length]);
  }

  void opengl_init() {
    static if (__traits(compiles, opengl_platform_init))
      opengl_platform_init();

    debug {
      glEnable(GL_DEBUG_OUTPUT);
      glDebugMessageCallback(&opengl_debug_proc, null);

      platform_log("OpenGL Renderer Info:");
      auto gl_vendor = glGetString(GL_VENDOR);
      platform_log(gl_vendor[0..strlen(gl_vendor)]);
      auto gl_renderer = glGetString(GL_RENDERER);
      platform_log(gl_renderer[0..strlen(gl_renderer)]);
      auto gl_version = glGetString(GL_VERSION);
      platform_log(gl_version[0..strlen(gl_version)]);
    }

    glClipControl(GL_LOWER_LEFT, GL_ZERO_TO_ONE);

    glCreateFramebuffers(1, &opengl.main_fbo);
    glCreateRenderbuffers(1, &opengl.main_fbo_color0);
    glCreateRenderbuffers(1, &opengl.main_fbo_depth);

    __gshared immutable const(char)*[1] vsrcs = [
      `#version 450

      layout(location = 0) in vec3 a_position;
      layout(location = 1) in vec4 a_color;

      layout(location = 1) out vec4 f_color;

      void main() {
        gl_Position = vec4(a_position, 1.0);
        f_color = a_color;
      }`,
    ];
    uint vshader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vshader, vsrcs.length, vsrcs.ptr, null);
    glCompileShader(vshader);

    __gshared immutable const(char)*[1] fsrcs = [
      `#version 450

      layout(location = 1) in vec4 f_color;

      layout(location = 0) out vec4 color;

      void main() {
        color = f_color;
      }`,
    ];
    uint fshader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fshader, fsrcs.length, fsrcs.ptr, null);
    glCompileShader(fshader);

    opengl.triangle_shader = glCreateProgram();
    glAttachShader(opengl.triangle_shader, vshader);
    glAttachShader(opengl.triangle_shader, fshader);
    glLinkProgram(opengl.triangle_shader);
    glDetachShader(opengl.triangle_shader, fshader);
    glDetachShader(opengl.triangle_shader, vshader);

    glDeleteShader(fshader);
    glDeleteShader(vshader);

    __gshared immutable OpenGLTriangleVertex[4] vertices = [
      OpenGLTriangleVertex([-0.5, -0.5, 0.0], [1.0, 0.0, 0.0, 1.0]),
      OpenGLTriangleVertex([+0.5, -0.5, 0.0], [0.0, 1.0, 0.0, 1.0]),
      OpenGLTriangleVertex([+0.5, +0.5, 0.0], [0.0, 0.0, 1.0, 1.0]),
      OpenGLTriangleVertex([-0.5, +0.5, 0.0], [1.0, 0.0, 1.0, 1.0]),
    ];
    __gshared immutable ubyte[6] elements = [0, 1, 2, 2, 3, 0];

    glCreateBuffers(1, &opengl.triangle_vbo);
    glNamedBufferData(opengl.triangle_vbo, vertices.length * OpenGLTriangleVertex.sizeof, vertices.ptr, GL_STATIC_DRAW);

    glCreateBuffers(1, &opengl.triangle_ebo);
    glNamedBufferData(opengl.triangle_ebo, elements.length * ubyte.sizeof, elements.ptr, GL_STATIC_DRAW);

    uint vbo_binding = 0;
    glCreateVertexArrays(1, &opengl.triangle_vao);
    glVertexArrayElementBuffer(opengl.triangle_vao, opengl.triangle_ebo);
    glVertexArrayVertexBuffer(opengl.triangle_vao, vbo_binding, opengl.triangle_vbo, 0, OpenGLTriangleVertex.sizeof);

    uint position_attrib = 0;
    glEnableVertexArrayAttrib(opengl.triangle_vao, position_attrib);
    glVertexArrayAttribBinding(opengl.triangle_vao, position_attrib, vbo_binding);
    glVertexArrayAttribFormat(opengl.triangle_vao, position_attrib, 3, GL_FLOAT, false, OpenGLTriangleVertex.position.offsetof);

    uint color_attrib = 1;
    glEnableVertexArrayAttrib(opengl.triangle_vao, color_attrib);
    glVertexArrayAttribBinding(opengl.triangle_vao, color_attrib, vbo_binding);
    glVertexArrayAttribFormat(opengl.triangle_vao, color_attrib, 4, GL_FLOAT, false, OpenGLTriangleVertex.color.offsetof);
  }

  void opengl_deinit() {
    static if (__traits(compiles, opengl_platform_deinit))
      opengl_platform_deinit();
  }

  void opengl_resize() {
    static if (__traits(compiles, opengl_platform_resize))
      opengl_platform_resize();

    if (platform_size[0] == 0 || platform_size[1] == 0) return;

    int fbo_color_samples = void;
    glGetIntegerv(GL_MAX_COLOR_TEXTURE_SAMPLES, &fbo_color_samples);
    int fbo_depth_samples = void;
    glGetIntegerv(GL_MAX_DEPTH_TEXTURE_SAMPLES, &fbo_depth_samples);
    uint fbo_samples = cast(uint) max(1, min(fbo_color_samples, fbo_depth_samples));

    glNamedRenderbufferStorageMultisample(opengl.main_fbo_color0, fbo_samples, GL_RGBA16F, platform_size[0], platform_size[1]);
    glNamedFramebufferRenderbuffer(opengl.main_fbo, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, opengl.main_fbo_color0);

    glNamedRenderbufferStorageMultisample(opengl.main_fbo_depth, fbo_samples, GL_DEPTH_COMPONENT32F, platform_size[0], platform_size[1]);
    glNamedFramebufferRenderbuffer(opengl.main_fbo, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, opengl.main_fbo_depth);
  }

  void opengl_present() {
    static if (__traits(compiles, opengl_platform_present))
      opengl_platform_present();

    __gshared immutable clear_color0 = [0.6f, 0.2f, 0.2f, 1.0f];
    glClearNamedFramebufferfv(opengl.main_fbo, GL_COLOR, 0, clear_color0.ptr);
    __gshared immutable clear_depth = [0.0f];
    glClearNamedFramebufferfv(opengl.main_fbo, GL_DEPTH, 0, clear_depth.ptr);

    glBindFramebuffer(GL_FRAMEBUFFER, opengl.main_fbo);
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);
    glBindVertexArray(opengl.triangle_vao);
    glUseProgram(opengl.triangle_shader);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_BYTE, cast(const(void)*) 0);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);

    glClear(0); // NOTE(dfra): this fixes intel integrated gpus.

    glEnable(GL_FRAMEBUFFER_SRGB);
    glBlitNamedFramebuffer(opengl.main_fbo, 0,
      0, 0, platform_size[0], platform_size[1],
      0, 0, platform_size[0], platform_size[1],
      GL_COLOR_BUFFER_BIT, GL_NEAREST);
    glDisable(GL_FRAMEBUFFER_SRGB);
  }

  __gshared immutable opengl_renderer = Platform_Renderer(
    &opengl_init,
    &opengl_deinit,
    &opengl_resize,
    &opengl_present,
  );
}
