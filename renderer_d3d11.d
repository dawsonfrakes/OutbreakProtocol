import basic;
import basic.windows;
import renderer : Platform_Renderer;

struct D3D11_Data {
  bool initted;
}

__gshared D3D11_Data d3d11;

void d3d11_init() {
  HRESULT hr;

  // hr = D3D11CreateDeviceAndSwapChain();
  // if (hr < 0) goto defer;

  d3d11.initted = true;
defer:
  if (hr != 0) d3d11_deinit();
}

void d3d11_deinit() {
  // if (d3d11.device) d3d11.device.Release();
  d3d11 = d3d11.init;
}

void d3d11_resize() {
  if (!d3d11.initted) return;
}

void d3d11_present() {
  if (!d3d11.initted) return;
}

extern(C) export immutable d3d11_renderer = Platform_Renderer(
  &d3d11_init,
  &d3d11_deinit,
  &d3d11_resize,
  &d3d11_present,
);
