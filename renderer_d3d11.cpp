#include <D3D11.h>
#include <Dxgi.h>
#include <D3Dcompiler.h>

static struct {
  bool initted;

  IDXGISwapChain* swapchain;
  ID3D11Device* device;
  ID3D11DeviceContext* ctx;
  ID3D11DepthStencilState* depthbuffer_state;

  ID3D11RenderTargetView* backbuffer_view;

  ID3D11Texture2D* depthbuffer;
  ID3D11DepthStencilView* depthbuffer_view;
} d3d11;

static void d3d11_deinit();

static void d3d11_init() {
  HRESULT hr;
  {
    DXGI_SWAP_CHAIN_DESC swapchain_descriptor = {};
    swapchain_descriptor.BufferDesc.Width = platform_size[0];
    swapchain_descriptor.BufferDesc.Height = platform_size[1];
    swapchain_descriptor.BufferDesc.Format = DXGI_FORMAT_R8G8B8A8_UNORM_SRGB;
    swapchain_descriptor.SampleDesc.Count = 1;
    swapchain_descriptor.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT;
    swapchain_descriptor.BufferCount = 1;
    swapchain_descriptor.OutputWindow = platform_hwnd;
    swapchain_descriptor.Windowed = true;
    swapchain_descriptor.Flags = DXGI_SWAP_CHAIN_FLAG_ALLOW_MODE_SWITCH;
    hr = D3D11CreateDeviceAndSwapChain(nullptr, D3D_DRIVER_TYPE_HARDWARE, nullptr,
      D3D11_CREATE_DEVICE_DEBUG, nullptr, 0, D3D11_SDK_VERSION,
      &swapchain_descriptor, &d3d11.swapchain, &d3d11.device, nullptr, &d3d11.ctx);
    if (FAILED(hr)) goto error;

    IDXGIDevice* dxgi_device;
    if (SUCCEEDED(d3d11.swapchain->GetDevice(__uuidof(IDXGIDevice), cast(void**, &dxgi_device)))) {
      IDXGIAdapter* dxgi_adapter;
      if (SUCCEEDED(dxgi_device->GetAdapter(&dxgi_adapter))) {
        IDXGIFactory* dxgi_factory;
        if (SUCCEEDED(dxgi_adapter->GetParent(__uuidof(IDXGIFactory), cast(void**, &dxgi_factory)))) {
          dxgi_factory->MakeWindowAssociation(platform_hwnd, DXGI_MWA_NO_ALT_ENTER);
          dxgi_factory->Release();
        }
        dxgi_adapter->Release();
      }
      dxgi_device->Release();
    }

    D3D11_DEPTH_STENCIL_DESC depthbuffer_state_desc = {};
    depthbuffer_state_desc.DepthEnable = true;
    depthbuffer_state_desc.DepthWriteMask = D3D11_DEPTH_WRITE_MASK_ALL;
    depthbuffer_state_desc.DepthFunc = D3D11_COMPARISON_GREATER_EQUAL;
    hr = d3d11.device->CreateDepthStencilState(&depthbuffer_state_desc, &d3d11.depthbuffer_state);
    if (FAILED(hr)) goto error;

    d3d11.initted = true;
    return;
  }
error:
  d3d11_deinit();
}

static void d3d11_deinit() {
  if (d3d11.depthbuffer_view) d3d11.depthbuffer_view->Release();
  if (d3d11.depthbuffer) d3d11.depthbuffer->Release();
  if (d3d11.backbuffer_view) d3d11.backbuffer_view->Release();

  if (d3d11.depthbuffer_state) d3d11.depthbuffer_state->Release();
  if (d3d11.ctx) d3d11.ctx->Release();
  if (d3d11.device) d3d11.device->Release();
  if (d3d11.swapchain) d3d11.swapchain->Release();
  d3d11 = {};
}

static void d3d11_resize() {
  HRESULT hr = 0;
  ID3D11Texture2D* backbuffer = nullptr;
  {
    if (!d3d11.initted || platform_size[0] == 0 || platform_size[1] == 0) return;

    if (d3d11.depthbuffer_view) d3d11.depthbuffer_view->Release();
    if (d3d11.depthbuffer) d3d11.depthbuffer->Release();
    if (d3d11.backbuffer_view) d3d11.backbuffer_view->Release();

    hr = d3d11.swapchain->ResizeBuffers(1, platform_size[0], platform_size[1], DXGI_FORMAT_UNKNOWN, DXGI_SWAP_CHAIN_FLAG_ALLOW_MODE_SWITCH);
    if (FAILED(hr)) goto defer;

    hr = d3d11.swapchain->GetBuffer(0, __uuidof(ID3D11Texture2D), cast(void**, &backbuffer));
    if (FAILED(hr)) goto defer;

    hr = d3d11.device->CreateRenderTargetView(backbuffer, nullptr, &d3d11.backbuffer_view);
    if (FAILED(hr)) goto defer;

    D3D11_TEXTURE2D_DESC depthbuffer_desc = {};
    depthbuffer_desc.Width = platform_size[0];
    depthbuffer_desc.Height = platform_size[1];
    depthbuffer_desc.ArraySize = 1;
    depthbuffer_desc.Format = DXGI_FORMAT_D32_FLOAT;
    depthbuffer_desc.SampleDesc.Count = 1;
    depthbuffer_desc.Usage = D3D11_USAGE_DEFAULT;
    depthbuffer_desc.BindFlags = D3D11_BIND_DEPTH_STENCIL;
    hr = d3d11.device->CreateTexture2D(&depthbuffer_desc, nullptr, &d3d11.depthbuffer);
    if (FAILED(hr)) goto defer;

    hr = d3d11.device->CreateDepthStencilView(d3d11.depthbuffer, nullptr, &d3d11.depthbuffer_view);
    if (FAILED(hr)) goto defer;
  }
defer:
  if (backbuffer) backbuffer->Release();
  if (hr != 0) d3d11_deinit();
}

static void d3d11_present(Game_Renderer* game_renderer) {
  (void) game_renderer;
  if (!d3d11.initted || platform_size[0] == 0 || platform_size[1] == 0) return;

  d3d11.ctx->ClearRenderTargetView(d3d11.backbuffer_view, game_renderer->clear_color0);
  d3d11.ctx->ClearDepthStencilView(d3d11.depthbuffer_view, D3D11_CLEAR_DEPTH, 0.0f, 0);

  d3d11.ctx->OMSetDepthStencilState(d3d11.depthbuffer_state, 0);

  d3d11.swapchain->Present(1, 0);
}

static Platform_Renderer d3d11_renderer = {
  d3d11_init,
  d3d11_deinit,
  d3d11_resize,
  d3d11_present,
};
