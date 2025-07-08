import basic;
import basic.windows;
import renderer : Platform_Renderer;
import main_windows : platform_hwnd, platform_size;

struct D3D11_Data {
  bool initted;
  IDXGISwapChain* swapchain;
  ID3D11Device* device;
  ID3D11DeviceContext* ctx;
}

__gshared D3D11_Data d3d11;

void d3d11_init(Platform_Renderer.Init_Data* init_data) {
  HRESULT hr;

  DXGI_SWAP_CHAIN_DESC swapchain_descriptor;
  swapchain_descriptor.BufferDesc.Width = init_data.size[0];
  swapchain_descriptor.BufferDesc.Height = init_data.size[1];
  swapchain_descriptor.BufferDesc.Format = DXGI_FORMAT.R8G8B8A8_UNORM_SRGB;
  swapchain_descriptor.SampleDesc.Count = 1;
  swapchain_descriptor.BufferUsage = DXGI_USAGE.RENDER_TARGET_OUTPUT;
  swapchain_descriptor.BufferCount = 1;
  swapchain_descriptor.OutputWindow = init_data.hwnd;
  swapchain_descriptor.Windowed = true;
  swapchain_descriptor.Flags = DXGI_SWAP_CHAIN_FLAG.ALLOW_MODE_SWITCH;
  hr = D3D11CreateDeviceAndSwapChain(null, D3D_DRIVER_TYPE.HARDWARE, null,
    D3D11_CREATE_DEVICE_FLAG.DEBUG, null, 0, D3D11_SDK_VERSION,
    &swapchain_descriptor, &d3d11.swapchain, &d3d11.device, null, &d3d11.ctx);
  if (hr < 0) goto defer;

  d3d11.initted = true;
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
}

void d3d11_present() {
  if (!d3d11.initted) return;
  d3d11.swapchain.Present(0, 0);
}

extern(C) export immutable d3d11_renderer = Platform_Renderer(
  &d3d11_init,
  &d3d11_deinit,
  &d3d11_resize,
  &d3d11_present,
);

pragma(lib, "d3d11");
