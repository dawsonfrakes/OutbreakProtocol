version (Windows) {
  version = D3D11;
  version = OpenGL;
}

struct Platform_Renderer {
  void function() init_;
  void function() deinit;
  void function() resize;
  void function() present;
}

version (D3D11) {
  import basic.windows;

  struct D3D11_Data {
    bool initted;
    IDXGISwapChain* swapchain;
    ID3D11Device* device;
    ID3D11DeviceContext* ctx;
  }

  __gshared D3D11_Data d3d11;

  void d3d11_init() {
    {
      HRESULT hr = void;

      // hr = D3D11CreateDeviceAndSwapChain();
      // if (hr < 0) goto error;

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
    if (!d3d11.initted) return;
  }

  void d3d11_present() {
    if (!d3d11.initted) return;
  }

  __gshared immutable d3d11_renderer = Platform_Renderer(
    &d3d11_init,
    &d3d11_deinit,
    &d3d11_resize,
    &d3d11_present,
  );
}
