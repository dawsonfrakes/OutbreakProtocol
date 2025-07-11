d3d11: struct {
  initted: bool;
  swapchain: *IDXGISwapChain;
  device: *ID3D11Device;
  ctx: *ID3D11DeviceContext;

  swapchain_backbuffer_view: *ID3D11RenderTargetView;
}

d3d11_init :: (init_data: PlatformRenderer.Init) #no_context {
  inner :: (init_data: PlatformRenderer.Init) -> HRESULT #no_context {
    hr: HRESULT = ---;

    swapchain_desc: DXGI_SWAP_CHAIN_DESC;
    swapchain_desc.BufferDesc.Width = init_data.width;
    swapchain_desc.BufferDesc.Height = init_data.height;
    swapchain_desc.BufferDesc.Format = .R8G8B8A8_UNORM_SRGB;
    swapchain_desc.SampleDesc.Count = 1;
    swapchain_desc.BufferUsage = DXGI_USAGE.RENDER_TARGET_OUTPUT;
    swapchain_desc.BufferCount = 1;
    swapchain_desc.OutputWindow = init_data.hwnd;
    swapchain_desc.Windowed = xx true;
    swapchain_desc.Flags = .ALLOW_MODE_SWITCH;
    hr = D3D11CreateDeviceAndSwapChain(null, .HARDWARE, null, .DEBUG,
      null, 0, D3D11_SDK_VERSION, *swapchain_desc,
      *d3d11.swapchain, *d3d11.device, null, *d3d11.ctx);
    if hr < 0 return hr;

    d3d11.initted = true;
    return 0;
  }
  if inner(init_data) < 0 d3d11_deinit();
}

d3d11_deinit_swapchain :: () #no_context {
  if d3d11.swapchain_backbuffer_view d3d11.swapchain_backbuffer_view.Release(d3d11.swapchain_backbuffer_view);
}

d3d11_deinit :: () #no_context {
  d3d11_deinit_swapchain();
  if d3d11.ctx d3d11.ctx.Release(d3d11.ctx);
  if d3d11.device d3d11.device.Release(d3d11.device);
  if d3d11.swapchain d3d11.swapchain.Release(d3d11.swapchain);
  d3d11 = .{};
}

d3d11_resize :: (resize_data: PlatformRenderer.Resize) #no_context {
  if !d3d11.initted || resize_data.width == 0 || resize_data.height == 0 return;
  inner :: (resize_data: PlatformRenderer.Resize) -> HRESULT #no_context {
    hr: HRESULT = ---;

    d3d11_deinit_swapchain();

    hr = d3d11.swapchain.ResizeBuffers(d3d11.swapchain, 1, resize_data.width, resize_data.height, .UNKNOWN, .ALLOW_MODE_SWITCH);
    if hr < 0 return hr;

    swapchain_backbuffer: *ID3D11Texture2D = ---;
    hr = d3d11.swapchain.GetBuffer(d3d11.swapchain, 0, *ID3D11Texture2D_UUID, xx *swapchain_backbuffer);
    if hr < 0 return hr;
    defer swapchain_backbuffer.Release(swapchain_backbuffer);

    hr = d3d11.device.CreateRenderTargetView(d3d11.device, swapchain_backbuffer, null, *d3d11.swapchain_backbuffer_view);
    if hr < 0 return hr;

    return 0;
  }
  if inner(resize_data) < 0 d3d11_deinit();
}

d3d11_present :: (present_data: PlatformRenderer.Present) #no_context {
  if !d3d11.initted || present_data.width == 0 || present_data.height == 0 return;
  inner :: (present_data: PlatformRenderer.Present) -> HRESULT #no_context {
    hr: HRESULT = ---;

    d3d11.ctx.ClearRenderTargetView(d3d11.ctx, d3d11.swapchain_backbuffer_view, present_data.renderer.clear_color0.data);

    hr = d3d11.swapchain.Present(d3d11.swapchain, 1, 0);
    if hr < 0 return hr;

    return hr;
  }
  if inner(present_data) < 0 d3d11_deinit();
}

d3d11_renderer := PlatformRenderer.{
  "Direct3D 11",
  d3d11_init,
  d3d11_deinit,
  d3d11_resize,
  d3d11_present,
};
