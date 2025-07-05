module basic.windows;

import basic;

alias HANDLE = void*;
alias HRESULT = s32;
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
    extern(Windows) HRESULT function(void*, IID*, void**) QueryInterface;
    extern(Windows) u32 function(void*) AddRef;
    extern(Windows) u32 function(void*) Release;
  }
  mixin COMClass;
}

// kernel32
enum STD_INPUT_HANDLE = -10;
enum STD_OUTPUT_HANDLE = -11;
enum STD_ERROR_HANDLE = -12;

struct HINSTANCE__; alias HINSTANCE = HINSTANCE__*;
alias HMODULE = HINSTANCE;

@foreign("kernel32") extern(Windows) HMODULE GetModuleHandleW(const(wchar)*);
@foreign("kernel32") extern(Windows) void Sleep(u32);
@foreign("kernel32") extern(Windows) s32 AllocConsole();
@foreign("kernel32") extern(Windows) HANDLE GetStdHandle(u32);
@foreign("kernel32") extern(Windows) s32 WriteFile(HANDLE, const(void)*, u32, u32*, void*);
@foreign("kernel32") extern(Windows) noreturn ExitProcess(u32);

// user32
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
enum VK_ESCAPE = 0x1B;
enum VK_F4 = 0x73;
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

@foreign("user32") extern(Windows) s32 SetProcessDPIAware();
@foreign("user32") extern(Windows) HICON LoadIconW(HINSTANCE, const(wchar)*);
@foreign("user32") extern(Windows) HCURSOR LoadCursorW(HINSTANCE, const(wchar)*);
@foreign("user32") extern(Windows) u16 RegisterClassExW(const(WNDCLASSEXW)*);
@foreign("user32") extern(Windows) HWND CreateWindowExW(u32, const(wchar)*, const(wchar)*, u32, s32, s32, s32, s32, HWND, HMENU, HINSTANCE, void*);
@foreign("user32") extern(Windows) s32 PeekMessageW(MSG*, HWND, u32, u32, u32);
@foreign("user32") extern(Windows) s32 TranslateMessage(const(MSG)*);
@foreign("user32") extern(Windows) ssize DispatchMessageW(const(MSG)*);
@foreign("user32") extern(Windows) ssize DefWindowProcW(HWND, u32, usize, ssize);
@foreign("user32") extern(Windows) void PostQuitMessage(s32);
@foreign("user32") extern(Windows) HDC GetDC(HWND);
@foreign("user32") extern(Windows) s32 DestroyWindow(HWND);
@foreign("user32") extern(Windows) s32 ClipCursor(const(RECT)*);
@foreign("user32") extern(Windows) s32 ValidateRect(HWND, const(RECT)*);
@foreign("user32") extern(Windows) ssize GetWindowLongPtrW(HWND, s32);
@foreign("user32") extern(Windows) ssize SetWindowLongPtrW(HWND, s32, ssize);
@foreign("user32") extern(Windows) s32 GetWindowPlacement(HWND, WINDOWPLACEMENT*);
@foreign("user32") extern(Windows) s32 SetWindowPlacement(HWND, const(WINDOWPLACEMENT)*);
@foreign("user32") extern(Windows) s32 SetWindowPos(HWND, HWND, s32, s32, s32, s32, u32);
@foreign("user32") extern(Windows) HMONITOR MonitorFromWindow(HWND, u32);
@foreign("user32") extern(Windows) s32 GetMonitorInfoW(HMONITOR, MONITORINFO*);

// gdi32
enum PFD_DOUBLEBUFFER = 0x00000001;
enum PFD_DRAW_TO_WINDOW = 0x00000004;
enum PFD_SUPPORT_OPENGL = 0x00000020;
enum PFD_DEPTH_DONTCARE = 0x20000000;

struct PIXELFORMATDESCRIPTOR {
  u16 nSize;
  u16 nVersion;
  u32 dwFlags;
  u8 iPixelType;
  u8 cColorBits;
  u8 cRedBits;
  u8 cRedShift;
  u8 cGreenBits;
  u8 cGreenShift;
  u8 cBlueBits;
  u8 cBlueShift;
  u8 cAlphaBits;
  u8 cAlphaShift;
  u8 cAccumBits;
  u8 cAccumRedBits;
  u8 cAccumGreenBits;
  u8 cAccumBlueBits;
  u8 cAccumAlphaBits;
  u8 cDepthBits;
  u8 cStencilBits;
  u8 cAuxBuffers;
  u8 iLayerType;
  u8 bReserved;
  u32 dwLayerMask;
  u32 dwVisibleMask;
  u32 dwDamageMask;
}

@foreign("gdi32") extern(Windows) s32 ChoosePixelFormat(HDC, const(PIXELFORMATDESCRIPTOR)*);
@foreign("gdi32") extern(Windows) s32 SetPixelFormat(HDC, s32, const(PIXELFORMATDESCRIPTOR)*);
@foreign("gdi32") extern(Windows) s32 SwapBuffers(HDC);

// opengl32
enum WGL_CONTEXT_MAJOR_VERSION_ARB = 0x2091;
enum WGL_CONTEXT_MINOR_VERSION_ARB = 0x2092;
enum WGL_CONTEXT_FLAGS_ARB = 0x2094;
enum WGL_CONTEXT_PROFILE_MASK_ARB = 0x9126;
enum WGL_CONTEXT_DEBUG_BIT_ARB = 0x0001;
enum WGL_CONTEXT_CORE_PROFILE_BIT_ARB = 0x00000001;

struct HGLRC__; alias HGLRC = HGLRC__*;

@foreign("opengl32") extern(Windows) HGLRC wglCreateContext(HDC);
@foreign("opengl32") extern(Windows) s32 wglDeleteContext(HGLRC);
@foreign("opengl32") extern(Windows) s32 wglMakeCurrent(HDC, HGLRC);
@foreign("opengl32") extern(Windows) PROC wglGetProcAddress(const(char)*);

// ws2_32
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
version (Win64) alias WSADATA = WSADATA64;
else            alias WSADATA = WSADATA32;

@foreign("ws2_32") extern(Windows) s32 WSAStartup(u16, WSADATA*);
@foreign("ws2_32") extern(Windows) s32 WSACleanup();

// dwmapi
enum DWMWA_USE_IMMERSIVE_DARK_MODE = 20;
enum DWMWA_WINDOW_CORNER_PREFERENCE = 33;
enum DWMWCP_DONOTROUND = 1;

@foreign("dwmapi") extern(Windows) HRESULT DwmSetWindowAttribute(HWND, u32, const(void)*, u32);

// winmm
enum TIMERR_NOERROR = 0;

@foreign("winmm") extern(Windows) u32 timeBeginPeriod(u32);

// d3d11
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
enum D3D11_CREATE_DEVICE_FLAG : u32 { // @EnumFlags
  SINGLETHREADED = 0x1,
  DEBUG = 0x2,
  SWITCH_TO_REF = 0x4,
  PREVENT_INTERNAL_THREADING_OPTIMIZATIONS = 0x8,
  BGRA_SUPPORT = 0x20,
  DEBUGGABLE = 0x40,
  PREVENT_ALTERING_LAYER_SETTINGS_FROM_REGISTRY = 0x80,
  DISABLE_GPU_TIMEOUT = 0x100,
  VIDEO_SUPPORT = 0x800
}
enum D3D11_RTV_DIMENSION : s32 {
  UNKNOWN = 0,
  BUFFER = 1,
  TEXTURE1D = 2,
  TEXTURE1DARRAY = 3,
  TEXTURE2D = 4,
  TEXTURE2DARRAY = 5,
  TEXTURE2DMS = 6,
  TEXTURE2DMSARRAY = 7,
  TEXTURE3D = 8,
}
struct D3D11_BUFFER_RTV {
  union {
    u32 FirstElement;
    u32 ElementOffset;
  }
  union {
    u32 NumElements;
    u32 ElementWidth;
  }
}
struct D3D11_TEX1D_RTV {
  u32 MipSlice;
}
struct D3D11_TEX1D_ARRAY_RTV {
  u32 MipSlice;
  u32 FirstArraySlice;
  u32 ArraySize;
}
struct D3D11_TEX2D_RTV {
  u32 MipSlice;
}
struct D3D11_TEX2D_ARRAY_RTV {
  u32 MipSlice;
  u32 FirstArraySlice;
  u32 ArraySize;
}
struct D3D11_TEX2DMS_RTV {
  u32 UnusedField_NothingToDefine;
}
struct D3D11_TEX2DMS_ARRAY_RTV {
  u32 FirstArraySlice;
  u32 ArraySize;
}
struct D3D11_TEX3D_RTV {
  u32 MipSlice;
  u32 FirstWSlice;
  u32 WSize;
}
struct D3D11_RENDER_TARGET_VIEW_DESC {
  DXGI_FORMAT Format;
  D3D11_RTV_DIMENSION ViewDimension;
  union {
    D3D11_BUFFER_RTV Buffer;
    D3D11_TEX1D_RTV Texture1D;
    D3D11_TEX1D_ARRAY_RTV Texture1DArray;
    D3D11_TEX2D_RTV Texture2D;
    D3D11_TEX2D_ARRAY_RTV Texture2DArray;
    D3D11_TEX2DMS_RTV Texture2DMS;
    D3D11_TEX2DMS_ARRAY_RTV Texture2DMSArray;
    D3D11_TEX3D_RTV Texture3D;
  }
}
enum D3D11_DSV_DIMENSION : s32 {
  UNKNOWN = 0,
  TEXTURE1D = 1,
  TEXTURE1DARRAY = 2,
  TEXTURE2D = 3,
  TEXTURE2DARRAY = 4,
  TEXTURE2DMS = 5,
  TEXTURE2DMSARRAY = 6,
}
struct D3D11_TEX1D_DSV {
  u32 MipSlice;
}
struct D3D11_TEX1D_ARRAY_DSV {
  u32 MipSlice;
  u32 FirstArraySlice;
  u32 ArraySize;
}
struct D3D11_TEX2D_DSV {
  u32 MipSlice;
}
struct D3D11_TEX2D_ARRAY_DSV {
  u32 MipSlice;
  u32 FirstArraySlice;
  u32 ArraySize;
}
struct D3D11_TEX2DMS_DSV {
  u32 UnusedField_NothingToDefine;
}
struct D3D11_TEX2DMS_ARRAY_DSV {
  u32 FirstArraySlice;
  u32 ArraySize;
}
struct D3D11_DEPTH_STENCIL_VIEW_DESC {
  DXGI_FORMAT Format;
  D3D11_DSV_DIMENSION ViewDimension;
  u32 Flags;
  union {
    D3D11_TEX1D_DSV Texture1D;
    D3D11_TEX1D_ARRAY_DSV Texture1DArray;
    D3D11_TEX2D_DSV Texture2D;
    D3D11_TEX2D_ARRAY_DSV Texture2DArray;
    D3D11_TEX2DMS_DSV Texture2DMS;
    D3D11_TEX2DMS_ARRAY_DSV Texture2DMSArray;
  }
}
enum D3D11_RESOURCE_DIMENSION : s32 {
  UNKNOWN = 0,
  BUFFER = 1,
  TEXTURE1D = 2,
  TEXTURE2D = 3,
  TEXTURE3D = 4,
}
enum D3D11_PRIMITIVE_TOPOLOGY : s32 {
  UNDEFINED = 0,
  POINTLIST = 1,
  LINELIST = 2,
  LINESTRIP = 3,
  TRIANGLELIST = 4,
  TRIANGLESTRIP = 5,
  LINELIST_ADJ = 10,
  LINESTRIP_ADJ = 11,
  TRIANGLELIST_ADJ = 12,
  TRIANGLESTRIP_ADJ = 13,
  _1_CONTROL_POINT_PATCHLIST = 33,
  _2_CONTROL_POINT_PATCHLIST = 34,
  _3_CONTROL_POINT_PATCHLIST = 35,
  _4_CONTROL_POINT_PATCHLIST = 36,
  _5_CONTROL_POINT_PATCHLIST = 37,
  _6_CONTROL_POINT_PATCHLIST = 38,
  _7_CONTROL_POINT_PATCHLIST = 39,
  _8_CONTROL_POINT_PATCHLIST = 40,
  _9_CONTROL_POINT_PATCHLIST = 41,
  _10_CONTROL_POINT_PATCHLIST = 42,
  _11_CONTROL_POINT_PATCHLIST = 43,
  _12_CONTROL_POINT_PATCHLIST = 44,
  _13_CONTROL_POINT_PATCHLIST = 45,
  _14_CONTROL_POINT_PATCHLIST = 46,
  _15_CONTROL_POINT_PATCHLIST = 47,
  _16_CONTROL_POINT_PATCHLIST = 48,
  _17_CONTROL_POINT_PATCHLIST = 49,
  _18_CONTROL_POINT_PATCHLIST = 50,
  _19_CONTROL_POINT_PATCHLIST = 51,
  _20_CONTROL_POINT_PATCHLIST = 52,
  _21_CONTROL_POINT_PATCHLIST = 53,
  _22_CONTROL_POINT_PATCHLIST = 54,
  _23_CONTROL_POINT_PATCHLIST = 55,
  _24_CONTROL_POINT_PATCHLIST = 56,
  _25_CONTROL_POINT_PATCHLIST = 57,
  _26_CONTROL_POINT_PATCHLIST = 58,
  _27_CONTROL_POINT_PATCHLIST = 59,
  _28_CONTROL_POINT_PATCHLIST = 60,
  _29_CONTROL_POINT_PATCHLIST = 61,
  _30_CONTROL_POINT_PATCHLIST = 62,
  _31_CONTROL_POINT_PATCHLIST = 63,
  _32_CONTROL_POINT_PATCHLIST = 64,
}
enum D3D11_INPUT_CLASSIFICATION : s32 {
  VERTEX_DATA = 0,
  INSTANCE_DATA = 1,
}
struct D3D11_INPUT_ELEMENT_DESC {
  const(char)* SemanticName;
  u32 SemanticIndex;
  DXGI_FORMAT Format;
  u32 InputSlot;
  u32 AlignedByteOffset;
  D3D11_INPUT_CLASSIFICATION InputSlotClass;
  u32 InstanceDataStepRate;
}
struct D3D11_VIEWPORT {
  f32 TopLeftX;
  f32 TopLeftY;
  f32 Width;
  f32 Height;
  f32 MinDepth;
  f32 MaxDepth;
}
enum D3D11_USAGE : s32 {
  DEFAULT = 0,
  IMMUTABLE = 1,
  DYNAMIC = 2,
  STAGING = 3,
}
enum D3D11_BIND_FLAG : u32 { // @EnumFlags
  VERTEX_BUFFER = 0x1,
  INDEX_BUFFER = 0x2,
  CONSTANT_BUFFER = 0x4,
  SHADER_RESOURCE = 0x8,
  STREAM_OUTPUT = 0x10,
  RENDER_TARGET = 0x20,
  DEPTH_STENCIL = 0x40,
  UNORDERED_ACCESS = 0x80,
  DECODER = 0x200,
  VIDEO_ENCODER = 0x400,
}
enum D3D11_CPU_ACCESS_FLAG : u32 { // @EnumFlags
  WRITE = 0x10000,
  READ = 0x20000,
}
struct D3D11_SUBRESOURCE_DATA {
  const(void)* pSysMem;
  u32 SysMemPitch;
  u32 SysMemSlicePitch;
}
struct D3D11_BUFFER_DESC {
  u32 ByteWidth;
  D3D11_USAGE Usage;
  u32 BindFlags;
  u32 CPUAccessFlags;
  u32 MiscFlags;
  u32 StructureByteStride;
}
struct D3D11_TEXTURE2D_DESC {
  u32 Width;
  u32 Height;
  u32 MipLevels;
  u32 ArraySize;
  DXGI_FORMAT Format;
  DXGI_SAMPLE_DESC SampleDesc;
  D3D11_USAGE Usage;
  u32 BindFlags;
  u32 CPUAccessFlags;
  u32 MiscFlags;
}
enum D3D11_CLEAR_FLAG : u32 { // @EnumFlags
  DEPTH = 0x1,
  STENCIL = 0x2,
}
enum D3D11_DEPTH_WRITE_MASK : s32 {
  ZERO = 0,
  ALL = 1,
}
enum D3D11_COMPARISON_FUNC : s32 {
  NEVER = 1,
  LESS = 2,
  EQUAL = 3,
  LESS_EQUAL = 4,
  GREATER = 5,
  NOT_EQUAL = 6,
  GREATER_EQUAL = 7,
  ALWAYS = 8,
}
enum D3D11_STENCIL_OP : s32 {
  KEEP = 1,
  ZERO = 2,
  REPLACE = 3,
  INCR_SAT = 4,
  DECR_SAT = 5,
  INVERT = 6,
  INCR = 7,
  DECR = 8
}
struct D3D11_DEPTH_STENCILOP_DESC {
  D3D11_STENCIL_OP StencilFailOp;
  D3D11_STENCIL_OP StencilDepthFailOp;
  D3D11_STENCIL_OP StencilPassOp;
  D3D11_COMPARISON_FUNC StencilFunc;
}
struct D3D11_DEPTH_STENCIL_DESC {
  s32 DepthEnable;
  D3D11_DEPTH_WRITE_MASK DepthWriteMask;
  D3D11_COMPARISON_FUNC DepthFunc;
  s32 StencilEnable;
  u8 StencilReadMask;
  u8 StencilWriteMask;
  D3D11_DEPTH_STENCILOP_DESC FrontFace;
  D3D11_DEPTH_STENCILOP_DESC BackFace;
}
enum D3D11_MAP : s32 {
  READ = 1,
  WRITE = 2,
  READ_WRITE = 3,
  WRITE_DISCARD = 4,
  WRITE_NO_OVERWRITE = 5,
}
struct D3D11_MAPPED_SUBRESOURCE {
  void* pData;
  u32 RowPitch;
  u32 DepthPitch;
}
struct ID3DBlob {
  struct VTable {
    IUnknown.VTable iunknown_vtable;
    alias this = iunknown_vtable;
    extern(Windows) void* function(void*) GetBufferPointer;
    extern(Windows) usize function(void*) GetBufferSize;
  }
  mixin COMClass;
}
struct ID3D11Device {
  struct VTable {
    IUnknown.VTable iunknown_vtable;
    alias this = iunknown_vtable;
    extern(Windows) HRESULT function(void*, const(D3D11_BUFFER_DESC)*, const(D3D11_SUBRESOURCE_DATA)*, ID3D11Buffer**) CreateBuffer;
    extern(Windows) void function(void*) CreateTexture1D;
    extern(Windows) HRESULT function(void*, const(D3D11_TEXTURE2D_DESC)*, const(D3D11_SUBRESOURCE_DATA)*, ID3D11Texture2D**) CreateTexture2D;
    extern(Windows) void function(void*) CreateTexture3D;
    extern(Windows) void function(void*) CreateShaderResourceView;
    extern(Windows) void function(void*) CreateUnorderedAccessView;
    extern(Windows) HRESULT function(void*, ID3D11Resource*, const(D3D11_RENDER_TARGET_VIEW_DESC)*, ID3D11RenderTargetView**) CreateRenderTargetView;
    extern(Windows) HRESULT function(void*, ID3D11Resource*, const(D3D11_DEPTH_STENCIL_VIEW_DESC)*, ID3D11DepthStencilView**) CreateDepthStencilView;
    extern(Windows) HRESULT function(void*, const(D3D11_INPUT_ELEMENT_DESC)*, u32, const(void)*, usize, ID3D11InputLayout**) CreateInputLayout;
    extern(Windows) HRESULT function(void*, const(void)*, usize, ID3D11ClassLinkage*, ID3D11VertexShader**) CreateVertexShader;
    extern(Windows) void function(void*) CreateGeometryShader;
    extern(Windows) void function(void*) CreateGeometryShaderWithStreamOutput;
    extern(Windows) HRESULT function(void*, const(void)*, usize, ID3D11ClassLinkage*, ID3D11PixelShader**) CreatePixelShader;
    extern(Windows) void function(void*) CreateHullShader;
    extern(Windows) void function(void*) CreateDomainShader;
    extern(Windows) void function(void*) CreateComputeShader;
    extern(Windows) void function(void*) CreateClassLinkage;
    extern(Windows) void function(void*) CreateBlendState;
    extern(Windows) HRESULT function(void*, const(D3D11_DEPTH_STENCIL_DESC)*, ID3D11DepthStencilState**) CreateDepthStencilState;
    extern(Windows) void function(void*) CreateRasterizerState;
    extern(Windows) void function(void*) CreateSamplerState;
    extern(Windows) void function(void*) CreateQuery;
    extern(Windows) void function(void*) CreatePredicate;
    extern(Windows) void function(void*) CreateCounter;
    extern(Windows) void function(void*) CreateDeferredContext;
    extern(Windows) void function(void*) OpenSharedResource;
    extern(Windows) void function(void*) CheckFormatSupport;
    extern(Windows) void function(void*) CheckMultisampleQualityLevels;
    extern(Windows) void function(void*) CheckCounterInfo;
    extern(Windows) void function(void*) CheckCounter;
    extern(Windows) void function(void*) CheckFeatureSupport;
    extern(Windows) void function(void*) GetPrivateData;
    extern(Windows) void function(void*) SetPrivateData;
    extern(Windows) void function(void*) SetPrivateDataInterface;
    extern(Windows) void function(void*) GetFeatureLevel;
    extern(Windows) void function(void*) GetCreationFlags;
    extern(Windows) void function(void*) GetDeviceRemovedReason;
    extern(Windows) void function(void*) GetImmediateContext;
    extern(Windows) void function(void*) SetExceptionMode;
    extern(Windows) void function(void*) GetExceptionMode;
  }
  mixin COMClass;
}
struct ID3D11DeviceChild {
  struct VTable {
    IUnknown.VTable iunknown_vtable;
    alias this = iunknown_vtable;
    extern(Windows) void function(void*) GetDevice;
    extern(Windows) void function(void*) GetPrivateData;
    extern(Windows) void function(void*) SetPrivateData;
    extern(Windows) void function(void*) SetPrivateDataInterface;
  }
  mixin COMClass;
}
struct ID3D11Resource {
  struct VTable {
    ID3D11DeviceChild.VTable id3d11devicechild_vtable;
    alias this = id3d11devicechild_vtable;
    extern(Windows) void function (D3D11_RESOURCE_DIMENSION*) GetType;
    extern(Windows) void function(void*, u32) SetEvictionPriority;
    extern(Windows) u32 function(void*) GetEvictionPriority;
  }
  mixin COMClass;
}
struct ID3D11Buffer {
  struct VTable {
    ID3D11Resource.VTable id3d11resource_vtable;
    alias this = id3d11resource_vtable;
    extern(Windows) void function(void*) GetDesc;
  }
  mixin COMClass;
}
struct ID3D11Texture2D {
  __gshared immutable uuidof = IID(0x6F15AAF2, 0xD208, 0x4E89, [0x9A, 0xB4, 0x48, 0x95, 0x35, 0xD3, 0x4F, 0x9C]);
  struct VTable {
    ID3D11Resource.VTable id3d11resource_vtable;
    alias this = id3d11resource_vtable;
    extern(Windows) void function(void*) GetDesc;
  }
  mixin COMClass;
}
struct ID3D11DepthStencilState {
  struct VTable {
    ID3D11Resource.VTable id3d11resource_vtable;
    alias this = id3d11resource_vtable;
    extern(Windows) void function(void*) GetDesc;
  }
  mixin COMClass;
}
struct ID3D11View {
  struct VTable {
    ID3D11DeviceChild.VTable id3d11devicechild_vtable;
    alias this = id3d11devicechild_vtable;
    extern(Windows) void function(void*, ID3D11Resource**) GetResource;
  }
  mixin COMClass;
}
struct ID3D11RenderTargetView {
  struct VTable {
    ID3D11View.VTable id3d11view_vtable;
    alias this = id3d11view_vtable;
    extern(Windows) void function(void*, D3D11_RENDER_TARGET_VIEW_DESC*) GetDesc;
  }
  mixin COMClass;
}
struct ID3D11DepthStencilView {
  struct VTable {
    ID3D11View.VTable id3d11view_vtable;
    alias this = id3d11view_vtable;
    extern(Windows) void function(void*) GetDesc;
  }
  mixin COMClass;
}
struct ID3D11ClassLinkage {
  struct VTable {
    ID3D11DeviceChild.VTable id3d11devicechild_vtable;
    alias this = id3d11devicechild_vtable;
    // ...
  }
  mixin COMClass;
}
struct ID3D11ClassInstance {
  struct VTable {
    ID3D11DeviceChild.VTable id3d11devicechild_vtable;
    alias this = id3d11devicechild_vtable;
    // ...
  }
  mixin COMClass;
}
struct ID3D11VertexShader {
  struct VTable {
    ID3D11DeviceChild.VTable id3d11devicechild_vtable;
    alias this = id3d11devicechild_vtable;
  }
  mixin COMClass;
}
struct ID3D11PixelShader {
  struct VTable {
    ID3D11DeviceChild.VTable id3d11devicechild_vtable;
    alias this = id3d11devicechild_vtable;
  }
  mixin COMClass;
}
struct ID3D11InputLayout {
  struct VTable {
    ID3D11DeviceChild.VTable id3d11devicechild_vtable;
    alias this = id3d11devicechild_vtable;
  }
  mixin COMClass;
}
struct ID3D11DeviceContext {
  struct VTable {
    ID3D11DeviceChild.VTable id3d11devicechild_vtable;
    alias this = id3d11devicechild_vtable;
    extern(Windows) void function(void*) VSSetConstantBuffers;
    extern(Windows) void function(void*) PSSetShaderResources;
    extern(Windows) void function(void*, ID3D11PixelShader*, const(ID3D11ClassInstance*)*, u32) PSSetShader;
    extern(Windows) void function(void*) PSSetSamplers;
    extern(Windows) void function(void*, ID3D11VertexShader*, const(ID3D11ClassInstance*)*, u32) VSSetShader;
    extern(Windows) void function(void*, u32, u32, s32) DrawIndexed;
    extern(Windows) void function(void*, u32, u32) Draw;
    extern(Windows) HRESULT function(void*, ID3D11Resource*, u32, D3D11_MAP, u32, D3D11_MAPPED_SUBRESOURCE*) Map;
    extern(Windows) void function(void*, ID3D11Resource*, u32) Unmap;
    extern(Windows) void function(void*) PSSetConstantBuffers;
    extern(Windows) void function(void*, ID3D11InputLayout*) IASetInputLayout;
    extern(Windows) void function(void*, u32, u32, const(ID3D11Buffer*)*, const(u32)*, const(u32)*) IASetVertexBuffers;
    extern(Windows) void function(void*, ID3D11Buffer*, DXGI_FORMAT, u32) IASetIndexBuffer;
    extern(Windows) void function(void*, u32, u32, u32, s32, u32) DrawIndexedInstanced;
    extern(Windows) void function(void*) DrawInstanced;
    extern(Windows) void function(void*) GSSetConstantBuffers;
    extern(Windows) void function(void*) GSSetShader;
    extern(Windows) void function(void*, D3D11_PRIMITIVE_TOPOLOGY) IASetPrimitiveTopology;
    extern(Windows) void function(void*) VSSetShaderResources;
    extern(Windows) void function(void*) VSSetSamplers;
    extern(Windows) void function(void*) Begin;
    extern(Windows) void function(void*) End;
    extern(Windows) void function(void*) GetData;
    extern(Windows) void function(void*) SetPredication;
    extern(Windows) void function(void*) GSSetShaderResources;
    extern(Windows) void function(void*) GSSetSamplers;
    extern(Windows) void function(void*, u32, const(ID3D11RenderTargetView*)*, ID3D11DepthStencilView*) OMSetRenderTargets;
    extern(Windows) void function(void*) OMSetRenderTargetsAndUnorderedAccessViews;
    extern(Windows) void function(void*) OMSetBlendState;
    extern(Windows) void function(void*, ID3D11DepthStencilState*, u32) OMSetDepthStencilState;
    extern(Windows) void function(void*) SOSetTargets;
    extern(Windows) void function(void*) DrawAuto;
    extern(Windows) void function(void*) DrawIndexedInstancedIndirect;
    extern(Windows) void function(void*) DrawInstancedIndirect;
    extern(Windows) void function(void*) Dispatch;
    extern(Windows) void function(void*) DispatchIndirect;
    extern(Windows) void function(void*) RSSetState;
    extern(Windows) void function(void*, u32, const(D3D11_VIEWPORT)*) RSSetViewports;
    extern(Windows) void function(void*) RSSetScissorRects;
    extern(Windows) void function(void*) CopySubresourceRegion;
    extern(Windows) void function(void*) CopyResource;
    extern(Windows) void function(void*) UpdateSubresource;
    extern(Windows) void function(void*) CopyStructureCount;
    extern(Windows) void function(void*, ID3D11RenderTargetView*, const(float)*) ClearRenderTargetView;
    extern(Windows) void function(void*) ClearUnorderedAccessViewUint;
    extern(Windows) void function(void*) ClearUnorderedAccessViewFloat;
    extern(Windows) void function(void*, ID3D11DepthStencilView*, u32, f32, u8) ClearDepthStencilView;
    extern(Windows) void function(void*) GenerateMips;
    extern(Windows) void function(void*) SetResourceMinLOD;
    extern(Windows) void function(void*) GetResourceMinLOD;
    extern(Windows) void function(void*) ResolveSubresource;
    extern(Windows) void function(void*) ExecuteCommandList;
    extern(Windows) void function(void*) HSSetShaderResources;
    extern(Windows) void function(void*) HSSetShader;
    extern(Windows) void function(void*) HSSetSamplers;
    extern(Windows) void function(void*) HSSetConstantBuffers;
    extern(Windows) void function(void*) DSSetShaderResources;
    extern(Windows) void function(void*) DSSetShader;
    extern(Windows) void function(void*) DSSetSamplers;
    extern(Windows) void function(void*) DSSetConstantBuffers;
    extern(Windows) void function(void*) CSSetShaderResources;
    extern(Windows) void function(void*) CSSetUnorderedAccessViews;
    extern(Windows) void function(void*) CSSetShader;
    extern(Windows) void function(void*) CSSetSamplers;
    extern(Windows) void function(void*) CSSetConstantBuffers;
    extern(Windows) void function(void*) VSGetConstantBuffers;
    extern(Windows) void function(void*) PSGetShaderResources;
    extern(Windows) void function(void*) PSGetShader;
    extern(Windows) void function(void*) PSGetSamplers;
    extern(Windows) void function(void*) VSGetShader;
    extern(Windows) void function(void*) PSGetConstantBuffers;
    extern(Windows) void function(void*) IAGetInputLayout;
    extern(Windows) void function(void*) IAGetVertexBuffers;
    extern(Windows) void function(void*) IAGetIndexBuffer;
    extern(Windows) void function(void*) GSGetConstantBuffers;
    extern(Windows) void function(void*) GSGetShader;
    extern(Windows) void function(void*) IAGetPrimitiveTopology;
    extern(Windows) void function(void*) VSGetShaderResources;
    extern(Windows) void function(void*) VSGetSamplers;
    extern(Windows) void function(void*) GetPredication;
    extern(Windows) void function(void*) GSGetShaderResources;
    extern(Windows) void function(void*) GSGetSamplers;
    extern(Windows) void function(void*) OMGetRenderTargets;
    extern(Windows) void function(void*) OMGetRenderTargetsAndUnorderedAccessViews;
    extern(Windows) void function(void*) OMGetBlendState;
    extern(Windows) void function(void*) OMGetDepthStencilState;
    extern(Windows) void function(void*) SOGetTargets;
    extern(Windows) void function(void*) RSGetState;
    extern(Windows) void function(void*) RSGetViewports;
    extern(Windows) void function(void*) RSGetScissorRects;
    extern(Windows) void function(void*) HSGetShaderResources;
    extern(Windows) void function(void*) HSGetShader;
    extern(Windows) void function(void*) HSGetSamplers;
    extern(Windows) void function(void*) HSGetConstantBuffers;
    extern(Windows) void function(void*) DSGetShaderResources;
    extern(Windows) void function(void*) DSGetShader;
    extern(Windows) void function(void*) DSGetSamplers;
    extern(Windows) void function(void*) DSGetConstantBuffers;
    extern(Windows) void function(void*) CSGetShaderResources;
    extern(Windows) void function(void*) CSGetUnorderedAccessViews;
    extern(Windows) void function(void*) CSGetShader;
    extern(Windows) void function(void*) CSGetSamplers;
    extern(Windows) void function(void*) CSGetConstantBuffers;
    extern(Windows) void function(void*) ClearState;
    extern(Windows) void function(void*) Flush;
    extern(Windows) void function(void*) GetType;
    extern(Windows) void function(void*) GetContextFlags;
    extern(Windows) void function(void*) FinishCommandList;
  }
  mixin COMClass;
}

@foreign("d3d11") extern(Windows) HRESULT D3D11CreateDeviceAndSwapChain(IDXGIAdapter*, D3D_DRIVER_TYPE, HMODULE, uint, const(D3D_FEATURE_LEVEL)*, uint, uint, const(DXGI_SWAP_CHAIN_DESC)*, IDXGISwapChain**, ID3D11Device**, D3D_FEATURE_LEVEL*, ID3D11DeviceContext**);

// dxgi
enum DXGI_CPU_ACCESS_NONE = 0; // @EnumFlags
enum DXGI_CPU_ACCESS_DYNAMIC = 1;
enum DXGI_CPU_ACCESS_READ_WRITE = 2;
enum DXGI_CPU_ACCESS_SCRATCH = 3;
enum DXGI_CPU_ACCESS_FIELD = 15;
enum DXGI_USAGE_SHADER_INPUT = 1 << (0 + 4);
enum DXGI_USAGE_RENDER_TARGET_OUTPUT = 1 << (1 + 4);
enum DXGI_USAGE_BACK_BUFFER = 1 << (2 + 4);
enum DXGI_USAGE_SHARED = 1 << (3 + 4);
enum DXGI_USAGE_READ_ONLY = 1 << (4 + 4);
enum DXGI_USAGE_DISCARD_ON_PRESENT = 1 << (5 + 4);
enum DXGI_USAGE_UNORDERED_ACCESS = 1 << (6 + 4);

struct DXGI_RATIONAL {
  u32 Numerator;
  u32 Denominator;
}
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
enum DXGI_MODE_SCANLINE_ORDER : s32 {
  UNSPECIFIED = 0,
  PROGRESSIVE = 1,
  UPPER_FIELD_FIRST = 2,
  LOWER_FIELD_FIRST = 3,
}
enum DXGI_MODE_SCALING : s32 {
  UNSPECIFIED = 0,
  CENTERED = 1,
  STRETCHED = 2,
}
struct DXGI_SAMPLE_DESC {
  u32 Count;
  u32 Quality;
}
struct DXGI_MODE_DESC {
  u32 Width;
  u32 Height;
  DXGI_RATIONAL RefreshRate;
  DXGI_FORMAT Format;
  DXGI_MODE_SCANLINE_ORDER ScanlineOrdering;
  DXGI_MODE_SCALING Scaling;
}
alias DXGI_USAGE = u32;
enum DXGI_SWAP_EFFECT : s32 {
  DISCARD = 0,
  SEQUENTIAL = 1,
  FLIP_SEQUENTIAL = 3,
  FLIP_DISCARD = 4,
}
struct DXGI_SWAP_CHAIN_DESC {
  DXGI_MODE_DESC BufferDesc;
  DXGI_SAMPLE_DESC SampleDesc;
  DXGI_USAGE BufferUsage;
  u32 BufferCount;
  HWND OutputWindow;
  s32 Windowed;
  DXGI_SWAP_EFFECT SwapEffect;
  u32 Flags;
}
enum DXGI_SWAP_CHAIN_FLAG : u32 { // @EnumFlags
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
enum DXGI_MWA : u32 { // @EnumFlags
  NO_WINDOW_CHANGES = 0,
  NO_ALT_ENTER = 1,
  NO_PRINT_SCREEN = 2,
}
struct IDXGIObject {
  struct VTable {
    IUnknown.VTable iunknown_vtable;
    alias this = iunknown_vtable;
    extern(Windows) HRESULT function(void*, GUID*, u32, const(void)*) SetPrivateData;
    extern(Windows) HRESULT function(void*, GUID*, const(IUnknown)*) SetPrivateDataInterface;
    extern(Windows) HRESULT function(void*, GUID*, u32*, void*) GetPrivateData;
    extern(Windows) HRESULT function(void*, IID*, void**) GetParent;
  }
  mixin COMClass;
}
struct IDXGIAdapter {
  struct VTable {
    IDXGIObject.VTable idxgiobject_vtable;
    alias this = idxgiobject_vtable;
    // ...
  }
  mixin COMClass;
}
struct IDXGIFactory {
  __gshared immutable uuidof = IID(0x7B7166EC, 0x21C7, 0x44AE, [0xB2, 0x1A, 0xC9, 0xAE, 0x32, 0x1A, 0xE3, 0x69]);
  struct VTable {
    IDXGIObject.VTable idxgiobject_vtable;
    alias this = idxgiobject_vtable;
    extern(Windows) void function(void*) EnumAdapters;
    extern(Windows) HRESULT function(void*, HWND, u32) MakeWindowAssociation;
    extern(Windows) void function(void*) GetWindowAssociation;
    extern(Windows) void function(void*) CreateSwapChain;
    extern(Windows) void function(void*) CreateSoftwareAdapter;
  }
  mixin COMClass;
}
struct IDXGIDevice {
  __gshared immutable uuidof = IID(0x54EC77FA, 0x1377, 0x44E6, [0x8C, 0x32, 0x88, 0xFD, 0x5F, 0x44, 0xC8, 0x4C]);
  struct VTable {
    IDXGIObject.VTable idxgiobject_vtable;
    alias this = idxgiobject_vtable;
    extern(Windows) HRESULT function(void*, IDXGIAdapter**) GetAdapter;
    extern(Windows) void function(void*) CreateSurface;
    extern(Windows) void function(void*) QueryResourceResidency;
    extern(Windows) void function(void*) SetGPUThreadPriority;
    extern(Windows) void function(void*) GetGPUThreadPriority;
  }
  mixin COMClass;
}
struct IDXGIDeviceSubObject {
  struct VTable {
    IDXGIObject.VTable idxgiobject_vtable;
    alias this = idxgiobject_vtable;
    extern(Windows) HRESULT function(void*, IID*, void**) GetDevice;
  }
  mixin COMClass;
}
struct IDXGISwapChain {
  struct VTable {
    IDXGIDeviceSubObject.VTable idxgidevicesubobject_vtable;
    alias this = idxgidevicesubobject_vtable;
    extern(Windows) HRESULT function(void*, u32, u32) Present;
    extern(Windows) HRESULT function(void*, u32, IID*, void**) GetBuffer;
    extern(Windows) void function(void*) SetFullscreenState;
    extern(Windows) void function(void*) GetFullscreenState;
    extern(Windows) void function(void*) GetDesc;
    extern(Windows) HRESULT function(void*, u32, u32, u32, DXGI_FORMAT, u32) ResizeBuffers;
    extern(Windows) void function(void*) ResizeTarget;
    extern(Windows) void function(void*) GetContainingOutput;
    extern(Windows) void function(void*) GetFrameStatistics;
    extern(Windows) void function(void*) GetLastPresentCount;
  }
  mixin COMClass;
}

// d3dcompiler
enum D3DCOMPILE : s32 {
  DEBUG = 0,
  SKIP_VALIDATION = 1,
  SKIP_OPTIMIZATION = 2,
  PACK_MATRIX_ROW_MAJOR = 3,
  PACK_MATRIX_COLUMN_MAJOR = 4,
  PARTIAL_PRECISION = 5,
  FORCE_VS_SOFTWARE_NO_OPT = 6,
  FORCE_PS_SOFTWARE_NO_OPT = 7,
  NO_PRESHADER = 8,
  AVOID_FLOW_CONTROL = 9,
  PREFER_FLOW_CONTROL = 10,
  ENABLE_STRICTNESS = 11,
  ENABLE_BACKWARDS_COMPATIBILITY = 12,
  IEEE_STRICTNESS = 13,
  OPTIMIZATION_LEVEL0 = 14,
  OPTIMIZATION_LEVEL3 = 15,
  RESERVED16 = 16,
  RESERVED17 = 17,
  WARNINGS_ARE_ERRORS = 18,
  RESOURCES_MAY_ALIAS = 19,
  ENABLE_UNBOUNDED_DESCRIPTOR_TABLES = 20,
  ALL_RESOURCES_BOUND = 21,
  DEBUG_NAME_FOR_SOURCE = 22,
  DEBUG_NAME_FOR_BINARY = 23,
}
struct D3D_SHADER_MACRO {
  const(char)* Name;
  const(char)* Definition;
}
struct ID3DInclude {
  struct VTable {
    extern(Windows) void function(void*) Open;
    extern(Windows) void function(void*) Close;
  }
  mixin COMClass;
}

@foreign("d3dcompiler") extern(Windows) HRESULT D3DCompile(const(void)*, usize, const(char)*, const(D3D_SHADER_MACRO)*, ID3DInclude*, const(char)*, const(char)*, u32, u32, ID3DBlob**, ID3DBlob**);
