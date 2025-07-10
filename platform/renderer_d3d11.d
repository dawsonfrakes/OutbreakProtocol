import basic;
import basic.windows;
import platform.renderer;

void d3d11_init() {

}

void d3d11_deinit() {

}

void d3d11_resize() {

}

void d3d11_present() {

}

mixin DefineOrExportIfDLL!`
  __gshared immutable d3d11_renderer = PlatformRenderer(
    "Direct3D 11",
    &d3d11_init,
    &d3d11_deinit,
    &d3d11_resize,
    &d3d11_present,
  );
`;

pragma(lib, "D3D11");
pragma(lib, "DXGI");
pragma(lib, "D3DCompiler");
