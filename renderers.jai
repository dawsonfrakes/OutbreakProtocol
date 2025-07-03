Platform_Renderers :: enum_flags {
  NULL :: 0;
  D3D11 :: 1 << 0;
  OPENGL :: 1 << 1;
}

Platform_Renderer :: struct {
  init: () #no_context;
  deinit: () #no_context;
  resize: () #no_context;
  present: () #no_context;
}

null_renderer_proc :: () #no_context {}
null_renderer :: Platform_Renderer.{
  null_renderer_proc,
  null_renderer_proc,
  null_renderer_proc,
  null_renderer_proc,
};

#if RENDERERS & .D3D11 {
  d3d11: struct {
    initted: bool;
    swapchain: *IDXGISwapChain;
    device: *ID3D11Device;
    ctx: *ID3D11DeviceContext;
  }

  d3d11_init :: () #no_context {
    while label := true {
      hr: HRESULT = ---;

      swapchain_descriptor: DXGI_SWAP_CHAIN_DESC;
      hr = D3D11CreateDeviceAndSwapChain(null, .HARDWARE, null, .DEBUG,
        null, 0, D3D11_SDK_VERSION, *swapchain_descriptor,
        *d3d11.swapchain, *d3d11.device, null, *d3d11.ctx);
      if hr < 0 break label;

      d3d11.initted = true;
      return;
    }
    d3d11_deinit();
  }

  d3d11_deinit :: () #no_context {
    if d3d11.ctx d3d11.ctx.Release(d3d11.ctx);
    if d3d11.device d3d11.device.Release(d3d11.device);
    if d3d11.swapchain d3d11.swapchain.Release(d3d11.swapchain);
    d3d11 = .{};
  }

  d3d11_resize :: () #no_context {

  }

  d3d11_present :: () #no_context {

  }

  d3d11_renderer :: Platform_Renderer.{
    d3d11_init,
    d3d11_deinit,
    d3d11_resize,
    d3d11_present,
  };
}
