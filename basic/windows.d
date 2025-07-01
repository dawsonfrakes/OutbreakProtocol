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

@foreign("kernel32") extern(Windows) HMODULE GetModuleHandleW(const(wchar)*);
@foreign("kernel32") extern(Windows) void Sleep(uint);
@foreign("kernel32") extern(Windows) int AllocConsole();
@foreign("kernel32") extern(Windows) HANDLE GetStdHandle(uint);
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
struct ID3D11Device {
  __gshared immutable uuidof = IID(0xDB6F6DDB, 0xAC77, 0x4E88, [0x82, 0x53, 0x81, 0x9D, 0xF9, 0xBB, 0xF1, 0x40]);
  struct VTable {
    IUnknown.VTable iunknown_vtable;
    alias this = iunknown_vtable;
    // ...
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
struct ID3D11DeviceContext {
  __gshared immutable uuidof = IID(0xC0BFA96C, 0xE089, 0x44FB, [0x8E, 0xAF, 0x26, 0xF8, 0x79, 0x61, 0x90, 0xDA]);
  struct VTable {
    ID3D11DeviceChild.VTable id3d11devicechild_vtable;
    alias this = id3d11devicechild_vtable;
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
  DXGI_MODE_SCANLINE_ORDER_UNSPECIFIED = 0,
  DXGI_MODE_SCANLINE_ORDER_PROGRESSIVE = 1,
  DXGI_MODE_SCANLINE_ORDER_UPPER_FIELD_FIRST = 2,
  DXGI_MODE_SCANLINE_ORDER_LOWER_FIELD_FIRST = 3,
}
enum DXGI_MODE_SCALING : int {
  DXGI_MODE_SCALING_UNSPECIFIED = 0,
  DXGI_MODE_SCALING_CENTERED = 1,
  DXGI_MODE_SCALING_STRETCHED = 2,
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
  DXGI_SWAP_EFFECT_DISCARD = 0,
  DXGI_SWAP_EFFECT_SEQUENTIAL = 1,
  DXGI_SWAP_EFFECT_FLIP_SEQUENTIAL = 3,
  DXGI_SWAP_EFFECT_FLIP_DISCARD = 4,
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
    // ...
  }
  mixin COMClass;
}
