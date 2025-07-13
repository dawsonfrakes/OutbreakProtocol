#import "Basic2";
#import "Windows2";

d3d11: struct {
  initted: bool;
  swapchain: *IDXGISwapChain;
  device: *ID3D11Device;
  ctx: *ID3D11DeviceContext;
  using swapchain_objects: struct {
    swapchain_backbuffer: *ID3D11Texture2D;
    swapchain_backbuffer_view: *ID3D11RenderTargetView;
    depthbuffer: *ID3D11Texture2D;
    depthbuffer_view: *ID3D11DepthStencilView;
  };
}

d3d11_init :: () #no_context {
  inner :: () -> HRESULT #no_context {
    hr: HRESULT = ---;

    swapchain_desc: DXGI_SWAP_CHAIN_DESC;
    swapchain_desc.BufferDesc.Format = .R8G8B8A8_UNORM_SRGB;
    swapchain_desc.SampleDesc.Count = 1;
    swapchain_desc.BufferUsage = .RENDER_TARGET_OUTPUT;
    swapchain_desc.BufferCount = 1;
    swapchain_desc.OutputWindow = platform_hwnd;
    swapchain_desc.Windowed = xx true;
    swapchain_desc.Flags = .ALLOW_MODE_SWITCH;
    hr = D3D11CreateDeviceAndSwapChain(null, .HARDWARE, null, ifx DEBUG then .DEBUG,
      null, 0, D3D11_SDK_VERSION, *swapchain_desc,
      *d3d11.swapchain, *d3d11.device, null, *d3d11.ctx);
    if hr < 0 return hr;

    d3d11.initted = true;
    return 0;
  }
  if inner() < 0 d3d11_deinit();
}

d3d11_swapchain_deinit :: () #no_context {
  if d3d11.depthbuffer_view d3d11.depthbuffer_view.Release(d3d11.depthbuffer_view);
  if d3d11.depthbuffer d3d11.depthbuffer.Release(d3d11.depthbuffer);
  if d3d11.swapchain_backbuffer_view d3d11.swapchain_backbuffer_view.Release(d3d11.swapchain_backbuffer_view);
  if d3d11.swapchain_backbuffer d3d11.swapchain_backbuffer.Release(d3d11.swapchain_backbuffer);
  d3d11.swapchain_objects = .{};
}

d3d11_deinit :: () #no_context {
  d3d11_swapchain_deinit();
  if d3d11.ctx d3d11.ctx.Release(d3d11.ctx);
  if d3d11.device d3d11.device.Release(d3d11.device);
  if d3d11.swapchain d3d11.swapchain.Release(d3d11.swapchain);
  d3d11 = .{};
}

d3d11_resize :: () #no_context {
  if !d3d11.initted || platform_width == 0 || platform_height == 0 return;
  inner :: () -> HRESULT #no_context {
    hr: HRESULT = ---;

    d3d11_swapchain_deinit();

    hr = d3d11.swapchain.ResizeBuffers(d3d11.swapchain, 1, platform_width, platform_height, .UNKNOWN, .ALLOW_MODE_SWITCH);
    if hr < 0 return hr;

    hr = d3d11.swapchain.GetBuffer(d3d11.swapchain, 0, *ID3D11Texture2D_UUID, xx *d3d11.swapchain_backbuffer);
    if hr < 0 return hr;

    hr = d3d11.device.CreateRenderTargetView(d3d11.device, d3d11.swapchain_backbuffer, null, *d3d11.swapchain_backbuffer_view);
    if hr < 0 return hr;

    depthbuffer_desc: D3D11_TEXTURE2D_DESC;
    depthbuffer_desc.Width = platform_width;
    depthbuffer_desc.Height = platform_height;
    depthbuffer_desc.MipLevels = 1;
    depthbuffer_desc.ArraySize = 1;
    depthbuffer_desc.Format = .D32_FLOAT;
    depthbuffer_desc.SampleDesc.Count = 1;
    depthbuffer_desc.Usage = .DEFAULT;
    depthbuffer_desc.BindFlags = .DEPTH_STENCIL;
    hr = d3d11.device.CreateTexture2D(d3d11.device, *depthbuffer_desc, null, *d3d11.depthbuffer);
    if hr < 0 return hr;

    hr = d3d11.device.CreateDepthStencilView(d3d11.device, d3d11.depthbuffer, null, *d3d11.depthbuffer_view);
    if hr < 0 return hr;

    return 0;
  }
  if inner() < 0 d3d11_deinit();
}

d3d11_present :: () #no_context {
  if !d3d11.initted || platform_width == 0 || platform_height == 0 return;
  inner :: () -> HRESULT #no_context {
    hr: HRESULT = ---;

    d3d11.ctx.ClearRenderTargetView(d3d11.ctx, d3d11.swapchain_backbuffer_view, f32.[0.6, 0.2, 0.2, 1.0].data);

    hr = d3d11.swapchain.Present(d3d11.swapchain, 1, 0);
    if hr < 0 return hr;

    return 0;
  }
  if inner() < 0 d3d11_deinit();
}

renderer_d3d11 :: struct {
  pretty_name :: "Direct3D 11";
  init :: d3d11_init;
  deinit :: d3d11_deinit;
  resize :: d3d11_resize;
  present :: d3d11_present;
}
