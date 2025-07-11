module basic.windows;

import basic;

// Kernel32
alias HRESULT = s32;
struct HINSTANCE__; alias HINSTANCE = HINSTANCE__*;
alias HMODULE = HINSTANCE;
alias PROC = extern(Windows) ssize function();
struct GUID {
  u32 Data1;
  u16 Data2;
  u16 Data3;
  u8[8] Data4;
}
alias IID = const(GUID);
struct IUnknown {
  struct VTable {
    extern(Windows) HRESULT function(IUnknown*, IID*, void**) QueryInterface;
    extern(Windows) u32 function(IUnknown*) AddRef;
    extern(Windows) u32 function(IUnknown*) Release;
  }
  mixin COMClass;
}

@foreign("Kernel32") extern(Windows) {
  HMODULE GetModuleHandleW(const(wchar)*);
  HMODULE LoadLibraryW(const(wchar)*);
  PROC GetProcAddress(HMODULE, const(char)*);
  s32 FreeLibrary(HMODULE);
  void Sleep(u32);
  noreturn ExitProcess(u32);
}

// User32
enum CS_OWNDC = 0x0020;
enum IDI_WARNING = cast(const(wchar)*) 32515;
enum IDC_CROSS = cast(const(wchar)*) 32515;
enum WS_MAXIMIZEBOX = 0x00010000;
enum WS_MINIMIZEBOX = 0x00020000;
enum WS_THICKFRAME = 0x00040000;
enum WS_SYSMENU = 0x00080000;
enum WS_CAPTION = 0x00C00000;
enum WS_VISIBLE = 0x10000000;
enum WS_OVERLAPPEDWINDOW = WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX;
enum CW_USEDEFAULT = 0x80000000;
enum PM_REMOVE = 0x0001;
enum WM_CREATE = 0x0001;
enum WM_DESTROY = 0x0002;
enum WM_SIZE = 0x0005;
enum WM_PAINT = 0x000F;
enum WM_QUIT = 0x0012;
enum WM_ERASEBKGND = 0x0014;
enum WM_ACTIVATEAPP = 0x001C;
enum WM_KEYDOWN = 0x0100;
enum WM_KEYUP = 0x0101;
enum WM_SYSKEYDOWN = 0x0104;
enum WM_SYSKEYUP = 0x0105;
enum WM_SYSCOMMAND = 0x0112;
enum SC_KEYMENU = 0xF100;
enum GWL_STYLE = -16;
enum MONITOR_DEFAULTTOPRIMARY = 1;
enum HWND_TOP = cast(HWND) 0;
enum SWP_NOSIZE = 0x0001;
enum SWP_NOMOVE = 0x0002;
enum SWP_NOZORDER = 0x0004;
enum SWP_FRAMECHANGED = 0x0020;
enum VK_RETURN = 0x0D;
enum VK_MENU = 0x12;
enum VK_F4 = 0x73;
enum VK_F6 = 0x75;
enum VK_F10 = 0x79;
enum VK_F11 = 0x7A;

struct HDC__; alias HDC = HDC__*;
struct HWND__; alias HWND = HWND__*;
struct HMENU__; alias HMENU = HMENU__*;
struct HICON__; alias HICON = HICON__*;
struct HBRUSH__; alias HBRUSH = HBRUSH__*;
struct HCURSOR__; alias HCURSOR = HCURSOR__*;
struct HMONITOR__; alias HMONITOR = HMONITOR__*;
alias WNDPROC = extern(Windows) ssize function(HWND, u32, usize, ssize);
struct POINT {
  s32 x;
  s32 y;
}
struct RECT {
  s32 left;
  s32 top;
  s32 right;
  s32 bottom;
}
struct WNDCLASSEXW {
  u32 cbSize;
  u32 style;
  WNDPROC lpfnWndProc;
  s32 cbClsExtra;
  s32 cbWndExtra;
  HINSTANCE hInstance;
  HICON hIcon;
  HCURSOR hCursor;
  HBRUSH hbrBackground;
  const(wchar)* lpszMenuName;
  const(wchar)* lpszClassName;
  HICON hIconSm;
}
struct MSG {
  HWND hwnd;
  u32 message;
  usize wParam;
  ssize lParam;
  u32 time;
  POINT pt;
  u32 lPrivate;
}
struct WINDOWPLACEMENT {
  u32 length;
  u32 flags;
  u32 showCmd;
  POINT ptMinPosition;
  POINT ptMaxPosition;
  RECT rcNormalPosition;
  RECT rcDevice;
}
struct MONITORINFO {
  u32 cbSize;
  RECT rcMonitor;
  RECT rcWork;
  u32 dwFlags;
}

@foreign("User32") extern(Windows) {
  s32 SetProcessDPIAware();
  HICON LoadIconW(HINSTANCE, const(wchar)*);
  HCURSOR LoadCursorW(HINSTANCE, const(wchar)*);
  u16 RegisterClassExW(const(WNDCLASSEXW)*);
  HWND CreateWindowExW(u32, const(wchar)*, const(wchar)*, u32, s32, s32, s32, s32, HWND, HMENU, HINSTANCE, void*);
  s32 PeekMessageW(MSG*, HWND, u32, u32, u32);
  s32 TranslateMessage(const(MSG)*);
  ssize DispatchMessageW(const(MSG)*);
  ssize DefWindowProcW(HWND, u32, usize, ssize);
  HDC GetDC(HWND);
  s32 DestroyWindow(HWND);
  s32 ShowCursor(s32);
  s32 ClipCursor(const(RECT)*);
  s32 ValidateRect(HWND, const(RECT)*);
  void PostQuitMessage(s32);
  s32 SetWindowTextA(HWND, const(char)*);
  ssize GetWindowLongPtrW(HWND, s32);
  ssize SetWindowLongPtrW(HWND, s32, ssize);
  s32 GetWindowPlacement(HWND, WINDOWPLACEMENT*);
  s32 SetWindowPlacement(HWND, const(WINDOWPLACEMENT)*);
  s32 SetWindowPos(HWND, HWND, s32, s32, s32, s32, u32);
  HMONITOR MonitorFromWindow(HWND, u32);
  s32 GetMonitorInfoW(HMONITOR, MONITORINFO*);
}

// Ws2_32
enum WSADESCRIPTION_LEN = 256;
enum WSASYS_STATUS_LEN = 128;

struct WSADATA32 {
  u16 wVersion;
  u16 wHighVersion;
  char[WSADESCRIPTION_LEN + 1] szDescription;
  char[WSASYS_STATUS_LEN + 1] szSystemStatus;
  u16 iMaxSockets;
  u16 iMaxUdpDg;
  char* lpVendorInfo;
}
struct WSADATA64 {
  u16 wVersion;
  u16 wHighVersion;
  u16 iMaxSockets;
  u16 iMaxUdpDg;
  char* lpVendorInfo;
  char[WSADESCRIPTION_LEN + 1] szDescription;
  char[WSASYS_STATUS_LEN + 1] szSystemStatus;
}
version (Win32) alias WSADATA = WSADATA32;
version (Win64) alias WSADATA = WSADATA64;

@foreign("Ws2_32") extern(Windows) {
  s32 WSAStartup(u16, WSADATA*);
  s32 WSACleanup();
}

// Dwmapi
enum DWMWA_USE_IMMERSIVE_DARK_MODE = 20;
enum DWMWA_WINDOW_CORNER_PREFERENCE = 33;
enum DWMWCP_DONOTROUND = 1;

@foreign("Dwmapi") extern(Windows) {
  HRESULT DwmSetWindowAttribute(HWND, u32, const(void)*, u32);
}

// Winmm
enum TIMERR_NOERROR = 0;

@foreign("Winmm") extern(Windows) {
  u32 timeBeginPeriod(u32);
}

// D3D11
enum D3D11_SDK_VERSION = 7;

enum D3D_DRIVER_TYPE : s32 {
  UNKNOWN = 0,
  HARDWARE = 1,
  REFERENCE = 2,
  NULL = 3,
  SOFTWARE = 4,
  WARP = 5,
}
enum D3D_FEATURE_LEVEL : s32 {
  _1_0_GENERIC = 0,
  _1_0_CORE = 1,
  _9_1 = 2,
  _9_2 = 3,
  _9_3 = 4,
  _10_0 = 5,
  _10_1 = 6,
  _11_0 = 7,
  _11_1 = 8,
  _12_0 = 9,
  _12_1 = 10,
  _12_2 = 11,
}
enum D3D11_CREATE_DEVICE_FLAGS : s32 {
  SINGLETHREADED = 0x1,
  DEBUG = 0x2,
  SWITCH_TO_REF = 0x4,
  PREVENT_INTERNAL_THREADING_OPTIMIZATIONS = 0x8,
  BGRA_SUPPORT = 0x20,
  DEBUGGABLE = 0x40,
  PREVENT_ALTERING_LAYER_SETTINGS_FROM_REGISTRY = 0x80,
  DISABLE_GPU_TIMEOUT = 0x100,
  VIDEO_SUPPORT = 0x800,
}
alias D3D11_CREATE_DEVICE_FLAG = EnumFlags!D3D11_CREATE_DEVICE_FLAGS;
struct ID3D11Device {
  struct VTable {
    IUnknown.VTable iunknown_vtable;
    alias this = iunknown_vtable;
    void* CreateBuffer;
    void* CreateTexture1D;
    void* CreateTexture2D;
    void* CreateTexture3D;
    void* CreateShaderResourceView;
    void* CreateUnorderedAccessView;
    void* CreateRenderTargetView;
    void* CreateDepthStencilView;
    void* CreateInputLayout;
    void* CreateVertexShader;
    void* CreateGeometryShader;
    void* CreateGeometryShaderWithStreamOutput;
    void* CreatePixelShader;
    void* CreateHullShader;
    void* CreateDomainShader;
    void* CreateComputeShader;
    void* CreateClassLinkage;
    void* CreateBlendState;
    void* CreateDepthStencilState;
    void* CreateRasterizerState;
    void* CreateSamplerState;
    void* CreateQuery;
    void* CreatePredicate;
    void* CreateCounter;
    void* CreateDeferredContext;
    void* OpenSharedResource;
    void* CheckFormatSupport;
    void* CheckMultisampleQualityLevels;
    void* CheckCounterInfo;
    void* CheckCounter;
    void* CheckFeatureSupport;
    void* GetPrivateData;
    void* SetPrivateData;
    void* SetPrivateDataInterface;
    void* GetFeatureLevel;
    void* GetCreationFlags;
    void* GetDeviceRemovedReason;
    void* GetImmediateContext;
    void* SetExceptionMode;
    void* GetExceptionMode;
  }
  mixin COMClass!IUnknown;
}
struct ID3D11DeviceChild {
  struct VTable {
    IUnknown.VTable iunknown_vtable;
    alias this = iunknown_vtable;
    void* GetDevice;
    void* GetPrivateData;
    void* SetPrivateData;
    void* SetPrivateDataInterface;
  }
  mixin COMClass!IUnknown;
}
struct ID3D11DeviceContext {
  struct VTable {
    ID3D11DeviceChild.VTable id3d11devicechild_vtable;
    alias this = id3d11devicechild_vtable;
    void *VSSetConstantBuffers;
    void *PSSetShaderResources;
    void *PSSetShader;
    void *PSSetSamplers;
    void *VSSetShader;
    void *DrawIndexed;
    void *Draw;
    void *Map;
    void *Unmap;
    void *PSSetConstantBuffers;
    void *IASetInputLayout;
    void *IASetVertexBuffers;
    void *IASetIndexBuffer;
    void *DrawIndexedInstanced;
    void *DrawInstanced;
    void *GSSetConstantBuffers;
    void *GSSetShader;
    void *IASetPrimitiveTopology;
    void *VSSetShaderResources;
    void *VSSetSamplers;
    void *Begin;
    void *End;
    void *GetData;
    void *SetPredication;
    void *GSSetShaderResources;
    void *GSSetSamplers;
    void *OMSetRenderTargets;
    void *OMSetRenderTargetsAndUnorderedAccessViews;
    void *OMSetBlendState;
    void *OMSetDepthStencilState;
    void *SOSetTargets;
    void *DrawAuto;
    void *DrawIndexedInstancedIndirect;
    void *DrawInstancedIndirect;
    void *Dispatch;
    void *DispatchIndirect;
    void *RSSetState;
    void *RSSetViewports;
    void *RSSetScissorRects;
    void *CopySubresourceRegion;
    void *CopyResource;
    void *UpdateSubresource;
    void *CopyStructureCount;
    void *ClearRenderTargetView;
    void *ClearUnorderedAccessViewUint;
    void *ClearUnorderedAccessViewFloat;
    void *ClearDepthStencilView;
    void *GenerateMips;
    void *SetResourceMinLOD;
    void *GetResourceMinLOD;
    void *ResolveSubresource;
    void *ExecuteCommandList;
    void *HSSetShaderResources;
    void *HSSetShader;
    void *HSSetSamplers;
    void *HSSetConstantBuffers;
    void *DSSetShaderResources;
    void *DSSetShader;
    void *DSSetSamplers;
    void *DSSetConstantBuffers;
    void *CSSetShaderResources;
    void *CSSetUnorderedAccessViews;
    void *CSSetShader;
    void *CSSetSamplers;
    void *CSSetConstantBuffers;
    void *VSGetConstantBuffers;
    void *PSGetShaderResources;
    void *PSGetShader;
    void *PSGetSamplers;
    void *VSGetShader;
    void *PSGetConstantBuffers;
    void *IAGetInputLayout;
    void *IAGetVertexBuffers;
    void *IAGetIndexBuffer;
    void *GSGetConstantBuffers;
    void *GSGetShader;
    void *IAGetPrimitiveTopology;
    void *VSGetShaderResources;
    void *VSGetSamplers;
    void *GetPredication;
    void *GSGetShaderResources;
    void *GSGetSamplers;
    void *OMGetRenderTargets;
    void *OMGetRenderTargetsAndUnorderedAccessViews;
    void *OMGetBlendState;
    void *OMGetDepthStencilState;
    void *SOGetTargets;
    void *RSGetState;
    void *RSGetViewports;
    void *RSGetScissorRects;
    void *HSGetShaderResources;
    void *HSGetShader;
    void *HSGetSamplers;
    void *HSGetConstantBuffers;
    void *DSGetShaderResources;
    void *DSGetShader;
    void *DSGetSamplers;
    void *DSGetConstantBuffers;
    void *CSGetShaderResources;
    void *CSGetUnorderedAccessViews;
    void *CSGetShader;
    void *CSGetSamplers;
    void *CSGetConstantBuffers;
    void *ClearState;
    void *Flush;
    void *GetType;
    void *GetContextFlags;
    void *FinishCommandList;

  }
  mixin COMClass!ID3D11DeviceChild;
}

@foreign("D3D11") extern(Windows) {
  HRESULT D3D11CreateDeviceAndSwapChain(IDXGIAdapter*, D3D_DRIVER_TYPE, HMODULE, D3D11_CREATE_DEVICE_FLAG, const(D3D_FEATURE_LEVEL)*, u32, u32, const(DXGI_SWAP_CHAIN_DESC)*, IDXGISwapChain**, ID3D11Device**, D3D_FEATURE_LEVEL*, ID3D11DeviceContext**);
}

// dxgi
enum DXGI_FORMAT : u32 {
  UNKNOWN = 0,
  R32G32B32A32_TYPELESS = 1,
  R32G32B32A32_FLOAT = 2,
  R32G32B32A32_UINT = 3,
  R32G32B32A32_SINT = 4,
  R32G32B32_TYPELESS = 5,
  R32G32B32_FLOAT = 6,
  R32G32B32_UINT = 7,
  R32G32B32_SINT = 8,
  R16G16B16A16_TYPELESS = 9,
  R16G16B16A16_FLOAT = 10,
  R16G16B16A16_UNORM = 11,
  R16G16B16A16_UINT = 12,
  R16G16B16A16_SNORM = 13,
  R16G16B16A16_SINT = 14,
  R32G32_TYPELESS = 15,
  R32G32_FLOAT = 16,
  R32G32_UINT = 17,
  R32G32_SINT = 18,
  R32G8X24_TYPELESS = 19,
  D32_FLOAT_S8X24_UINT = 20,
  R32_FLOAT_X8X24_TYPELESS = 21,
  X32_TYPELESS_G8X24_UINT = 22,
  R10G10B10A2_TYPELESS = 23,
  R10G10B10A2_UNORM = 24,
  R10G10B10A2_UINT = 25,
  R11G11B10_FLOAT = 26,
  R8G8B8A8_TYPELESS = 27,
  R8G8B8A8_UNORM = 28,
  R8G8B8A8_UNORM_SRGB = 29,
  R8G8B8A8_UINT = 30,
  R8G8B8A8_SNORM = 31,
  R8G8B8A8_SINT = 32,
  R16G16_TYPELESS = 33,
  R16G16_FLOAT = 34,
  R16G16_UNORM = 35,
  R16G16_UINT = 36,
  R16G16_SNORM = 37,
  R16G16_SINT = 38,
  R32_TYPELESS = 39,
  D32_FLOAT = 40,
  R32_FLOAT = 41,
  R32_UINT = 42,
  R32_SINT = 43,
  R24G8_TYPELESS = 44,
  D24_UNORM_S8_UINT = 45,
  R24_UNORM_X8_TYPELESS = 46,
  X24_TYPELESS_G8_UINT = 47,
  R8G8_TYPELESS = 48,
  R8G8_UNORM = 49,
  R8G8_UINT = 50,
  R8G8_SNORM = 51,
  R8G8_SINT = 52,
  R16_TYPELESS = 53,
  R16_FLOAT = 54,
  D16_UNORM = 55,
  R16_UNORM = 56,
  R16_UINT = 57,
  R16_SNORM = 58,
  R16_SINT = 59,
  R8_TYPELESS = 60,
  R8_UNORM = 61,
  R8_UINT = 62,
  R8_SNORM = 63,
  R8_SINT = 64,
  A8_UNORM = 65,
  R1_UNORM = 66,
  R9G9B9E5_SHAREDEXP = 67,
  R8G8_B8G8_UNORM = 68,
  G8R8_G8B8_UNORM = 69,
  BC1_TYPELESS = 70,
  BC1_UNORM = 71,
  BC1_UNORM_SRGB = 72,
  BC2_TYPELESS = 73,
  BC2_UNORM = 74,
  BC2_UNORM_SRGB = 75,
  BC3_TYPELESS = 76,
  BC3_UNORM = 77,
  BC3_UNORM_SRGB = 78,
  BC4_TYPELESS = 79,
  BC4_UNORM = 80,
  BC4_SNORM = 81,
  BC5_TYPELESS = 82,
  BC5_UNORM = 83,
  BC5_SNORM = 84,
  B5G6R5_UNORM = 85,
  B5G5R5A1_UNORM = 86,
  B8G8R8A8_UNORM = 87,
  B8G8R8X8_UNORM = 88,
  R10G10B10_XR_BIAS_A2_UNORM = 89,
  B8G8R8A8_TYPELESS = 90,
  B8G8R8A8_UNORM_SRGB = 91,
  B8G8R8X8_TYPELESS = 92,
  B8G8R8X8_UNORM_SRGB = 93,
  BC6H_TYPELESS = 94,
  BC6H_UF16 = 95,
  BC6H_SF16 = 96,
  BC7_TYPELESS = 97,
  BC7_UNORM = 98,
  BC7_UNORM_SRGB = 99,
  AYUV = 100,
  Y410 = 101,
  Y416 = 102,
  NV12 = 103,
  P010 = 104,
  P016 = 105,
  _420_OPAQUE = 106,
  YUY2 = 107,
  Y210 = 108,
  Y216 = 109,
  NV11 = 110,
  AI44 = 111,
  IA44 = 112,
  P8 = 113,
  A8P8 = 114,
  B4G4R4A4_UNORM = 115,
  P208 = 130,
  V208 = 131,
  V408 = 132,
  SAMPLER_FEEDBACK_MIN_MIP_OPAQUE = 189,
  SAMPLER_FEEDBACK_MIP_REGION_USED_OPAQUE = 190,
}
struct DXGI_RATIONAL {
  u32 Numerator;
  u32 Denominator;
}
enum DXGI_MODE_SCANLINE_ORDER : u32 {
  UNSPECIFIED = 0,
  PROGRESSIVE = 1,
  UPPER_FIELD_FIRST = 2,
  LOWER_FIELD_FIRST = 3,
}
enum DXGI_MODE_SCALING {
  UNSPECIFIED = 0,
  CENTERED = 1,
  STRETCHED = 2
}
struct DXGI_MODE_DESC {
  u32 Width;
  u32 Height;
  DXGI_RATIONAL RefreshRate;
  DXGI_FORMAT Format;
  DXGI_MODE_SCANLINE_ORDER ScanlineOrdering;
  DXGI_MODE_SCALING Scaling;
}
struct DXGI_SAMPLE_DESC {
  u32 Count;
  u32 Quality;
}
enum DXGI_USAGE_FLAGS : u32 {
  SHADER_INPUT = 1 << (0 + 4),
  RENDER_TARGET_OUTPUT = 1 << (1 + 4),
  BACK_BUFFER = 1 << (2 + 4),
  SHARED = 1 << (3 + 4),
  READ_ONLY = 1 << (4 + 4),
  DISCARD_ON_PRESENT = 1 << (5 + 4),
  UNORDERED_ACCESS = 1 << (6 + 4),
}
alias DXGI_USAGE = EnumFlags!DXGI_USAGE_FLAGS;
enum DXGI_SWAP_EFFECT : s32 {
  DISCARD = 0,
  SEQUENTIAL = 1,
  FLIP_SEQUENTIAL = 3,
  FLIP_DISCARD = 4,
}
enum DXGI_SWAP_CHAIN_FLAGS : s32 {
  NONPREROTATED = 1,
  ALLOW_MODE_SWITCH = 2,
  GDI_COMPATIBLE = 4,
  RESTRICTED_CONTENT = 8,
  RESTRICT_SHARED_RESOURCE_DRIVER = 16,
  DISPLAY_ONLY = 32,
  FRAME_LATENCY_WAITABLE_OBJECT = 64,
  FOREGROUND_LAYER = 128,
  FULLSCREEN_VIDEO = 256,
  YUV_VIDEO = 512,
  HW_PROTECTED = 1024,
  ALLOW_TEARING = 2048,
  RESTRICTED_TO_ALL_HOLOGRAPHIC_DISPLAYS = 4096,
}
alias DXGI_SWAP_CHAIN_FLAG = EnumFlags!DXGI_SWAP_CHAIN_FLAGS;
struct DXGI_SWAP_CHAIN_DESC {
  DXGI_MODE_DESC BufferDesc;
  DXGI_SAMPLE_DESC SampleDesc;
  DXGI_USAGE BufferUsage;
  u32 BufferCount;
  HWND OutputWindow;
  s32 Windowed;
  DXGI_SWAP_EFFECT SwapEffect;
  DXGI_SWAP_CHAIN_FLAG Flags;
}
struct IDXGIObject {
  struct VTable {
    IUnknown.VTable iunknown_vtable;
    alias this = iunknown_vtable;
    void* SetPrivateData;
    void* SetPrivateDataInterface;
    void* GetPrivateData;
    void* GetParent;
  }
  mixin COMClass!IUnknown;
}
struct IDXGIDeviceSubObject {
  struct VTable {
    IDXGIObject.VTable idxgiobject_vtable;
    alias this = idxgiobject_vtable;
    void* GetDevice;
  }
  mixin COMClass!IDXGIObject;
}
struct IDXGISwapChain {
  struct VTable {
    IDXGIDeviceSubObject.VTable idxgidevicesubobject_vtable;
    alias this = idxgidevicesubobject_vtable;
    void* Present;
    void* GetBuffer;
    void* SetFullscreenState;
    void* GetFullscreenState;
    void* GetDesc;
    void* ResizeBuffers;
    void* ResizeTarget;
    void* GetContainingOutput;
    void* GetFrameStatistics;
    void* GetLastPresentCount;
  }
  mixin COMClass!IDXGIDeviceSubObject;
}
struct IDXGIAdapter {
  struct VTable {
    IDXGIObject.VTable idxgiobject_vtable;
    alias this = idxgiobject_vtable;
    void* EnumOutputs;
    void* GetDesc;
    void* CheckInterfaceSupport;
  }
  mixin COMClass!IDXGIObject;
}
