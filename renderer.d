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
  version (Windows) {
    import main : platform_hdc;
    import basic.windows;

    struct OpenGLData {
      HGLRC ctx;
    }

    __gshared OpenGLData opengl;

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
      opengl.ctx = wglCreateContextAttribsARB(platform_hdc, null, attribs.ptr);
      wglMakeCurrent(platform_hdc, opengl.ctx);
    }

    void opengl_platform_deinit() {
      if (opengl.ctx) wglDeleteContext(opengl.ctx);
      opengl = opengl.init;
    }

    void opengl_platform_resize() {

    }

    void opengl_platform_present() {
      SwapBuffers(platform_hdc);
    }

    pragma(lib, "gdi32");
    pragma(lib, "opengl32");
  }

  void opengl_init() {
    static if (__traits(compiles, opengl_platform_init))
      opengl_platform_init();
  }

  void opengl_deinit() {
    static if (__traits(compiles, opengl_platform_deinit))
      opengl_platform_deinit();
  }

  void opengl_resize() {
    static if (__traits(compiles, opengl_platform_resize))
      opengl_platform_resize();
  }

  void opengl_present() {
    static if (__traits(compiles, opengl_platform_present))
      opengl_platform_present();
  }

  __gshared immutable opengl_renderer = Platform_Renderer(
    &opengl_init,
    &opengl_deinit,
    &opengl_resize,
    &opengl_present,
  );
}
