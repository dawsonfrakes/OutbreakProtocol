import basic;
import basic.windows;
import renderer : Platform_Renderer;

struct D3D11_Data {
  bool initted;
  IDXGISwapChain* swapchain;
  ID3D11Device* device;
  ID3D11DeviceContext* ctx;

  ID3D11RenderTargetView* swapchain_backbuffer_view;
}

__gshared D3D11_Data d3d11;

void d3d11_init(Platform_Renderer.Init_Data* init_data) {
  HRESULT hr;
  {
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

    IDXGIDevice* dxgi_device = void;
    if (d3d11.swapchain.GetDevice(&IDXGIDevice.uuidof, cast(void**) &dxgi_device) >= 0) {
      IDXGIAdapter* dxgi_adapter = void;
      if (dxgi_device.GetAdapter(&dxgi_adapter) >= 0) {
        IDXGIFactory* dxgi_factory = void;
        if (dxgi_adapter.GetParent(&IDXGIFactory.uuidof, cast(void**) &dxgi_factory) >= 0) {
          /*hr = */dxgi_factory.MakeWindowAssociation(init_data.hwnd, DXGI_MWA.NO_ALT_ENTER);
          dxgi_factory.Release();
        }
        dxgi_adapter.Release();
      }
      dxgi_device.Release();
    }

    d3d11.initted = true;
  }
defer:
  if (hr != 0) d3d11_deinit();
}

void d3d11_deinit_swapchain() {
  if (d3d11.swapchain_backbuffer_view) d3d11.swapchain_backbuffer_view.Release();
}

void d3d11_deinit() {
  d3d11_deinit_swapchain();
  if (d3d11.ctx) d3d11.ctx.Release();
  if (d3d11.device) d3d11.device.Release();
  if (d3d11.swapchain) d3d11.swapchain.Release();
  d3d11 = d3d11.init;
}

void d3d11_resize(ushort[2] size) {
  HRESULT hr;
  ID3D11Texture2D* swapchain_backbuffer = void;

  if (!d3d11.initted) return;

  d3d11_deinit_swapchain();

  hr = d3d11.swapchain.ResizeBuffers(1, size[0], size[1], DXGI_FORMAT.UNKNOWN, DXGI_SWAP_CHAIN_FLAG.ALLOW_MODE_SWITCH);
  if (hr < 0) goto defer;

  hr = d3d11.swapchain.GetBuffer(0, &swapchain_backbuffer.uuidof, cast(void**) &swapchain_backbuffer);
  if (hr < 0) goto defer;

  hr = d3d11.device.CreateRenderTargetView(cast(ID3D11Resource*) swapchain_backbuffer, null, &d3d11.swapchain_backbuffer_view);
  if (hr < 0) goto defer;

defer:
  if (swapchain_backbuffer) swapchain_backbuffer.Release();
  if (hr != 0) d3d11_deinit();
}

void d3d11_present() {
  if (!d3d11.initted) return;

  __gshared f32[4] clear_color0 = [0.6, 0.2, 0.2, 1.0];
  d3d11.ctx.ClearRenderTargetView(d3d11.swapchain_backbuffer_view, clear_color0.ptr);

  d3d11.swapchain.Present(0, 0);
}

extern(C) export immutable d3d11_renderer = Platform_Renderer(
  &d3d11_init,
  &d3d11_deinit,
  &d3d11_resize,
  &d3d11_present,
);

pragma(lib, "d3d11");
