import basic;
import basic.windows;
import platform.renderer;

struct D3D11Data {
  bool initted;
  IDXGISwapChain* swapchain;
  ID3D11Device* device;
  ID3D11DeviceContext* ctx;
}
__gshared D3D11Data d3d11;

void d3d11_init(PlatformRenderer.Init init_data) {
  HRESULT hr;
  {
    DXGI_SWAP_CHAIN_DESC swapchain_desc;
    swapchain_desc.BufferDesc.Format = DXGI_FORMAT.R8G8B8A8_UNORM_SRGB;
    swapchain_desc.SampleDesc.Count = 1;
    swapchain_desc.BufferUsage = DXGI_USAGE.RENDER_TARGET_OUTPUT;
    swapchain_desc.BufferCount = 1;
    swapchain_desc.OutputWindow = init_data.hwnd;
    swapchain_desc.Windowed = true;
    swapchain_desc.Flags = DXGI_SWAP_CHAIN_FLAG.ALLOW_MODE_SWITCH;
    hr = D3D11CreateDeviceAndSwapChain(null, D3D_DRIVER_TYPE.HARDWARE, null,
      D3D11_CREATE_DEVICE_FLAG.DEBUG, null, 0, D3D11_SDK_VERSION,
      &swapchain_desc, &d3d11.swapchain, &d3d11.device, null, &d3d11.ctx);
    if (hr < 0) goto defer;

    d3d11.initted = true;
  }
defer:
  if (hr != 0) d3d11_deinit();
}

void d3d11_deinit() {
  if (d3d11.ctx) d3d11.ctx.Release();
  if (d3d11.device) d3d11.device.Release();
  if (d3d11.swapchain) d3d11.swapchain.Release();
  d3d11 = d3d11.init;
}

void d3d11_resize(PlatformRenderer.Resize resize_data) {
  if (!d3d11.initted) return;
  HRESULT hr;
  {
    hr = d3d11.swapchain.ResizeBuffers(1, resize_data.width, resize_data.height, DXGI_FORMAT.UNKNOWN, 0);
    if (hr < 0) goto defer;
  }
defer:
  if (hr != 0) d3d11_deinit();
}

void d3d11_present() {
  if (!d3d11.initted) return;
  HRESULT hr;
  {
    hr = d3d11.swapchain.Present(0, 0);
    if (hr < 0) goto defer;
  }
defer:
  if (hr != 0) d3d11_deinit();
}

package template Exports() {
  __gshared immutable d3d11_renderer = PlatformRenderer(
    "Direct3D 11",
    &d3d11_init,
    &d3d11_deinit,
    &d3d11_resize,
    &d3d11_present,
  );
}

mixin ExportIfVersionDLLElseDefine!Exports;

pragma(lib, "D3D11");
