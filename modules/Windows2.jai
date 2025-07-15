#import "Basic2";

Kernel32 :: #library,system "Kernel32";

HRESULT :: s32;
HINSTANCE :: *struct {};
HMODULE :: HINSTANCE;
PROC :: #type () -> ssize #c_call;
GUID :: struct {
  Data1: u32;
  Data2: u16;
  Data3: u16;
  Data4: [8]u8;
}
IID :: #type,isa GUID;
IUnknown_VTable :: struct {
  QueryInterface: (*IUnknown, *IID, **void) -> HRESULT #cpp_method;
  AddRef: (*IUnknown) -> u32 #cpp_method;
  Release: (*IUnknown) -> u32 #cpp_method;
}
IUnknown :: struct {
  using _iunknown_vtable: *IUnknown_VTable;
}

GetModuleHandleW :: (name: *u16) -> HMODULE #foreign Kernel32;
LoadLibraryW :: (name: *u16) -> HMODULE #foreign Kernel32;
GetProcAddress :: (module: HMODULE, name: *u8) -> PROC #foreign Kernel32;
FreeLibrary :: (module: HMODULE) -> s32 #foreign Kernel32;
Sleep :: (milliseconds: u32) #foreign Kernel32;
ExitProcess :: (status: u32) -> noreturn #foreign Kernel32;

User32 :: #library,system "User32";

CS_OWNDC :: 0x0020;
IDI_WARNING :: cast(*u16) 32515;
IDC_CROSS :: cast(*u16) 32515;
WS_MAXIMIZEBOX :: 0x00010000;
WS_MINIMIZEBOX :: 0x00020000;
WS_THICKFRAME :: 0x00040000;
WS_SYSMENU :: 0x00080000;
WS_CAPTION :: 0x00C00000;
WS_VISIBLE :: 0x10000000;
WS_OVERLAPPEDWINDOW :: WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX;
CW_USEDEFAULT :: 0x80000000;
PM_REMOVE :: 0x0001;
WM_CREATE :: 0x0001;
WM_DESTROY :: 0x0002;
WM_SIZE :: 0x0005;
WM_PAINT :: 0x000F;
WM_QUIT :: 0x0012;
WM_ERASEBKGND :: 0x0014;
WM_ACTIVATEAPP :: 0x001C;
WM_KEYDOWN :: 0x0100;
WM_KEYUP :: 0x0101;
WM_SYSKEYDOWN :: 0x0104;
WM_SYSKEYUP :: 0x0105;
WM_SYSCOMMAND :: 0x0112;
SC_KEYMENU :: 0xF100;
GWL_STYLE :: -16;
HWND_TOP :: cast(HWND) 0;
MONITOR_DEFAULTTOPRIMARY :: 1;
SWP_NOSIZE :: 0x0001;
SWP_NOMOVE :: 0x0002;
SWP_NOZORDER :: 0x0004;
SWP_FRAMECHANGED :: 0x0020;
VK_RETURN :: 0x0D;
VK_MENU :: 0x12;
VK_F4 :: 0x73;
VK_F10 :: 0x79;
VK_F11 :: 0x7A;

HDC :: *struct {};
HWND :: *struct {};
HMENU :: *struct {};
HICON :: *struct {};
HBRUSH :: *struct {};
HCURSOR :: *struct {};
HMONITOR :: *struct {};
WNDPROC :: #type (HWND, u32, usize, ssize) -> ssize #c_call;
POINT :: struct {
  x: s32;
  y: s32;
}
RECT :: struct {
  left: s32;
  top: s32;
  right: s32;
  bottom: s32;
}
WNDCLASSEXW :: struct {
  cbSize: u32;
  style: u32;
  lpfnWndProc: WNDPROC;
  cbClsExtra: s32;
  cbWndExtra: s32;
  hInstance: HINSTANCE;
  hIcon: HICON;
  hCursor: HCURSOR;
  hbrBackground: HBRUSH;
  lpszMenuName: *u16;
  lpszClassName: *u16;
  hIconSm: HICON;
}
MSG :: struct {
  hwnd: HWND;
  message: u32;
  wParam: usize;
  lParam: ssize;
  time: u32;
  pt: POINT;
  lPrivate: u32;
}
WINDOWPLACEMENT :: struct {
  length: u32;
  flags: u32;
  showCmd: u32;
  ptMinPosition: POINT;
  ptMaxPosition: POINT;
  rcNormalPosition: RECT;
  rcDevice: RECT;
}
MONITORINFO :: struct {
  cbSize: u32;
  rcMonitor: RECT;
  rcWork: RECT;
  dwFlags: u32;
}

SetProcessDPIAware :: () -> s32 #foreign User32;
LoadIconW :: (instance: HINSTANCE, name: *u16) -> HICON #foreign User32;
LoadCursorW :: (instance: HINSTANCE, name: *u16) -> HCURSOR #foreign User32;
RegisterClassExW :: (wndclass: *WNDCLASSEXW) -> u16 #foreign User32;
CreateWindowExW :: (ex_style: u32, class_name: *u16, title: *u16, style: u32, x: s32, y: s32, w: s32, h: s32, parent: HWND, menu: HMENU, instance: HINSTANCE, param: *void) -> HWND #foreign User32;
PeekMessageW :: (msg: *MSG, hwnd: HWND, min: u32, max: u32, mremove: u32) -> s32 #foreign User32;
TranslateMessage :: (msg: *MSG) -> s32 #foreign User32;
DispatchMessageW :: (msg: *MSG) -> ssize #foreign User32;
DefWindowProcW :: (hwnd: HWND, message: u32, wParam: usize, lParam: ssize) -> ssize #foreign User32;
PostQuitMessage :: (status: s32) #foreign User32;
GetDC :: (hwnd: HWND) -> HDC #foreign User32;
ValidateRect :: (hwnd: HWND, rect: *RECT) -> s32 #foreign User32;
DestroyWindow :: (hwnd: HWND) -> s32 #foreign User32;
ClipCursor :: (rect: *RECT) -> s32 #foreign User32;
GetWindowLongPtrW :: (hwnd: HWND, index: s32) -> ssize #foreign User32;
SetWindowLongPtrW :: (hwnd: HWND, index: s32, value: ssize) -> ssize #foreign User32;
GetWindowPlacement :: (hwnd: HWND, placement: *WINDOWPLACEMENT) -> s32 #foreign User32;
SetWindowPlacement :: (hwnd: HWND, placement: *WINDOWPLACEMENT) -> s32 #foreign User32;
SetWindowPos :: (hwnd: HWND, after: HWND, x: s32, y: s32, w: s32, h: s32, flags: u32) -> s32 #foreign User32;
MonitorFromWindow :: (hwnd: HWND, flags: u32) -> HMONITOR #foreign User32;
GetMonitorInfoW :: (monitor: HMONITOR, info: *MONITORINFO) -> s32 #foreign User32;

Ws2_32 :: #library,system "Ws2_32";

WSADESCRIPTION_LEN :: 256;
WSASYS_STATUS_LEN :: 128;

WSADATA32 :: struct {
  wVersion: u16;
  wHighVersion: u16;
  szDescription: [WSADESCRIPTION_LEN + 1]u8;
  szSystemStatus: [WSASYS_STATUS_LEN + 1]u8;
  iMaxSockets: u16;
  iMaxUdpDg: u16;
  lpVendorInfo: *u8;
}
WSADATA64 :: struct {
  wVersion: u16;
  wHighVersion: u16;
  iMaxSockets: u16;
  iMaxUdpDg: u16;
  lpVendorInfo: *u8;
  szDescription: [WSADESCRIPTION_LEN + 1]u8;
  szSystemStatus: [WSASYS_STATUS_LEN + 1]u8;
}
#if CPU == .X64 || CPU == .ARM64
  WSADATA :: WSADATA64;
else
  WSADATA :: WSADATA32;

WSAStartup :: (version: u16, data: *WSADATA) -> s32 #foreign Ws2_32;
WSACleanup :: () -> s32 #foreign Ws2_32;

Dwmapi :: #library,system "Dwmapi";

DWMWA_USE_IMMERSIVE_DARK_MODE :: 20;
DWMWA_WINDOW_CORNER_PREFERENCE :: 33;
DWMWCP_DONOTROUND :: 1;

DwmSetWindowAttribute :: (hwnd: HWND, attribute: u32, data: *void, size: u32) -> HRESULT #foreign Dwmapi;

Winmm :: #library,system "Winmm";

TIMERR_NOERROR :: 0;

timeBeginPeriod :: (interval: u32) -> u32 #foreign Winmm;

D3D11 :: #library,system "D3D11";

D3D11_SDK_VERSION :: 7;
ID3D11Texture2D_UUID :: IID.{0x6F15AAF2, 0xD208, 0x4E89, .[0x9A, 0xB4, 0x48, 0x95, 0x35, 0xD3, 0x4F, 0x9C]};

D3D_DRIVER_TYPE :: enum s32 {
  UNKNOWN :: 0;
  HARDWARE :: 1;
  REFERENCE :: 2;
  NULL :: 3;
  SOFTWARE :: 4;
  WARP :: 5;
}
D3D_FEATURE_LEVEL :: enum s32 {
  _1_0_GENERIC :: 0;
  _1_0_CORE :: 1;
  _9_1 :: 2;
  _9_2 :: 3;
  _9_3 :: 4;
  _10_0 :: 5;
  _10_1 :: 6;
  _11_0 :: 7;
  _11_1 :: 8;
  _12_0 :: 9;
  _12_1 :: 10;
  _12_2 :: 11;
}
D3D11_CREATE_DEVICE_FLAG :: enum_flags u32 {
  SINGLETHREADED :: 0x1;
  DEBUG :: 0x2;
  SWITCH_TO_REF :: 0x4;
  PREVENT_INTERNAL_THREADING_OPTIMIZATIONS :: 0x8;
  BGRA_SUPPORT :: 0x20;
  DEBUGGABLE :: 0x40;
  PREVENT_ALTERING_LAYER_SETTINGS_FROM_REGISTRY :: 0x80;
  DISABLE_GPU_TIMEOUT :: 0x100;
  VIDEO_SUPPORT :: 0x800;
}
D3D11_RTV_DIMENSION :: enum s32 {
  UNKNOWN :: 0;
  BUFFER :: 1;
  TEXTURE1D :: 2;
  TEXTURE1DARRAY :: 3;
  TEXTURE2D :: 4;
  TEXTURE2DARRAY :: 5;
  TEXTURE2DMS :: 6;
  TEXTURE2DMSARRAY :: 7;
  TEXTURE3D :: 8;
}
D3D11_BUFFER_RTV :: struct {
  using _: union {
    FirstElement: u32;
    ElementOffset: u32;
  };
  using _: union {
    NumElements: u32;
    ElementWidth: u32;
  };
}
D3D11_TEX1D_RTV :: struct {
  MipSlice: u32;
}
D3D11_TEX1D_ARRAY_RTV :: struct {
  MipSlice: u32;
  FirstArraySlice: u32;
  ArraySize: u32;
}
D3D11_TEX2D_RTV :: struct {
  MipSlice: u32;
}
D3D11_TEX2D_ARRAY_RTV :: struct {
  MipSlice: u32;
  FirstArraySlice: u32;
  ArraySize: u32;
}
D3D11_TEX2DMS_RTV :: struct {
  UnusedField_NothingToDefine: u32;
}
D3D11_TEX2DMS_ARRAY_RTV :: struct {
  FirstArraySlice: u32;
  ArraySize: u32;
}
D3D11_TEX3D_RTV :: struct {
  MipSlice: u32;
  FirstWSlice: u32;
  WSize: u32;
}
D3D11_RENDER_TARGET_VIEW_DESC :: struct {
  Format: DXGI_FORMAT;
  ViewDimension: D3D11_RTV_DIMENSION;
  using _: union {
    Buffer: D3D11_BUFFER_RTV;
    Texture1D: D3D11_TEX1D_RTV;
    Texture1DArray: D3D11_TEX1D_ARRAY_RTV;
    Texture2D: D3D11_TEX2D_RTV;
    Texture2DArray: D3D11_TEX2D_ARRAY_RTV;
    Texture2DMS: D3D11_TEX2DMS_RTV;
    Texture2DMSArray: D3D11_TEX2DMS_ARRAY_RTV;
    Texture3D: D3D11_TEX3D_RTV;
  };
}
D3D11_DSV_DIMENSION :: enum s32 {
  UNKNOWN :: 0;
  TEXTURE1D :: 1;
  TEXTURE1DARRAY :: 2;
  TEXTURE2D :: 3;
  TEXTURE2DARRAY :: 4;
  TEXTURE2DMS :: 5;
  TEXTURE2DMSARRAY :: 6;
}
D3D11_TEX1D_DSV :: struct {
  MipSlice: u32;
}
D3D11_TEX1D_ARRAY_DSV :: struct {
  MipSlice: u32;
  FirstArraySlice: u32;
  ArraySize: u32;
}
D3D11_TEX2D_DSV :: struct {
  MipSlice: u32;
}
D3D11_TEX2D_ARRAY_DSV :: struct {
  MipSlice: u32;
  FirstArraySlice: u32;
  ArraySize: u32;
}
D3D11_TEX2DMS_DSV :: struct {
  UnusedField_NothingToDefine: u32;
}
D3D11_TEX2DMS_ARRAY_DSV :: struct {
  FirstArraySlice: u32;
  ArraySize: u32;
}
D3D11_DEPTH_STENCIL_VIEW_DESC :: struct {
  Format: DXGI_FORMAT;
  ViewDimension: D3D11_DSV_DIMENSION;
  Flags: u32;
  using _: union {
    Texture1D: D3D11_TEX1D_DSV;
    Texture1DArray: D3D11_TEX1D_ARRAY_DSV;
    Texture2D: D3D11_TEX2D_DSV;
    Texture2DArray: D3D11_TEX2D_ARRAY_DSV;
    Texture2DMS: D3D11_TEX2DMS_DSV;
    Texture2DMSArray: D3D11_TEX2DMS_ARRAY_DSV;
  };
}
D3D11_USAGE :: enum s32 {
  DEFAULT :: 0;
  IMMUTABLE :: 1;
  DYNAMIC :: 2;
  STAGING :: 3;
}
D3D11_BIND_FLAG :: enum_flags u32 {
  VERTEX_BUFFER :: 0x1;
  INDEX_BUFFER :: 0x2;
  CONSTANT_BUFFER :: 0x4;
  SHADER_RESOURCE :: 0x8;
  STREAM_OUTPUT :: 0x10;
  RENDER_TARGET :: 0x20;
  DEPTH_STENCIL :: 0x40;
  UNORDERED_ACCESS :: 0x80;
  DECODER :: 0x200;
  VIDEO_ENCODER :: 0x400;
}
D3D11_TEXTURE2D_DESC :: struct {
  Width: u32;
  Height: u32;
  MipLevels: u32;
  ArraySize: u32;
  Format: DXGI_FORMAT;
  SampleDesc: DXGI_SAMPLE_DESC;
  Usage: D3D11_USAGE;
  BindFlags: D3D11_BIND_FLAG;
  CPUAccessFlags: u32;
  MiscFlags: u32;
}
D3D11_SUBRESOURCE_DATA :: struct {
  pSysMem: *void;
  SysMemPitch: u32;
  SysMemSlicePitch: u32;
}
D3D11_CLEAR_FLAG :: enum_flags u32 {
  DEPTH :: 0x1;
  STENCIL :: 0x2;
}
ID3D11Device_VTable :: struct {
  using iunknown_vtable: IUnknown_VTable;
  CreateBuffer: *void;
  CreateTexture1D: *void;
  CreateTexture2D: (*ID3D11Device, *D3D11_TEXTURE2D_DESC, *D3D11_SUBRESOURCE_DATA, **ID3D11Texture2D) -> HRESULT #cpp_method;
  CreateTexture3D: *void;
  CreateShaderResourceView: *void;
  CreateUnorderedAccessView: *void;
  CreateRenderTargetView: (*ID3D11Device, *ID3D11Resource, *D3D11_RENDER_TARGET_VIEW_DESC, **ID3D11RenderTargetView) -> HRESULT #cpp_method;
  CreateDepthStencilView: (*ID3D11Device, *ID3D11Resource, *D3D11_DEPTH_STENCIL_VIEW_DESC, **ID3D11DepthStencilView) -> HRESULT #cpp_method;
  CreateInputLayout: *void;
  CreateVertexShader: *void;
  CreateGeometryShader: *void;
  CreateGeometryShaderWithStreamOutput: *void;
  CreatePixelShader: *void;
  CreateHullShader: *void;
  CreateDomainShader: *void;
  CreateComputeShader: *void;
  CreateClassLinkage: *void;
  CreateBlendState: *void;
  CreateDepthStencilState: *void;
  CreateRasterizerState: *void;
  CreateSamplerState: *void;
  CreateQuery: *void;
  CreatePredicate: *void;
  CreateCounter: *void;
  CreateDeferredContext: *void;
  OpenSharedResource: *void;
  CheckFormatSupport: *void;
  CheckMultisampleQualityLevels: *void;
  CheckCounterInfo: *void;
  CheckCounter: *void;
  CheckFeatureSupport: *void;
  GetPrivateData: *void;
  SetPrivateData: *void;
  SetPrivateDataInterface: *void;
  GetFeatureLevel: *void;
  GetCreationFlags: *void;
  GetDeviceRemovedReason: *void;
  GetImmediateContext: *void;
  SetExceptionMode: *void;
  GetExceptionMode: *void;
}
ID3D11Device :: struct {
  #as iunknown: IUnknown;
  #place iunknown; using _id3d11device_vtable: *ID3D11Device_VTable;
}
ID3D11DeviceChild_VTable :: struct {
  using iunknown_vtable: IUnknown_VTable;
  GetDevice: *void;
  GetPrivateData: *void;
  SetPrivateData: *void;
  SetPrivateDataInterface: *void;
}
ID3D11DeviceChild :: struct {
  #as iunknown: IUnknown;
  #place iunknown; using _id3d11devicechild_vtable: *ID3D11DeviceChild_VTable;
}
ID3D11DeviceContext_VTable :: struct {
  using id3d11devicechild_vtable: ID3D11DeviceChild_VTable;
  VSSetConstantBuffers: *void;
  PSSetShaderResources: *void;
  PSSetShader: *void;
  PSSetSamplers: *void;
  VSSetShader: *void;
  DrawIndexed: *void;
  Draw: *void;
  Map: *void;
  Unmap: *void;
  PSSetConstantBuffers: *void;
  IASetInputLayout: *void;
  IASetVertexBuffers: *void;
  IASetIndexBuffer: *void;
  DrawIndexedInstanced: *void;
  DrawInstanced: *void;
  GSSetConstantBuffers: *void;
  GSSetShader: *void;
  IASetPrimitiveTopology: *void;
  VSSetShaderResources: *void;
  VSSetSamplers: *void;
  Begin: *void;
  End: *void;
  GetData: *void;
  SetPredication: *void;
  GSSetShaderResources: *void;
  GSSetSamplers: *void;
  OMSetRenderTargets: *void;
  OMSetRenderTargetsAndUnorderedAccessViews: *void;
  OMSetBlendState: *void;
  OMSetDepthStencilState: *void;
  SOSetTargets: *void;
  DrawAuto: *void;
  DrawIndexedInstancedIndirect: *void;
  DrawInstancedIndirect: *void;
  Dispatch: *void;
  DispatchIndirect: *void;
  RSSetState: *void;
  RSSetViewports: *void;
  RSSetScissorRects: *void;
  CopySubresourceRegion: *void;
  CopyResource: *void;
  UpdateSubresource: *void;
  CopyStructureCount: *void;
  ClearRenderTargetView: (*ID3D11DeviceContext, *ID3D11RenderTargetView, *f32) #cpp_method;
  ClearUnorderedAccessViewUint: *void;
  ClearUnorderedAccessViewFloat: *void;
  ClearDepthStencilView: (*ID3D11DeviceContext, *ID3D11DepthStencilView, D3D11_CLEAR_FLAG, f32, u8) #cpp_method;
  GenerateMips: *void;
  SetResourceMinLOD: *void;
  GetResourceMinLOD: *void;
  ResolveSubresource: *void;
  ExecuteCommandList: *void;
  HSSetShaderResources: *void;
  HSSetShader: *void;
  HSSetSamplers: *void;
  HSSetConstantBuffers: *void;
  DSSetShaderResources: *void;
  DSSetShader: *void;
  DSSetSamplers: *void;
  DSSetConstantBuffers: *void;
  CSSetShaderResources: *void;
  CSSetUnorderedAccessViews: *void;
  CSSetShader: *void;
  CSSetSamplers: *void;
  CSSetConstantBuffers: *void;
  VSGetConstantBuffers: *void;
  PSGetShaderResources: *void;
  PSGetShader: *void;
  PSGetSamplers: *void;
  VSGetShader: *void;
  PSGetConstantBuffers: *void;
  IAGetInputLayout: *void;
  IAGetVertexBuffers: *void;
  IAGetIndexBuffer: *void;
  GSGetConstantBuffers: *void;
  GSGetShader: *void;
  IAGetPrimitiveTopology: *void;
  VSGetShaderResources: *void;
  VSGetSamplers: *void;
  GetPredication: *void;
  GSGetShaderResources: *void;
  GSGetSamplers: *void;
  OMGetRenderTargets: *void;
  OMGetRenderTargetsAndUnorderedAccessViews: *void;
  OMGetBlendState: *void;
  OMGetDepthStencilState: *void;
  SOGetTargets: *void;
  RSGetState: *void;
  RSGetViewports: *void;
  RSGetScissorRects: *void;
  HSGetShaderResources: *void;
  HSGetShader: *void;
  HSGetSamplers: *void;
  HSGetConstantBuffers: *void;
  DSGetShaderResources: *void;
  DSGetShader: *void;
  DSGetSamplers: *void;
  DSGetConstantBuffers: *void;
  CSGetShaderResources: *void;
  CSGetUnorderedAccessViews: *void;
  CSGetShader: *void;
  CSGetSamplers: *void;
  CSGetConstantBuffers: *void;
  ClearState: *void;
  Flush: *void;
  GetType: *void;
  GetContextFlags: *void;
  FinishCommandList: *void;
}
ID3D11DeviceContext :: struct {
  #as id3d11devicechild: ID3D11DeviceChild;
  #place id3d11devicechild; using _id3d11devicecontext_vtable: *ID3D11DeviceContext_VTable;
}
ID3D11Resource_VTable :: struct {
  using id3d11devicechild_vtable: ID3D11DeviceChild_VTable;
  GetType: *void;
  SetEvictionPolicy: *void;
  GetEvictionPolicy: *void;
}
ID3D11Resource :: struct {
  #as id3d11devicechild: ID3D11DeviceChild;
  #place id3d11devicechild; using _id3d11resource_vtable: *ID3D11Resource_VTable;
}
ID3D11Texture2D_VTable :: struct {
  using id3d11resource_vtable: ID3D11Resource_VTable;
  GetDesc: *void;
}
ID3D11Texture2D :: struct {
  #as id3d11resource: ID3D11Resource;
  #place id3d11resource; using _id3d11texture2d_vtable: *ID3D11Texture2D_VTable;
}
ID3D11View_VTable :: struct {
  using id3d11devicechild_vtable: ID3D11DeviceChild_VTable;
  GetResource: *void;
}
ID3D11View :: struct {
  #as id3d11devicechild: ID3D11DeviceChild;
  #place id3d11devicechild; using _id3d11view_vtable: *ID3D11View_VTable;
}
ID3D11RenderTargetView_VTable :: struct {
  using id3d11view_vtable: ID3D11View_VTable;
  GetDesc: *void;
}
ID3D11RenderTargetView :: struct {
  #as id3d11view: ID3D11View;
  #place id3d11view; using _id3d11rendertargetview_vtable: *ID3D11RenderTargetView_VTable;
}
ID3D11DepthStencilView_VTable :: struct {
  using id3d11view_vtable: ID3D11View_VTable;
  GetDesc: *void;
}
ID3D11DepthStencilView :: struct {
  #as id3d11view: ID3D11View;
  #place id3d11view; using _id3d11rendertargetview_vtable: *ID3D11DepthStencilView_VTable;
}

D3D11CreateDeviceAndSwapChain :: (adapter: *IDXGIAdapter, driver: D3D_DRIVER_TYPE, software: HMODULE, flags: D3D11_CREATE_DEVICE_FLAG, feature_levels: *D3D_FEATURE_LEVEL, feature_levels_count: u32, sdk_version: u32, swapchain_desc: *DXGI_SWAP_CHAIN_DESC, swapchain: **IDXGISwapChain, device: **ID3D11Device, feature_level: *D3D_FEATURE_LEVEL, ctx: **ID3D11DeviceContext) -> HRESULT #foreign D3D11;

dxgi :: #library,system "dxgi";

IDXGIFactory_UUID :: IID.{0x7B7166EC, 0x21C7, 0x44AE, .[0xB2, 0x1A, 0xC9, 0xAE, 0x32, 0x1A, 0xE3, 0x69]};
IDXGIDevice_UUID :: IID.{0x54EC77FA, 0x1377, 0x44E6, .[0x8C, 0x32, 0x88, 0xFD, 0x5F, 0x44, 0xC8, 0x4C]};

DXGI_FORMAT :: enum u32 {
  UNKNOWN :: 0;
  R32G32B32A32_TYPELESS :: 1;
  R32G32B32A32_FLOAT :: 2;
  R32G32B32A32_UINT :: 3;
  R32G32B32A32_SINT :: 4;
  R32G32B32_TYPELESS :: 5;
  R32G32B32_FLOAT :: 6;
  R32G32B32_UINT :: 7;
  R32G32B32_SINT :: 8;
  R16G16B16A16_TYPELESS :: 9;
  R16G16B16A16_FLOAT :: 10;
  R16G16B16A16_UNORM :: 11;
  R16G16B16A16_UINT :: 12;
  R16G16B16A16_SNORM :: 13;
  R16G16B16A16_SINT :: 14;
  R32G32_TYPELESS :: 15;
  R32G32_FLOAT :: 16;
  R32G32_UINT :: 17;
  R32G32_SINT :: 18;
  R32G8X24_TYPELESS :: 19;
  D32_FLOAT_S8X24_UINT :: 20;
  R32_FLOAT_X8X24_TYPELESS :: 21;
  X32_TYPELESS_G8X24_UINT :: 22;
  R10G10B10A2_TYPELESS :: 23;
  R10G10B10A2_UNORM :: 24;
  R10G10B10A2_UINT :: 25;
  R11G11B10_FLOAT :: 26;
  R8G8B8A8_TYPELESS :: 27;
  R8G8B8A8_UNORM :: 28;
  R8G8B8A8_UNORM_SRGB :: 29;
  R8G8B8A8_UINT :: 30;
  R8G8B8A8_SNORM :: 31;
  R8G8B8A8_SINT :: 32;
  R16G16_TYPELESS :: 33;
  R16G16_FLOAT :: 34;
  R16G16_UNORM :: 35;
  R16G16_UINT :: 36;
  R16G16_SNORM :: 37;
  R16G16_SINT :: 38;
  R32_TYPELESS :: 39;
  D32_FLOAT :: 40;
  R32_FLOAT :: 41;
  R32_UINT :: 42;
  R32_SINT :: 43;
  R24G8_TYPELESS :: 44;
  D24_UNORM_S8_UINT :: 45;
  R24_UNORM_X8_TYPELESS :: 46;
  X24_TYPELESS_G8_UINT :: 47;
  R8G8_TYPELESS :: 48;
  R8G8_UNORM :: 49;
  R8G8_UINT :: 50;
  R8G8_SNORM :: 51;
  R8G8_SINT :: 52;
  R16_TYPELESS :: 53;
  R16_FLOAT :: 54;
  D16_UNORM :: 55;
  R16_UNORM :: 56;
  R16_UINT :: 57;
  R16_SNORM :: 58;
  R16_SINT :: 59;
  R8_TYPELESS :: 60;
  R8_UNORM :: 61;
  R8_UINT :: 62;
  R8_SNORM :: 63;
  R8_SINT :: 64;
  A8_UNORM :: 65;
  R1_UNORM :: 66;
  R9G9B9E5_SHAREDEXP :: 67;
  R8G8_B8G8_UNORM :: 68;
  G8R8_G8B8_UNORM :: 69;
  BC1_TYPELESS :: 70;
  BC1_UNORM :: 71;
  BC1_UNORM_SRGB :: 72;
  BC2_TYPELESS :: 73;
  BC2_UNORM :: 74;
  BC2_UNORM_SRGB :: 75;
  BC3_TYPELESS :: 76;
  BC3_UNORM :: 77;
  BC3_UNORM_SRGB :: 78;
  BC4_TYPELESS :: 79;
  BC4_UNORM :: 80;
  BC4_SNORM :: 81;
  BC5_TYPELESS :: 82;
  BC5_UNORM :: 83;
  BC5_SNORM :: 84;
  B5G6R5_UNORM :: 85;
  B5G5R5A1_UNORM :: 86;
  B8G8R8A8_UNORM :: 87;
  B8G8R8X8_UNORM :: 88;
  R10G10B10_XR_BIAS_A2_UNORM :: 89;
  B8G8R8A8_TYPELESS :: 90;
  B8G8R8A8_UNORM_SRGB :: 91;
  B8G8R8X8_TYPELESS :: 92;
  B8G8R8X8_UNORM_SRGB :: 93;
  BC6H_TYPELESS :: 94;
  BC6H_UF16 :: 95;
  BC6H_SF16 :: 96;
  BC7_TYPELESS :: 97;
  BC7_UNORM :: 98;
  BC7_UNORM_SRGB :: 99;
  AYUV :: 100;
  Y410 :: 101;
  Y416 :: 102;
  NV12 :: 103;
  P010 :: 104;
  P016 :: 105;
  _420_OPAQUE :: 106;
  YUY2 :: 107;
  Y210 :: 108;
  Y216 :: 109;
  NV11 :: 110;
  AI44 :: 111;
  IA44 :: 112;
  P8 :: 113;
  A8P8 :: 114;
  B4G4R4A4_UNORM :: 115;
  P208 :: 130;
  V208 :: 131;
  V408 :: 132;
  SAMPLER_FEEDBACK_MIN_MIP_OPAQUE :: 189;
  SAMPLER_FEEDBACK_MIP_REGION_USED_OPAQUE :: 190;
}
DXGI_MODE_SCANLINE_ORDER :: enum s32 {
  UNSPECIFIED :: 0;
  PROGRESSIVE :: 1;
  UPPER_FIELD_FIRST :: 2;
  LOWER_FIELD_FIRST :: 3;
}
DXGI_MODE_SCALING :: enum s32 {
  UNSPECIFIED :: 0;
  CENTERED :: 1;
  STRETCHED :: 2;
}
DXGI_USAGE :: enum_flags u32 {
  SHADER_INPUT :: 1 << (0 + 4);
  RENDER_TARGET_OUTPUT :: 1 << (1 + 4);
  BACK_BUFFER :: 1 << (2 + 4);
  SHARED :: 1 << (3 + 4);
  READ_ONLY :: 1 << (4 + 4);
  DISCARD_ON_PRESENT :: 1 << (5 + 4);
  UNORDERED_ACCESS :: 1 << (6 + 4);
}
DXGI_SWAP_EFFECT :: enum s32 {
  DISCARD :: 0;
  SEQUENTIAL :: 1;
  FLIP_SEQUENTIAL :: 3;
  FLIP_DISCARD :: 4;
}
DXGI_SWAP_CHAIN_FLAG :: enum_flags u32 {
  NONPREROTATED :: 1;
  ALLOW_MODE_SWITCH :: 2;
  GDI_COMPATIBLE :: 4;
  RESTRICTED_CONTENT :: 8;
  RESTRICT_SHARED_RESOURCE_DRIVER :: 16;
  DISPLAY_ONLY :: 32;
  FRAME_LATENCY_WAITABLE_OBJECT :: 64;
  FOREGROUND_LAYER :: 128;
  FULLSCREEN_VIDEO :: 256;
  YUV_VIDEO :: 512;
  HW_PROTECTED :: 1024;
  ALLOW_TEARING :: 2048;
  RESTRICTED_TO_ALL_HOLOGRAPHIC_DISPLAYS :: 4096;
}
DXGI_RATIONAL :: struct {
  Numerator: u32;
  Denominator: u32;
}
DXGI_MODE_DESC :: struct {
  Width: u32;
  Height: u32;
  RefreshRate: DXGI_RATIONAL;
  Format: DXGI_FORMAT;
  ScanlineOrdering: DXGI_MODE_SCANLINE_ORDER;
  Scaling: DXGI_MODE_SCALING;
}
DXGI_SAMPLE_DESC :: struct {
  Count: u32;
  Quality: u32;
}
DXGI_SWAP_CHAIN_DESC :: struct {
  BufferDesc: DXGI_MODE_DESC;
  SampleDesc: DXGI_SAMPLE_DESC;
  BufferUsage: DXGI_USAGE;
  BufferCount: u32;
  OutputWindow: HWND;
  Windowed: s32;
  SwapEffect: DXGI_SWAP_EFFECT;
  Flags: DXGI_SWAP_CHAIN_FLAG;
}
DXGI_MWA :: enum_flags u32 {
  NO_WINDOW_CHANGES :: 1 << 0;
  NO_ALT_ENTER :: 1 << 1;
  NO_PRINT_SCREEN :: 1 << 2;
}
IDXGIObject_VTable :: struct {
  using iunknown_vtable: IUnknown_VTable;
  SetPrivateData: (*IDXGIObject, *GUID, u32, *void) -> HRESULT #cpp_method;
  SetPrivateDataInterface: (*IDXGIObject, *GUID, *IUnknown) -> HRESULT #cpp_method;
  GetPrivateData: (*IDXGIObject, *GUID, *u32, *void) -> HRESULT #cpp_method;
  GetParent: (*IDXGIObject, *IID, **void) -> HRESULT #cpp_method;
}
IDXGIObject :: struct {
  #as iunknown: IUnknown;
  #place iunknown; using _idxgiobject_vtable: *IDXGIObject_VTable;
}
IDXGIFactory_VTable :: struct {
  using idxgiobject_vtable: IDXGIObject_VTable;
  EnumAdapters: *void;
  MakeWindowAssociation: (*IDXGIFactory, HWND, DXGI_MWA) -> HRESULT #cpp_method;
  GetWindowAssociation: *void;
  CreateSwapChain: *void;
  CreateSoftwareAdapter: *void;
}
IDXGIFactory :: struct {
  #as idxgiobject: IDXGIObject;
  #place idxgiobject; using _idxgifactory_vtable: *IDXGIFactory_VTable;
}
IDXGIAdapter_VTable :: struct {
  using idxgiobject_vtable: IDXGIObject_VTable;
  EnumOutputs: *void;
  GetDesc: *void;
  CheckInterfaceSupport: (*IDXGIAdapter, *GUID, *s64) -> HRESULT #cpp_method;
}
IDXGIAdapter :: struct {
  #as idxgiobject: IDXGIObject;
  #place idxgiobject; using _idxgiadapter_vtable: *IDXGIAdapter_VTable;
}
IDXGIDevice_VTable :: struct {
  using idxgiobject_vtable: IDXGIObject_VTable;
  GetAdapter: (*IDXGIDevice, **IDXGIAdapter) -> HRESULT #cpp_method;
  CreateSurface: *void;
  QueryResourceResidency: *void;
  SetGPUThreadPriority: *void;
  GetGPUThreadPriority: *void;
}
IDXGIDevice :: struct {
  #as idxgiobject: IDXGIObject;
  #place idxgiobject; using _idxgidevice_vtable: *IDXGIDevice_VTable;
}
IDXGIDeviceSubObject_VTable :: struct {
  using idxgiobject_vtable: IDXGIObject_VTable;
  GetDevice: (*IDXGIDeviceSubObject, *IID, **void) -> HRESULT #cpp_method;
}
IDXGIDeviceSubObject :: struct {
  #as idxgiobject: IDXGIObject;
  #place idxgiobject; using _idxgidevicesubobject_vtable: *IDXGIDeviceSubObject_VTable;
}
IDXGISwapChain_VTable :: struct {
  using idxgidevicesubobject_vtable: IDXGIDeviceSubObject_VTable;
  Present: (*IDXGISwapChain, u32, u32) -> HRESULT #cpp_method;
  GetBuffer: (*IDXGISwapChain, u32, *IID, **void) -> HRESULT #cpp_method;
  SetFullscreenState: *void;
  GetFullscreenState: *void;
  GetDesc: *void;
  ResizeBuffers: (*IDXGISwapChain, u32, u32, u32, DXGI_FORMAT, DXGI_SWAP_CHAIN_FLAG) -> HRESULT #cpp_method;
  ResizeTarget: *void;
  GetContainingOutput: *void;
  GetFrameStatistics: *void;
  GetLastPresentCount: *void;
}
IDXGISwapChain :: struct {
  #as idxgidevicesubobject: IDXGIDeviceSubObject;
  #place idxgidevicesubobject; using _idxgiswapchain_vtable: *IDXGISwapChain_VTable;
}

D3DCompiler :: #library,system "D3DCompiler";
