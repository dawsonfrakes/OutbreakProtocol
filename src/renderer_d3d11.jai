#import "Basic2";
#import "Windows2";

d3d11_renderer := Platform_Renderer.{
  "Direct3D 11",
  d3d11_init,
  d3d11_deinit,
  d3d11_resize,
  d3d11_present,
};

#scope_file

d3d: struct {
  initted: bool;
  swapchain: *IDXGISwapChain;
  // device: *ID3D11Device;
  // ctx: *ID3D11DeviceContext;
}

d3d11_init :: () #no_context {
  inner :: () -> HRESULT #no_context {
    hr: HRESULT = ---;
    // hr = D3D11CreateDeviceAndSwapChain();
    if hr < 0 return hr;

    d3d.initted = true;
    return hr;
  }
  if inner() < 0 d3d11_deinit();
}

d3d11_deinit :: () #no_context {
  if d3d.swapchain d3d.swapchain.Release(d3d.swapchain);
  d3d = .{};
}

d3d11_resize :: () #no_context {

}

d3d11_present :: () #no_context {

}
