module basic.windows;

import basic : COMClass, foreign;

alias HANDLE = void*;
alias HRESULT = int;
struct GUID {
  uint Data1;
  ushort Data2;
  ushort Data3;
  ubyte[8] Data4;
}
alias IID = const(GUID);
struct IUnknown {
  struct VTable {
    extern(Windows) HRESULT function(void*, IID*, void**) QueryInterface;
    extern(Windows) uint function(void*) AddRef;
    extern(Windows) uint function(void*) Release;
  }
  mixin COMClass;
}

// kernel32
enum STD_OUTPUT_HANDLE = -11;
enum STD_ERROR_HANDLE = -12;

struct HINSTANCE__; alias HINSTANCE = HINSTANCE__*;
alias HMODULE = HINSTANCE;
alias PROC = extern(Windows) ptrdiff_t function();

@foreign("kernel32") extern(Windows) HMODULE GetModuleHandleW(const(wchar)*);
@foreign("kernel32") extern(Windows) PROC GetProcAddress(HMODULE, const(char)*);
@foreign("kernel32") extern(Windows) void Sleep(uint);
@foreign("kernel32") extern(Windows) int AllocConsole();
@foreign("kernel32") extern(Windows) HANDLE GetStdHandle(uint);
@foreign("kernel32") extern(Windows) int WriteFile(HANDLE, const(void)*, uint, uint*, void*);
@foreign("kernel32") extern(Windows) noreturn ExitProcess(uint);

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
enum MONITOR_DEFAULTTOPRIMARY = 1;
enum GWL_STYLE = -16;
enum HWND_TOP = cast(HWND) 0;
enum SWP_NOSIZE = 0x0001;
enum SWP_NOMOVE = 0x0002;
enum SWP_NOZORDER = 0x0004;
enum SWP_FRAMECHANGED = 0x0020;
enum SC_KEYMENU = 0xF100;
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
alias WNDPROC = extern(Windows) ptrdiff_t function(HWND, uint, size_t, ptrdiff_t);
struct POINT {
  int x;
  int y;
}
struct RECT {
  int left;
  int top;
  int right;
  int bottom;
}
struct WNDCLASSEXW {
  uint cbSize;
  uint style;
  WNDPROC lpfnWndProc;
  int cbClsExtra;
  int cbWndExtra;
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
  uint message;
  size_t wParam;
  ptrdiff_t lParam;
  uint time;
  POINT pt;
  uint lPrivate;
}
struct WINDOWPLACEMENT {
  uint length;
  uint flags;
  uint showCmd;
  POINT ptMinPosition;
  POINT ptMaxPosition;
  RECT rcNormalPosition;
  RECT rcDevice;
}
struct MONITORINFO {
  uint cbSize;
  RECT rcMonitor;
  RECT rcWork;
  uint dwFlags;
}

@foreign("user32") extern(Windows) int SetProcessDPIAware();
@foreign("user32") extern(Windows) HICON LoadIconW(HINSTANCE, const(wchar)*);
@foreign("user32") extern(Windows) HCURSOR LoadCursorW(HINSTANCE, const(wchar)*);
@foreign("user32") extern(Windows) ushort RegisterClassExW(const(WNDCLASSEXW)*);
@foreign("user32") extern(Windows) HWND CreateWindowExW(uint, const(wchar)*, const(wchar)*, uint, int, int, int, int, HWND, HMENU, HINSTANCE, void*);
@foreign("user32") extern(Windows) int PeekMessageW(MSG*, HWND, uint, uint, uint);
@foreign("user32") extern(Windows) int TranslateMessage(const(MSG)*);
@foreign("user32") extern(Windows) ptrdiff_t DispatchMessageW(const(MSG)*);
@foreign("user32") extern(Windows) ptrdiff_t DefWindowProcW(HWND, uint, size_t, ptrdiff_t);
@foreign("user32") extern(Windows) HDC GetDC(HWND);
@foreign("user32") extern(Windows) int DestroyWindow(HWND);
@foreign("user32") extern(Windows) int ValidateRect(HWND, const(RECT)*);
@foreign("user32") extern(Windows) void PostQuitMessage(int);
@foreign("user32") extern(Windows) int ClipCursor(const(RECT)*);
@foreign("user32") extern(Windows) ptrdiff_t GetWindowLongPtrW(HWND, int);
@foreign("user32") extern(Windows) ptrdiff_t SetWindowLongPtrW(HWND, int, ptrdiff_t);
@foreign("user32") extern(Windows) int SetWindowPos(HWND, HWND, int, int, int, int, uint);
@foreign("user32") extern(Windows) int GetWindowPlacement(HWND, WINDOWPLACEMENT*);
@foreign("user32") extern(Windows) int SetWindowPlacement(HWND, const(WINDOWPLACEMENT)*);
@foreign("user32") extern(Windows) HMONITOR MonitorFromWindow(HWND, uint);
@foreign("user32") extern(Windows) int GetMonitorInfoW(HMONITOR, MONITORINFO*);

// gdi32
enum PFD_DOUBLEBUFFER = 0x00000001;
enum PFD_DRAW_TO_WINDOW = 0x00000004;
enum PFD_SUPPORT_OPENGL = 0x00000020;
enum PFD_DEPTH_DONTCARE = 0x20000000;

struct PIXELFORMATDESCRIPTOR {
  ushort nSize;
  ushort nVersion;
  uint dwFlags;
  ubyte iPixelType;
  ubyte cColorBits;
  ubyte cRedBits;
  ubyte cRedShift;
  ubyte cGreenBits;
  ubyte cGreenShift;
  ubyte cBlueBits;
  ubyte cBlueShift;
  ubyte cAlphaBits;
  ubyte cAlphaShift;
  ubyte cAccumBits;
  ubyte cAccumRedBits;
  ubyte cAccumGreenBits;
  ubyte cAccumBlueBits;
  ubyte cAccumAlphaBits;
  ubyte cDepthBits;
  ubyte cStencilBits;
  ubyte cAuxBuffers;
  ubyte iLayerType;
  ubyte bReserved;
  uint dwLayerMask;
  uint dwVisibleMask;
  uint dwDamageMask;
}

@foreign("gdi32") extern(Windows) int ChoosePixelFormat(HDC, const(PIXELFORMATDESCRIPTOR)*);
@foreign("gdi32") extern(Windows) int SetPixelFormat(HDC, int, const(PIXELFORMATDESCRIPTOR)*);
@foreign("gdi32") extern(Windows) int SwapBuffers(HDC);

// opengl32
enum WGL_CONTEXT_MAJOR_VERSION_ARB = 0x2091;
enum WGL_CONTEXT_MINOR_VERSION_ARB = 0x2092;
enum WGL_CONTEXT_FLAGS_ARB = 0x2094;
enum WGL_CONTEXT_PROFILE_MASK_ARB = 0x9126;
enum WGL_CONTEXT_DEBUG_BIT_ARB = 0x0001;
enum WGL_CONTEXT_CORE_PROFILE_BIT_ARB = 0x00000001;

struct HGLRC__; alias HGLRC = HGLRC__*;

@foreign("opengl32") extern(Windows) HGLRC wglCreateContext(HDC);
@foreign("opengl32") extern(Windows) int wglDeleteContext(HGLRC);
@foreign("opengl32") extern(Windows) int wglMakeCurrent(HDC, HGLRC);
@foreign("opengl32") extern(Windows) PROC wglGetProcAddress(const(char)*);

// ws2_32
enum WSADESCRIPTION_LEN = 256;
enum WSASYS_STATUS_LEN = 128;

struct WSADATA32 {
  ushort wVersion;
  ushort wHighVersion;
  char[WSADESCRIPTION_LEN + 1] szDescription;
  char[WSASYS_STATUS_LEN + 1] szSystemStatus;
  ushort iMaxSockets;
  ushort iMaxUdpDg;
  char* lpVendorInfo;
}
struct WSADATA64 {
  ushort wVersion;
  ushort wHighVersion;
  ushort iMaxSockets;
  ushort iMaxUdpDg;
  char* lpVendorInfo;
  char[WSADESCRIPTION_LEN + 1] szDescription;
  char[WSASYS_STATUS_LEN + 1] szSystemStatus;
}
version (Win32) alias WSADATA = WSADATA32;
version (Win64) alias WSADATA = WSADATA64;

@foreign("ws2_32") extern(Windows) int WSAStartup(ushort, WSADATA*);
@foreign("ws2_32") extern(Windows) int WSACleanup();

// dwmapi
enum DWMWA_USE_IMMERSIVE_DARK_MODE = 20;
enum DWMWA_WINDOW_CORNER_PREFERENCE = 33;
enum DWMWCP_DONOTROUND = 1;

@foreign("dwmapi") extern(Windows) HRESULT DwmSetWindowAttribute(HWND, uint, const(void)*, uint);

// winmm
enum TIMERR_NOERROR = 0;

@foreign("winmm") extern(Windows) uint timeBeginPeriod(uint);

// d3d11
enum D3D11_SDK_VERSION = 7;

enum D3D_DRIVER_TYPE : int {
  UNKNOWN = 0,
  HARDWARE = 1,
  REFERENCE = 2,
  NULL = 3,
  SOFTWARE = 4,
  WARP = 5,
}
enum D3D_FEATURE_LEVEL : int {
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
enum D3D11_CREATE_DEVICE_FLAG : int {
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
enum D3D11_RTV_DIMENSION : int {
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
    uint FirstElement;
    uint ElementOffset;
  }
  union {
    uint NumElements;
    uint ElementWidth;
  }
}
struct D3D11_TEX1D_RTV {
  uint MipSlice;
}
struct D3D11_TEX1D_ARRAY_RTV {
  uint MipSlice;
  uint FirstArraySlice;
  uint ArraySize;
}
struct D3D11_TEX2D_RTV {
  uint MipSlice;
}
struct D3D11_TEX2D_ARRAY_RTV {
  uint MipSlice;
  uint FirstArraySlice;
  uint ArraySize;
}
struct D3D11_TEX2DMS_RTV {
  uint UnusedField_NothingToDefine;
}
struct D3D11_TEX2DMS_ARRAY_RTV {
  uint FirstArraySlice;
  uint ArraySize;
}
struct D3D11_TEX3D_RTV {
  uint MipSlice;
  uint FirstWSlice;
  uint WSize;
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
enum D3D11_RESOURCE_DIMENSION : int {
  UNKNOWN = 0,
  BUFFER = 1,
  TEXTURE1D = 2,
  TEXTURE2D = 3,
  TEXTURE3D = 4,
}
enum D3D11_USAGE : int {
  DEFAULT = 0,
  IMMUTABLE = 1,
  DYNAMIC = 2,
  STAGING = 3,
}
struct D3D11_TEXTURE2D_DESC {
  uint Width;
  uint Height;
  uint MipLevels;
  uint ArraySize;
  DXGI_FORMAT Format;
  DXGI_SAMPLE_DESC SampleDesc;
  D3D11_USAGE Usage;
  uint BindFlags;
  uint CPUAccessFlags;
  uint MiscFlags;
}
enum D3D11_PRIMITIVE_TOPOLOGY : int {
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
enum D3D11_BIND_FLAG : int {
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
struct D3D11_BUFFER_DESC {
  uint ByteWidth;
  D3D11_USAGE Usage;
  uint BindFlags;
  uint CPUAccessFlags;
  uint MiscFlags;
  uint StructureByteStride;
}
struct D3D11_SUBRESOURCE_DATA {
  const(void)* pSysMem;
  uint SysMemPitch;
  uint SysMemSlicePitch;
}
struct D3D11_VIEWPORT {
  float TopLeftX;
  float TopLeftY;
  float Width;
  float Height;
  float MinDepth;
  float MaxDepth;
}
enum D3D11_INPUT_CLASSIFICATION : int {
  VERTEX_DATA = 0,
  INSTANCE_DATA = 1,
}
struct D3D11_INPUT_ELEMENT_DESC {
  const(char)* SemanticName;
  uint SemanticIndex;
  DXGI_FORMAT Format;
  uint InputSlot;
  uint AlignedByteOffset;
  D3D11_INPUT_CLASSIFICATION InputSlotClass;
  uint InstanceDataStepRate;
}
struct ID3D11Device {
  __gshared immutable uuidof = IID(0xDB6F6DDB, 0xAC77, 0x4E88, [0x82, 0x53, 0x81, 0x9D, 0xF9, 0xBB, 0xF1, 0x40]);
  struct VTable {
    IUnknown.VTable iunknown_vtable;
    alias this = iunknown_vtable;
    extern(Windows) HRESULT function(void*, const(D3D11_BUFFER_DESC)*, const(D3D11_SUBRESOURCE_DATA)*, ID3D11Buffer**) CreateBuffer;
    void* CreateTexture1D;
    void* CreateTexture2D;
    void* CreateTexture3D;
    void* CreateShaderResourceView;
    void* CreateUnorderedAccessView;
    extern(Windows) HRESULT function(void*, ID3D11Resource*, const(D3D11_RENDER_TARGET_VIEW_DESC)*, ID3D11RenderTargetView**) CreateRenderTargetView;
    void* CreateDepthStencilView;
    extern(Windows) HRESULT function(void*, const(D3D11_INPUT_ELEMENT_DESC)*, uint, const(void)*, size_t, ID3D11InputLayout**) CreateInputLayout;
    extern(Windows) HRESULT function(void*, const(void)*, size_t, ID3D11ClassLinkage*, ID3D11VertexShader**) CreateVertexShader;
    void* CreateGeometryShader;
    void* CreateGeometryShaderWithStreamOutput;
    extern(Windows) HRESULT function(void*, const(void)*, size_t, ID3D11ClassLinkage*, ID3D11PixelShader**) CreatePixelShader;
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
  mixin COMClass;
}
struct ID3D11DeviceChild {
  __gshared immutable uuidof = IID(0x1841E5C8, 0x16B0, 0x489B, [0xBC, 0xC8, 0x44, 0xCF, 0xB0, 0xD5, 0xDE, 0xAE]);
  struct VTable {
    IUnknown.VTable iunknown_vtable;
    alias this = iunknown_vtable;
    extern(Windows) void function(void*, ID3D11Device**) GetDevice;
    extern(Windows) HRESULT function(void*, GUID*, uint*, void*) GetPrivateData;
    extern(Windows) HRESULT function(void*, GUID*, uint, const(void)*) SetPrivateData;
    extern(Windows) HRESULT function(void*, GUID*, const(IUnknown)*) SetPrivateDataInterface;
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
struct ID3D11ClassInstance {
  struct VTable {
    ID3D11DeviceChild.VTable id3d11devicechild_vtable;
    alias this = id3d11devicechild_vtable;
    // ...
  }
  mixin COMClass;
}
struct ID3D11DeviceContext {
  __gshared immutable uuidof = IID(0xC0BFA96C, 0xE089, 0x44FB, [0x8E, 0xAF, 0x26, 0xF8, 0x79, 0x61, 0x90, 0xDA]);
  struct VTable {
    ID3D11DeviceChild.VTable id3d11devicechild_vtable;
    alias this = id3d11devicechild_vtable;
    void* VSSetConstantBuffers;
    void* PSSetShaderResources;
    extern(Windows) void function(void*, ID3D11PixelShader*, const(ID3D11ClassInstance*)*, uint) PSSetShader;
    void* PSSetSamplers;
    extern(Windows) void function(void*, ID3D11VertexShader*, const(ID3D11ClassInstance*)*, uint) VSSetShader;
    extern(Windows) void function(void*, uint, uint, int) DrawIndexed;
    extern(Windows) void function(void*, uint, uint) Draw;
    void* Map;
    void* Unmap;
    void* PSSetConstantBuffers;
    extern(Windows) void function(void*, ID3D11InputLayout*) IASetInputLayout;
    extern(Windows) void function(void*, uint, uint, const(ID3D11Buffer*)*, const(uint)*, const(uint)*) IASetVertexBuffers;
    extern(Windows) void function(void*, ID3D11Buffer*, DXGI_FORMAT, uint) IASetIndexBuffer;
    void* DrawIndexedInstanced;
    void* DrawInstanced;
    void* GSSetConstantBuffers;
    void* GSSetShader;
    extern(Windows) void function(void*, D3D11_PRIMITIVE_TOPOLOGY) IASetPrimitiveTopology;
    void* VSSetShaderResources;
    void* VSSetSamplers;
    void* Begin;
    void* End;
    void* GetData;
    void* SetPredication;
    void* GSSetShaderResources;
    void* GSSetSamplers;
    extern(Windows) void function(void*, uint, const(ID3D11RenderTargetView*)*, ID3D11DepthStencilView*) OMSetRenderTargets;
    void* OMSetRenderTargetsAndUnorderedAccessViews;
    void* OMSetBlendState;
    void* OMSetDepthStencilState;
    void* SOSetTargets;
    void* DrawAuto;
    void* DrawIndexedInstancedIndirect;
    void* DrawInstancedIndirect;
    void* Dispatch;
    void* DispatchIndirect;
    void* RSSetState;
     extern(Windows) void function(void*, uint, const(D3D11_VIEWPORT)*) RSSetViewports;
    void* RSSetScissorRects;
    void* CopySubresourceRegion;
    void* CopyResource;
    void* UpdateSubresource;
    void* CopyStructureCount;
    extern(Windows) void function(void*, ID3D11RenderTargetView*, const(float)*) ClearRenderTargetView;
    void* ClearUnorderedAccessViewUint;
    void* ClearUnorderedAccessViewFloat;
    void* ClearDepthStencilView;
    void* GenerateMips;
    void* SetResourceMinLOD;
    void* GetResourceMinLOD;
    void* ResolveSubresource;
    void* ExecuteCommandList;
    void* HSSetShaderResources;
    void* HSSetShader;
    void* HSSetSamplers;
    void* HSSetConstantBuffers;
    void* DSSetShaderResources;
    void* DSSetShader;
    void* DSSetSamplers;
    void* DSSetConstantBuffers;
    void* CSSetShaderResources;
    void* CSSetUnorderedAccessViews;
    void* CSSetShader;
    void* CSSetSamplers;
    void* CSSetConstantBuffers;
    void* VSGetConstantBuffers;
    void* PSGetShaderResources;
    void* PSGetShader;
    void* PSGetSamplers;
    void* VSGetShader;
    void* PSGetConstantBuffers;
    void* IAGetInputLayout;
    void* IAGetVertexBuffers;
    void* IAGetIndexBuffer;
    void* GSGetConstantBuffers;
    void* GSGetShader;
    void* IAGetPrimitiveTopology;
    void* VSGetShaderResources;
    void* VSGetSamplers;
    void* GetPredication;
    void* GSGetShaderResources;
    void* GSGetSamplers;
    void* OMGetRenderTargets;
    void* OMGetRenderTargetsAndUnorderedAccessViews;
    void* OMGetBlendState;
    void* OMGetDepthStencilState;
    void* SOGetTargets;
    void* RSGetState;
    void* RSGetViewports;
    void* RSGetScissorRects;
    void* HSGetShaderResources;
    void* HSGetShader;
    void* HSGetSamplers;
    void* HSGetConstantBuffers;
    void* DSGetShaderResources;
    void* DSGetShader;
    void* DSGetSamplers;
    void* DSGetConstantBuffers;
    void* CSGetShaderResources;
    void* CSGetUnorderedAccessViews;
    void* CSGetShader;
    void* CSGetSamplers;
    void* CSGetConstantBuffers;
    void* ClearState;
    void* Flush;
    void* GetType;
    void* GetContextFlags;
    void* FinishCommandList;
  }
  mixin COMClass;
}
struct ID3D11Resource {
  struct VTable {
    ID3D11DeviceChild.VTable id3d11devicechild_vtable;
    alias this = id3d11devicechild_vtable;
    extern(Windows) void function(void*, D3D11_RESOURCE_DIMENSION*) GetType;
    extern(Windows) void function(void*, uint) SetEvictionPriority;
    extern(Windows) uint function(void*) GetEvictionPriority;
  }
  mixin COMClass;
}
struct ID3D11Buffer {
  struct VTable {
    ID3D11Resource.VTable id3d11resource_vtable;
    alias this = id3d11resource_vtable;
    // ...
  }
  mixin COMClass;
}
struct ID3D11Texture2D {
  __gshared immutable uuidof = IID(0x6F15AAF2, 0xD208, 0x4E89, [0x9A, 0xB4, 0x48, 0x95, 0x35, 0xD3, 0x4F, 0x9C]);
  struct VTable {
    ID3D11Resource.VTable id3d11resource_vtable;
    alias this = id3d11resource_vtable;
    extern(Windows) void function(void*, D3D11_TEXTURE2D_DESC*) GetDesc;
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
    // ...
  }
  mixin COMClass;
}

@foreign("d3d11") extern(Windows) HRESULT D3D11CreateDeviceAndSwapChain(IDXGIAdapter*, D3D_DRIVER_TYPE, HMODULE, uint, const(D3D_FEATURE_LEVEL)*, uint, uint, const(DXGI_SWAP_CHAIN_DESC)*, IDXGISwapChain**, ID3D11Device**, D3D_FEATURE_LEVEL*, ID3D11DeviceContext**);

// dxgi
enum DXGI_CPU_ACCESS_NONE = 0;
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

struct DXGI_ADAPTER_DESC {
  wchar[128] Description;
  uint VendorId;
  uint DeviceId;
  uint SubSysId;
  uint Revision;
  size_t DedicatedVideoMemory;
  size_t DedicatedSystemMemory;
  size_t SharedSystemMemory;
  long AdapterLuid;
}
struct DXGI_RATIONAL {
  uint Numerator;
  uint Denominator;
}
enum DXGI_FORMAT : int {
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
  FORCE_UINT = 0xFFFFFFFF,
}
enum DXGI_MODE_SCANLINE_ORDER : int {
  UNSPECIFIED = 0,
  PROGRESSIVE = 1,
  UPPER_FIELD_FIRST = 2,
  LOWER_FIELD_FIRST = 3,
}
enum DXGI_MODE_SCALING : int {
  UNSPECIFIED = 0,
  CENTERED = 1,
  STRETCHED = 2,
}
struct DXGI_MODE_DESC {
  uint Width;
  uint Height;
  DXGI_RATIONAL RefreshRate;
  DXGI_FORMAT Format;
  DXGI_MODE_SCANLINE_ORDER ScanlineOrdering;
  DXGI_MODE_SCALING Scaling;
}
struct DXGI_SAMPLE_DESC {
  uint Count;
  uint Quality;
}
alias DXGI_USAGE = uint;
enum DXGI_SWAP_EFFECT : int {
  DISCARD = 0,
  SEQUENTIAL = 1,
  FLIP_SEQUENTIAL = 3,
  FLIP_DISCARD = 4,
}
enum DXGI_SWAP_CHAIN_FLAG : int {
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
struct DXGI_SWAP_CHAIN_DESC {
  DXGI_MODE_DESC BufferDesc;
  DXGI_SAMPLE_DESC SampleDesc;
  DXGI_USAGE BufferUsage;
  uint BufferCount;
  HWND OutputWindow;
  int Windowed;
  DXGI_SWAP_EFFECT SwapEffect;
  uint Flags;
}
enum DXGI_MWA : int {
  NO_WINDOW_CHANGES = 0,
  NO_ALT_ENTER = 1,
  NO_PRINT_SCREEN = 2,
}
struct IDXGIObject {
  __gshared immutable uuidof = IID(0xAEC22FB8, 0x76F3, 0x4639, [0x9B, 0xE0, 0x28, 0xEB, 0x43, 0xA6, 0x7A, 0x2E]);
  struct VTable {
    IUnknown.VTable iunknown_vtable;
    alias this = iunknown_vtable;
    extern(Windows) HRESULT function(void*, GUID*, uint, const(void)*) SetPrivateData;
    extern(Windows) HRESULT function(void*, GUID*, const(IUnknown)*) SetPrivateDataInterface;
    extern(Windows) HRESULT function(void*, GUID*, uint*, void*) GetPrivateData;
    extern(Windows) HRESULT function(void*, IID*, void**) GetParent;
  }
  mixin COMClass;
}
struct IDXGIOutput {
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
    extern(Windows) HRESULT function(void*, uint, IDXGIAdapter**) EnumAdapters;
    extern(Windows) HRESULT function(void*, HWND, DXGI_MWA) MakeWindowAssociation;
    // ...
  }
  mixin COMClass;
}
struct IDXGIAdapter {
  __gshared immutable uuidof = IID(0x2411E7E1, 0x12AC, 0x4CCF, [0xBD, 0x14, 0x97, 0x98, 0xE8, 0x53, 0x4D, 0xC0]);
  struct VTable {
    IDXGIObject.VTable idxgiobject_vtable;
    alias this = idxgiobject_vtable;
    extern(Windows) HRESULT function(void*, uint, IDXGIOutput**) EnumOutputs;
    extern(Windows) HRESULT function(void*, DXGI_ADAPTER_DESC*) GetDesc;
    extern(Windows) HRESULT function(void*, GUID*, ulong*) CheckInterfaceSupport;
  }
  mixin COMClass;
}
struct IDXGIDevice {
  __gshared immutable uuidof = IID(0x54EC77FA, 0x1377, 0x44E6, [0x8C, 0x32, 0x88, 0xFD, 0x5F, 0x44, 0xC8, 0x4C]);
  struct VTable {
    IDXGIObject.VTable idxgiobject_vtable;
    alias this = idxgiobject_vtable;
    extern(Windows) HRESULT function(void*, IDXGIAdapter**) GetAdapter;
    // ...
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
    extern(Windows) HRESULT function(void*, uint, uint) Present;
    extern(Windows) HRESULT function(void*, uint, IID*, void**) GetBuffer;
    void* SetFullscreenState;
    void* GetFullscreenState;
    void* GetDesc;
    extern(Windows) HRESULT function(void*, uint, uint, uint, DXGI_FORMAT, uint) ResizeBuffers;
    void* ResizeTarget;
    void* GetContainingOutput;
    void* GetFrameStatistics;
    void* GetLastPresentCount;
  }
  mixin COMClass;
}

// d3dcompiler
struct D3D_SHADER_MACRO {
  const(char)* Name;
  const(char)* Definition;
}
enum D3DCOMPILE : int {
  DEBUG = 1 << 0,
  SKIP_VALIDATION = 1 << 1,
  SKIP_OPTIMIZATION = 1 << 2,
  PACK_MATRIX_ROW_MAJOR = 1 << 3,
  PACK_MATRIX_COLUMN_MAJOR = 1 << 4,
  PARTIAL_PRECISION = 1 << 5,
  FORCE_VS_SOFTWARE_NO_OPT = 1 << 6,
  FORCE_PS_SOFTWARE_NO_OPT = 1 << 7,
  NO_PRESHADER = 1 << 8,
  AVOID_FLOW_CONTROL = 1 << 9,
  PREFER_FLOW_CONTROL = 1 << 10,
  ENABLE_STRICTNESS = 1 << 11,
  ENABLE_BACKWARDS_COMPATIBILITY = 1 << 12,
  IEEE_STRICTNESS = 1 << 13,
  OPTIMIZATION_LEVEL0 = 1 << 14,
  OPTIMIZATION_LEVEL3 = 1 << 15,
  RESERVED16 = 1 << 16,
  RESERVED17 = 1 << 17,
  WARNINGS_ARE_ERRORS = 1 << 18,
  RESOURCES_MAY_ALIAS = 1 << 19,
  ENABLE_UNBOUNDED_DESCRIPTOR_TABLES = 1 << 20,
  ALL_RESOURCES_BOUND = 1 << 21,
  DEBUG_NAME_FOR_SOURCE = 1 << 22,
  DEBUG_NAME_FOR_BINARY = 1 << 23,
}
struct ID3DInclude {
  struct VTable {
    void* Open;
    void* Close;
  }
  mixin COMClass;
}
struct ID3DBlob {
  struct VTable {
    IUnknown.VTable iunknown_vtable;
    alias this = iunknown_vtable;
    extern(Windows) void* function(void*) GetBufferPointer;
    extern(Windows) size_t function(void*) GetBufferSize;
  }
  mixin COMClass;
}

@foreign("d3dcompiler") extern(Windows) HRESULT D3DCompile(const(void)*, size_t, const(char)*, const(D3D_SHADER_MACRO)*, ID3DInclude*, const(char)*, const(char)*, uint, uint, ID3DBlob**, ID3DBlob**);
@foreign("d3dcompiler") extern(Windows) HRESULT D3DCompileFromFile(const(wchar)*, const(D3D_SHADER_MACRO)*, ID3DInclude*, const(char)*, const(char)*, uint, uint, ID3DBlob**, ID3DBlob**);
