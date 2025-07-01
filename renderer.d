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
    void opengl_platform_init() {

    }

    void opengl_platform_deinit() {

    }

    void opengl_platform_resize() {

    }

    void opengl_platform_present() {

    }
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

  version (Windows) pragma(lib, "opengl32");
}
