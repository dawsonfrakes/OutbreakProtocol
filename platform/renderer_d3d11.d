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

void d3d11_init() {
  HRESULT hr;
  {
    DXGI_SWAP_CHAIN_DESC swapchain_desc;
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

void d3d11_resize() {
  if (!d3d11.initted) return;
  HRESULT hr;
  {

  }
  if (hr != 0) d3d11_deinit();
}

void d3d11_present() {
  if (!d3d11.initted) return;
  HRESULT hr;
  {

  }
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
