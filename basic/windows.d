module basic.windows;

import basic;

alias HANDLE = void*;
alias HRESULT = s32;
struct GUID {
  u32 Data1;
  u16 Data2;
  u16 Data3;
  u8[8] Data4;
}
alias IID = const(GUID);
struct LUID {
  u32 LowPart;
  s32 HighPart;
}
struct IUnknown {
  struct VTable {
    extern(Windows) HRESULT function(void*, IID*, void**) QueryInterface;
    extern(Windows) u32 function(void*) AddRef;
    extern(Windows) u32 function(void*) Release;
  }
  mixin COMClass;
}

// kernel32
struct HINSTANCE__; alias HINSTANCE = HINSTANCE__*;
alias HMODULE = HINSTANCE;
alias PROC = extern(Windows) ssize function();
struct STARTUPINFOW {
  u32 cb;
  wchar* lpReserved;
  wchar* lpDesktop;
  wchar* lpTitle;
  u32 dwX;
  u32 dwY;
  u32 dwXSize;
  u32 dwYSize;
  u32 dwXCountChars;
  u32 dwYCountChars;
  u32 dwFillAttribute;
  u32 dwFlags;
  u16 wShowWindow;
  u16 cbReserved2;
  u8* lpReserved2;
  HANDLE hStdInput;
  HANDLE hStdOutput;
  HANDLE hStdError;
}
struct PROCESS_INFORMATION {
  HANDLE hProcess;
  HANDLE hThread;
  u32 dwProcessId;
  u32 dwThreadId;
}

@foreign("kernel32") extern(Windows) {
  HMODULE GetModuleHandleW(const(wchar)*);
  HMODULE LoadLibraryW(const(wchar)*);
  PROC GetProcAddress(HMODULE, const(char)*);
  s32 FreeLibrary(HMODULE);
  s32 CreateProcessW(const(wchar)*, wchar*, void*, void*, s32, u32, void*, const(wchar)*, STARTUPINFOW*, PROCESS_INFORMATION*);
  s32 CloseHandle(HANDLE);
  void Sleep(u32);
  noreturn ExitProcess(u32);
}

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
enum WM_INPUT = 0x00FF;
enum WM_KEYDOWN = 0x0100;
enum WM_KEYUP = 0x0101;
enum WM_SYSKEYDOWN = 0x0104;
enum WM_SYSKEYUP = 0x0105;
enum WM_SYSCOMMAND = 0x0112;
enum SC_KEYMENU = 0xF100;
enum GWL_STYLE = -16;
enum HWND_TOP = cast(HWND) 0;
enum MONITOR_DEFAULTTOPRIMARY = 1;
enum SWP_NOSIZE = 0x0001;
enum SWP_NOMOVE = 0x0002;
enum SWP_NOZORDER = 0x0004;
enum SWP_FRAMECHANGED = 0x0020;
enum HID_USAGE_PAGE_GENERIC = 0x01;
enum HID_USAGE_GENERIC_MOUSE = 0x02;
enum RIM_TYPEMOUSE = 0;
enum RID_INPUT = 0x10000003;
enum VK_RETURN = 0x0D;
enum VK_MENU = 0x12;
enum VK_ESCAPE = 0x1B;
enum VK_F4 = 0x73;
enum VK_F6 = 0x75;
enum VK_F7 = 0x76;
enum VK_F10 = 0x79;
enum VK_F11 = 0x7A;

struct HDC__; alias HDC = HDC__*;
struct HWND__; alias HWND = HWND__*;
struct HMENU__; alias HMENU = HMENU__*;
struct HICON__; alias HICON = HICON__*;
struct HBRUSH__; alias HBRUSH = HBRUSH__*;
struct HCURSOR__; alias HCURSOR = HCURSOR__*;
struct HMONITOR__; alias HMONITOR = HMONITOR__*;
struct HRAWINPUT__; alias HRAWINPUT = HRAWINPUT__*;
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
struct RAWINPUTDEVICE {
  u16 usUsagePage;
  u16 usUsage;
  u32 dwFlags;
  HWND hwndTarget;
}
struct RAWINPUTHEADER {
  u32 dwType;
  u32 dwSize;
  HANDLE hDevice;
  usize wParam;
}
struct RAWMOUSE {
  u16 usFlags;
  union {
    u32 ulButtons;
    struct {
      u16 usButtonFlags;
      u16 usButtonData;
    }
  }
  u32 ulRawButtons;
  s32 lLastX;
  s32 lLastY;
  u32 ulExtraInformation;
}
struct RAWKEYBOARD {
  u16 MakeCode;
  u16 Flags;
  u16 Reserved;
  u16 VKey;
  u32 Message;
  u32 ExtraInformation;
}
struct RAWHID {
  u32 dwSizeHid;
  u32 dwCount;
  u8* bRawData;
}
struct RAWINPUT {
  union Data {
    RAWMOUSE mouse;
    RAWKEYBOARD keyboard;
    RAWHID hid;
  }

  RAWINPUTHEADER header;
  Data data;
}

@foreign("user32") extern(Windows) {
  s32 SetProcessDPIAware();
  HICON LoadIconW(HINSTANCE, const(wchar)*);
  HCURSOR LoadCursorW(HINSTANCE, const(wchar)*);
  u16 RegisterClassExW(const(WNDCLASSEXW)*);
  HWND CreateWindowExW(u32, const(wchar)*, const(wchar)*, u32, s32, s32, s32, s32, HWND, HMENU, HINSTANCE, void*);
  s32 PeekMessageW(MSG*, HWND, u32, u32, u32);
  s32 TranslateMessage(const(MSG)*);
  ssize DefWindowProcW(HWND, u32, usize, ssize);
  ssize DispatchMessageW(const(MSG)*);
  HDC GetDC(HWND);
  s32 ValidateRect(HWND, const(RECT)*);
  void PostQuitMessage(s32);
  s32 DestroyWindow(HWND);
  s32 ClipCursor(const(RECT)*);
  s32 SetWindowTextA(HWND, const(char)*);
  ssize GetWindowLongPtrW(HWND, s32);
  ssize SetWindowLongPtrW(HWND, s32, ssize);
  s32 GetWindowPlacement(HWND, WINDOWPLACEMENT*);
  s32 SetWindowPlacement(HWND, const(WINDOWPLACEMENT)*);
  s32 SetWindowPos(HWND, HWND, s32, s32, s32, s32, u32);
  HMONITOR MonitorFromWindow(HWND, u32);
  s32 GetMonitorInfoW(HMONITOR, MONITORINFO*);
  s32 RegisterRawInputDevices(const(RAWINPUTDEVICE)*, u32, u32);
  u32 GetRawInputData(HRAWINPUT, u32, void*, u32*, u32);
}

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

@foreign("gdi32") extern(Windows) {
  s32 ChoosePixelFormat(HDC, const(PIXELFORMATDESCRIPTOR)*);
  s32 SetPixelFormat(HDC, s32, const(PIXELFORMATDESCRIPTOR)*);
  s32 SwapBuffers(HDC);
}

// opengl32
struct HGLRC__; alias HGLRC = HGLRC__*;

@foreign("opengl32") extern(Windows) {
  HGLRC wglCreateContext(HDC);
  s32 wglDeleteContext(HGLRC);
  s32 wglMakeCurrent(HDC, HGLRC);
  PROC wglGetProcAddress(const(char)*);
}

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

@foreign("ws2_32") extern(Windows) {
  s32 WSAStartup(u16, WSADATA*);
  s32 WSACleanup();
}

// dwmapi
enum DWMWA_USE_IMMERSIVE_DARK_MODE = 20;
enum DWMWA_WINDOW_CORNER_PREFERENCE = 33;
enum DWMWCP_DONOTROUND = 1;

@foreign("dwmapi") extern(Windows) {
  HRESULT DwmSetWindowAttribute(HWND, u32, const(void)*, u32);
}

// winmm
enum TIMERR_NOERROR = 0;

@foreign("winmm") extern(Windows) {
  u32 timeBeginPeriod(u32);
}

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
enum D3D11_USAGE : s32 {
  DEFAULT = 0,
  IMMUTABLE = 1,
  DYNAMIC = 2,
  STAGING = 3,
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
struct D3D11_TEXTURE1D_DESC {
  u32 Width;
  u32 MipLevels;
  u32 ArraySize;
  DXGI_FORMAT Format;
  D3D11_USAGE Usage;
  u32 BindFlags;
  u32 CPUAccessFlags;
  u32 MiscFlags;
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
struct D3D11_TEXTURE3D_DESC {
  u32 Width;
  u32 Height;
  u32 Depth;
  u32 MipLevels;
  DXGI_FORMAT Format;
  D3D11_USAGE Usage;
  u32 BindFlags;
  u32 CPUAccessFlags;
  u32 MiscFlags;
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
enum D3D11_RESOURCE_DIMENSION : s32 {
  UNKNOWN = 0,
  BUFFER = 1,
  TEXTURE1D = 2,
  TEXTURE2D = 3,
  TEXTURE3D = 4,
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
enum D3D11_UAV_DIMENSION : s32 {
  UNKNOWN = 0,
  BUFFER = 1,
  TEXTURE1D = 2,
  TEXTURE1DARRAY = 3,
  TEXTURE2D = 4,
  TEXTURE2DARRAY = 5,
  TEXTURE3D = 8,
}
struct D3D11_BUFFER_UAV {
  u32 FirstElement;
  u32 NumElements;
  u32 Flags;
}
struct D3D11_TEX1D_UAV {
  u32 MipSlice;
}
struct D3D11_TEX1D_ARRAY_UAV {
  u32 MipSlice;
  u32 FirstArraySlice;
  u32 ArraySize;
}
struct D3D11_TEX2D_UAV {
  u32 MipSlice;
}
struct D3D11_TEX2D_ARRAY_UAV {
  u32 MipSlice;
  u32 FirstArraySlice;
  u32 ArraySize;
}
struct D3D11_TEX3D_UAV {
  u32 MipSlice;
  u32 FirstWSlice;
  u32 WSize;
}
struct D3D11_UNORDERED_ACCESS_VIEW_DESC {
  DXGI_FORMAT Format;
  D3D11_UAV_DIMENSION ViewDimension;
  union {
    D3D11_BUFFER_UAV Buffer;
    D3D11_TEX1D_UAV Texture1D;
    D3D11_TEX1D_ARRAY_UAV Texture1DArray;
    D3D11_TEX2D_UAV Texture2D;
    D3D11_TEX2D_ARRAY_UAV Texture2DArray;
    D3D11_TEX3D_UAV Texture3D;
  }
}
enum D3D11_SRV_DIMENSION : s32 {
  UNKNOWN = 0,
  BUFFER = 1,
  TEXTURE1D = 2,
  TEXTURE1DARRAY = 3,
  TEXTURE2D = 4,
  TEXTURE2DARRAY = 5,
  TEXTURE2DMS = 6,
  TEXTURE2DMSARRAY = 7,
  TEXTURE3D = 8,
  TEXTURECUBE = 9,
  TEXTURECUBEARRAY = 10,
  BUFFEREX = 11,
}
struct D3D11_BUFFER_SRV {
  union {
    u32 FirstElement;
    u32 ElementOffset;
  }
  union {
    u32 NumElements;
    u32 ElementWidth;
  }
}
struct D3D11_TEX1D_SRV {
  u32 MostDetailedMip;
  u32 MipLevels;
}
struct D3D11_TEX1D_ARRAY_SRV {
  u32 MostDetailedMip;
  u32 MipLevels;
  u32 FirstArraySlice;
  u32 ArraySize;
}
struct D3D11_TEX2D_SRV {
  u32 MostDetailedMip;
  u32 MipLevels;
}
struct D3D11_TEX2D_ARRAY_SRV {
  u32 MostDetailedMip;
  u32 MipLevels;
  u32 FirstArraySlice;
  u32 ArraySize;
}
struct D3D11_TEX2DMS_SRV {
  u32 UnusedField_NothingToDefine;
}
struct D3D11_TEX2DMS_ARRAY_SRV {
  u32 FirstArraySlice;
  u32 ArraySize;
}
struct D3D11_TEX3D_SRV {
  u32 MostDetailedMip;
  u32 MipLevels;
}
struct D3D11_TEXCUBE_SRV {
  u32 MostDetailedMip;
  u32 MipLevels;
}
struct D3D11_TEXCUBE_ARRAY_SRV {
  u32 MostDetailedMip;
  u32 MipLevels;
  u32 First2DArrayFace;
  u32 NumCubes;
}
struct D3D11_BUFFEREX_SRV {
  u32 FirstElement;
  u32 NumElements;
  u32 Flags;
}
struct D3D11_SHADER_RESOURCE_VIEW_DESC {
  DXGI_FORMAT Format;
  D3D11_SRV_DIMENSION ViewDimension;
  union {
    D3D11_BUFFER_SRV Buffer;
    D3D11_TEX1D_SRV Texture1D;
    D3D11_TEX1D_ARRAY_SRV Texture1DArray;
    D3D11_TEX2D_SRV Texture2D;
    D3D11_TEX2D_ARRAY_SRV Texture2DArray;
    D3D11_TEX2DMS_SRV Texture2DMS;
    D3D11_TEX2DMS_ARRAY_SRV Texture2DMSArray;
    D3D11_TEX3D_SRV Texture3D;
    D3D11_TEXCUBE_SRV TextureCube;
    D3D11_TEXCUBE_ARRAY_SRV TextureCubeArray;
    D3D11_BUFFEREX_SRV BufferEx;
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
struct D3D11_SO_DECLARATION_ENTRY {
  u32 Stream;
  const(char)* SemanticName;
  u32 SemanticIndex;
  u8 StartComponent;
  u8 ComponentCount;
  u8 OutputSlot;
}
enum D3D11_BLEND : s32 {
  ZERO = 1,
  ONE = 2,
  SRC_COLOR = 3,
  INV_SRC_COLOR = 4,
  SRC_ALPHA = 5,
  INV_SRC_ALPHA = 6,
  DEST_ALPHA = 7,
  INV_DEST_ALPHA = 8,
  DEST_COLOR = 9,
  INV_DEST_COLOR = 10,
  SRC_ALPHA_SAT = 11,
  BLEND_FACTOR = 14,
  INV_BLEND_FACTOR = 15,
  SRC1_COLOR = 16,
  INV_SRC1_COLOR = 17,
  SRC1_ALPHA = 18,
  INV_SRC1_ALPHA = 19,
}
enum D3D11_BLEND_OP : s32 {
  ADD = 1,
  SUBTRACT = 2,
  REV_SUBTRACT = 3,
  MIN = 4,
  MAX = 5,
}
struct D3D11_RENDER_TARGET_BLEND_DESC {
  s32 BlendEnable;
  D3D11_BLEND SrcBlend;
  D3D11_BLEND DestBlend;
  D3D11_BLEND_OP BlendOp;
  D3D11_BLEND SrcBlendAlpha;
  D3D11_BLEND DestBlendAlpha;
  D3D11_BLEND_OP BlendOpAlpha;
  u8 RenderTargetWriteMask;
}
struct D3D11_BLEND_DESC {
  s32 AlphaToCoverageEnable;
  s32 IndependentBlendEnable;
  D3D11_RENDER_TARGET_BLEND_DESC[8] RenderTarget;
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
  DECR = 8,
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
enum D3D11_FILL_MODE : s32 {
  WIREFRAME = 2,
  SOLID = 3,
}
enum D3D11_CULL_MODE : s32 {
  NONE = 1,
  FRONT = 2,
  BACK = 3,
}
struct D3D11_RASTERIZER_DESC {
  D3D11_FILL_MODE FillMode;
  D3D11_CULL_MODE CullMode;
  s32 FrontCounterClockwise;
  s32 DepthBias;
  f32 DepthBiasClamp;
  f32 SlopeScaledDepthBias;
  s32 DepthClipEnable;
  s32 ScissorEnable;
  s32 MultisampleEnable;
  s32 AntialiasedLineEnable;
}
enum D3D11_FILTER : s32 {
  MIN_MAG_MIP_POINT = 0,
  MIN_MAG_POINT_MIP_LINEAR = 0x1,
  MIN_POINT_MAG_LINEAR_MIP_POINT = 0x4,
  MIN_POINT_MAG_MIP_LINEAR = 0x5,
  MIN_LINEAR_MAG_MIP_POINT = 0x10,
  MIN_LINEAR_MAG_POINT_MIP_LINEAR = 0x11,
  MIN_MAG_LINEAR_MIP_POINT = 0x14,
  MIN_MAG_MIP_LINEAR = 0x15,
  ANISOTROPIC = 0x55,
  COMPARISON_MIN_MAG_MIP_POINT = 0x80,
  COMPARISON_MIN_MAG_POINT_MIP_LINEAR = 0x81,
  COMPARISON_MIN_POINT_MAG_LINEAR_MIP_POINT = 0x84,
  COMPARISON_MIN_POINT_MAG_MIP_LINEAR = 0x85,
  COMPARISON_MIN_LINEAR_MAG_MIP_POINT = 0x90,
  COMPARISON_MIN_LINEAR_MAG_POINT_MIP_LINEAR = 0x91,
  COMPARISON_MIN_MAG_LINEAR_MIP_POINT = 0x94,
  COMPARISON_MIN_MAG_MIP_LINEAR = 0x95,
  COMPARISON_ANISOTROPIC = 0xD5,
  MINIMUM_MIN_MAG_MIP_POINT = 0x100,
  MINIMUM_MIN_MAG_POINT_MIP_LINEAR = 0x101,
  MINIMUM_MIN_POINT_MAG_LINEAR_MIP_POINT = 0x104,
  MINIMUM_MIN_POINT_MAG_MIP_LINEAR = 0x105,
  MINIMUM_MIN_LINEAR_MAG_MIP_POINT = 0x110,
  MINIMUM_MIN_LINEAR_MAG_POINT_MIP_LINEAR = 0x111,
  MINIMUM_MIN_MAG_LINEAR_MIP_POINT = 0x114,
  MINIMUM_MIN_MAG_MIP_LINEAR = 0x115,
  MINIMUM_ANISOTROPIC = 0x155,
  MAXIMUM_MIN_MAG_MIP_POINT = 0x180,
  MAXIMUM_MIN_MAG_POINT_MIP_LINEAR = 0x181,
  MAXIMUM_MIN_POINT_MAG_LINEAR_MIP_POINT = 0x184,
  MAXIMUM_MIN_POINT_MAG_MIP_LINEAR = 0x185,
  MAXIMUM_MIN_LINEAR_MAG_MIP_POINT = 0x190,
  MAXIMUM_MIN_LINEAR_MAG_POINT_MIP_LINEAR = 0x191,
  MAXIMUM_MIN_MAG_LINEAR_MIP_POINT = 0x194,
  MAXIMUM_MIN_MAG_MIP_LINEAR = 0x195,
  MAXIMUM_ANISOTROPIC = 0x1D5,
}
enum D3D11_TEXTURE_ADDRESS_MODE : s32 {
  WRAP = 1,
  MIRROR = 2,
  CLAMP = 3,
  BORDER = 4,
  MIRROR_ONCE = 5,
}
struct D3D11_SAMPLER_DESC {
  D3D11_FILTER Filter;
  D3D11_TEXTURE_ADDRESS_MODE AddressU;
  D3D11_TEXTURE_ADDRESS_MODE AddressV;
  D3D11_TEXTURE_ADDRESS_MODE AddressW;
  f32 MipLODBias;
  u32 MaxAnisotropy;
  D3D11_COMPARISON_FUNC ComparisonFunc;
  f32[4] BorderColor;
  f32 MinLOD;
  f32 MaxLOD;
}
enum D3D11_QUERY : s32 {
  EVENT = 0,
  OCCLUSION = 1,
  TIMESTAMP = 2,
  TIMESTAMP_DISJOINT = 3,
  PIPELINE_STATISTICS = 4,
  OCCLUSION_PREDICATE = 5,
  SO_STATISTICS = 6,
  SO_OVERFLOW_PREDICATE = 7,
  SO_STATISTICS_STREAM0 = 8,
  SO_OVERFLOW_PREDICATE_STREAM0 = 9,
  SO_STATISTICS_STREAM1 = 10,
  SO_OVERFLOW_PREDICATE_STREAM1 = 11,
  SO_STATISTICS_STREAM2 = 12,
  SO_OVERFLOW_PREDICATE_STREAM2 = 13,
  SO_STATISTICS_STREAM3 = 14,
  SO_OVERFLOW_PREDICATE_STREAM3 = 15,
}
struct D3D11_QUERY_DESC {
  D3D11_QUERY Query;
  u32 MiscFlags;
}
enum D3D11_COUNTER : s32 {
  DEVICE_DEPENDENT_0 = 0x40000000,
}
struct D3D11_COUNTER_DESC {
  D3D11_COUNTER Counter;
  u32 MiscFlags;
}
enum D3D11_COUNTER_TYPE : s32 {
  FLOAT32 = 0,
  UINT16 = 1,
  UINT32 = 2,
  UINT64 = 3,
}
struct D3D11_COUNTER_INFO {
  D3D11_COUNTER LastDeviceDependentCounter;
  u32 NumSimultaneousCounters;
  u8 NumDetectableParallelUnits;
}
enum D3D11_FEATURE : s32 {
  THREADING = 0,
  DOUBLES = 1,
  FORMAT_SUPPORT = 2,
  FORMAT_SUPPORT2 = 3,
  D3D10_X_HARDWARE_OPTIONS = 4,
  D3D11_OPTIONS = 5,
  ARCHITECTURE_INFO = 6,
  D3D9_OPTIONS = 7,
  SHADER_MIN_PRECISION_SUPPORT = 8,
  D3D9_SHADOW_SUPPORT = 9,
  D3D11_OPTIONS1 = 10,
  D3D9_SIMPLE_INSTANCING_SUPPORT = 11,
  MARKER_SUPPORT = 12,
  D3D9_OPTIONS1 = 13,
  D3D11_OPTIONS2 = 14,
  D3D11_OPTIONS3 = 15,
  GPU_VIRTUAL_ADDRESS_SUPPORT = 16,
  D3D11_OPTIONS4 = 17,
  SHADER_CACHE = 18,
  D3D11_OPTIONS5 = 19,
  DISPLAYABLE = 20,
  D3D11_OPTIONS6 = 21,
}
struct D3D11_CLASS_INSTANCE_DESC {
  u32 InstanceId;
  u32 InstanceIndex;
  u32 TypeId;
  u32 ConstantBuffer;
  u32 BaseConstantBufferOffset;
  u32 BaseTexture;
  u32 BaseSampler;
  s32 Created;
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
struct D3D11_VIEWPORT {
  f32 TopLeftX;
  f32 TopLeftY;
  f32 Width;
  f32 Height;
  f32 MinDepth;
  f32 MaxDepth;
}
struct D3D11_BOX {
  u32 left;
  u32 top;
  u32 front;
  u32 right;
  u32 bottom;
  u32 back;
}
enum D3D11_DEVICE_CONTEXT_TYPE : s32 {
  IMMEDIATE = 0,
  DEFERRED = 1,
}
enum D3D11_CREATE_DEVICE_FLAG : s32 {
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
  struct VTable {
    IUnknown.VTable iunknown_vtable;
    alias this = iunknown_vtable;
    extern(Windows) HRESULT function(void*, const(D3D11_BUFFER_DESC)*, const(D3D11_SUBRESOURCE_DATA)*, ID3D11Buffer**) CreateBuffer;
    extern(Windows) HRESULT function(void*, const(D3D11_TEXTURE1D_DESC)*, const(D3D11_SUBRESOURCE_DATA)*, ID3D11Texture1D*) CreateTexture1D;
    extern(Windows) HRESULT function(void*, const(D3D11_TEXTURE2D_DESC)*, const(D3D11_SUBRESOURCE_DATA)*, ID3D11Texture2D*) CreateTexture2D;
    extern(Windows) HRESULT function(void*, const(D3D11_TEXTURE3D_DESC)*, const(D3D11_SUBRESOURCE_DATA)*, ID3D11Texture3D*) CreateTexture3D;
    extern(Windows) HRESULT function(void*, ID3D11Resource*, const(D3D11_SHADER_RESOURCE_VIEW_DESC)*, ID3D11ShaderResourceView**) CreateShaderResourceView;
    extern(Windows) HRESULT function(void*, ID3D11Resource*, const(D3D11_UNORDERED_ACCESS_VIEW_DESC)*, ID3D11UnorderedAccessView**) CreateUnorderedAccessView;
    extern(Windows) HRESULT function(void*, ID3D11Resource*, const(D3D11_RENDER_TARGET_VIEW_DESC)*, ID3D11RenderTargetView**) CreateRenderTargetView;
    extern(Windows) HRESULT function(void*, ID3D11Resource*, const(D3D11_DEPTH_STENCIL_VIEW_DESC)*, ID3D11DepthStencilView**) CreateDepthStencilView;
    extern(Windows) HRESULT function(void*, const(D3D11_INPUT_ELEMENT_DESC)*, u32, const(void)*, usize, ID3D11InputLayout**) CreateInputLayout;
    extern(Windows) HRESULT function(void*, const(void)*, usize, ID3D11ClassLinkage*, ID3D11VertexShader**) CreateVertexShader;
    extern(Windows) HRESULT function(void*, const(void)*, usize, ID3D11ClassLinkage*, ID3D11GeometryShader**) CreateGeometryShader;
    extern(Windows) HRESULT function(void*, const(void)*, usize, const(D3D11_SO_DECLARATION_ENTRY)*, u32, const(u32)*, u32, u32, ID3D11ClassLinkage*, ID3D11GeometryShader**) CreateGeometryShaderWithStreamOutput;
    extern(Windows) HRESULT function(void*, const(void)*, usize, ID3D11ClassLinkage*, ID3D11PixelShader**) CreatePixelShader;
    extern(Windows) HRESULT function(void*, const(void)*, usize, ID3D11ClassLinkage*, ID3D11HullShader**) CreateHullShader;
    extern(Windows) HRESULT function(void*, const(void)*, usize, ID3D11ClassLinkage*, ID3D11DomainShader**) CreateDomainShader;
    extern(Windows) HRESULT function(void*, const(void)*, usize, ID3D11ClassLinkage*, ID3D11ComputeShader**) CreateComputeShader;
    extern(Windows) HRESULT function(void*, ID3D11ClassLinkage**) CreateClassLinkage;
    extern(Windows) HRESULT function(void*, const(D3D11_BLEND_DESC)*, ID3D11BlendState**) CreateBlendState;
    extern(Windows) HRESULT function(void*, const(D3D11_DEPTH_STENCIL_DESC)*, ID3D11DepthStencilState**) CreateDepthStencilState;
    extern(Windows) HRESULT function(void*, const(D3D11_RASTERIZER_DESC)*, ID3D11RasterizerState**) CreateRasterizerState;
    extern(Windows) HRESULT function(void*, const(D3D11_SAMPLER_DESC)*, ID3D11SamplerState**) CreateSamplerState;
    extern(Windows) HRESULT function(void*, const(D3D11_QUERY_DESC)*, ID3D11Query**) CreateQuery;
    extern(Windows) HRESULT function(void*, const(D3D11_QUERY_DESC)*, ID3D11Predicate**) CreatePredicate;
    extern(Windows) HRESULT function(void*, const(D3D11_COUNTER_DESC)*, ID3D11Counter**) CreateCounter;
    extern(Windows) HRESULT function(void*, u32, ID3D11DeviceContext**) CreateDeferredContext;
    extern(Windows) HRESULT function(void*, HANDLE, IID*, void**) OpenSharedResource;
    extern(Windows) HRESULT function(void*, DXGI_FORMAT, u32*) CheckFormatSupport;
    extern(Windows) HRESULT function(void*, DXGI_FORMAT, u32, u32*) CheckMultisampleQualityLevels;
    extern(Windows) void function(void*, D3D11_COUNTER_INFO*) CheckCounterInfo;
    extern(Windows) HRESULT function(void*, const(D3D11_COUNTER_DESC)*, D3D11_COUNTER_TYPE*, u32*, char*, u32*, char*, u32*, char*, u32*) CheckCounter;
    extern(Windows) HRESULT function(void*, D3D11_FEATURE, void*, u32) CheckFeatureSupport;
    extern(Windows) HRESULT function(void*, GUID*, u32*, void*) GetPrivateData;
    extern(Windows) HRESULT function(void*, GUID*, u32, const(void)*) SetPrivateData;
    extern(Windows) HRESULT function(void*, GUID*, const(IUnknown)*) SetPrivateDataInterface;
    extern(Windows) D3D_FEATURE_LEVEL function(void*) GetFeatureLevel;
    extern(Windows) u32 function(void*) GetCreationFlags;
    extern(Windows) HRESULT function(void*) GetDeviceRemovedReason;
    extern(Windows) void function(void*, ID3D11DeviceContext**) GetImmediateContext;
    extern(Windows) HRESULT function(void*, u32) SetExceptionMode;
    extern(Windows) u32 function(void*) GetExceptionMode;
  }
  mixin COMClass;
}
struct ID3D11DeviceChild {
  struct VTable {
    IUnknown.VTable iunknown_vtable;
    alias this = iunknown_vtable;
    extern(Windows) void function(void*, ID3D11Device**) GetDevice;
    extern(Windows) HRESULT function(void*, GUID*, u32*, void*) GetPrivateData;
    extern(Windows) HRESULT function(void*, GUID*, u32, const(void)*) SetPrivateData;
    extern(Windows) HRESULT function(void*, GUID*, const(IUnknown)*) SetPrivateDataInterface;
  }
  mixin COMClass;
}
struct ID3D11DeviceContext {
  struct VTable {
    ID3D11DeviceChild.VTable id3d11devicechild_vtable;
    alias this = id3d11devicechild_vtable;
    extern(Windows) void function(void*, u32, u32, const(ID3D11Buffer*)*) VSSetConstantBuffers;
    extern(Windows) void function(void*, u32, u32, const(ID3D11ShaderResourceView*)*) PSSetShaderResources;
    extern(Windows) void function(void*, ID3D11PixelShader*, const(ID3D11ClassInstance*)*, u32) PSSetShader;
    extern(Windows) void function(void*, u32, u32, const(ID3D11SamplerState*)*) PSSetSamplers;
    extern(Windows) void function(void*, ID3D11VertexShader*, const(ID3D11ClassInstance*)*, u32) VSSetShader;
    extern(Windows) void function(void*, u32, u32, s32) DrawIndexed;
    extern(Windows) void function(void*, u32, u32) Draw;
    extern(Windows) HRESULT function(void*, ID3D11Resource*, u32, D3D11_MAP, u32, D3D11_MAPPED_SUBRESOURCE*) Map;
    extern(Windows) void function(void*, ID3D11Resource*, u32) Unmap;
    extern(Windows) void function(void*, u32, u32, const(ID3D11Buffer*)*) PSSetConstantBuffers;
    extern(Windows) void function(void*, ID3D11InputLayout*) IASetInputLayout;
    extern(Windows) void function(void*, u32, u32, const(ID3D11Buffer*)*, const(u32)*, const(u32)*) IASetVertexBuffers;
    extern(Windows) void function(void*, ID3D11Buffer*, DXGI_FORMAT, u32) IASetIndexBuffer;
    extern(Windows) void function(void*, u32, u32, u32, s32, u32) DrawIndexedInstanced;
    extern(Windows) void function(void*, u32, u32, u32, u32) DrawInstanced;
    extern(Windows) void function(void*, u32, u32, const(ID3D11Buffer*)*) GSSetConstantBuffers;
    extern(Windows) void function(void*, ID3D11GeometryShader*, const(ID3D11ClassInstance*)*, u32) GSSetShader;
    extern(Windows) void function(void*, D3D11_PRIMITIVE_TOPOLOGY) IASetPrimitiveTopology;
    extern(Windows) void function(void*, u32, u32, const(ID3D11ShaderResourceView*)*) VSSetShaderResources;
    extern(Windows) void function(void*, u32, u32, const(ID3D11SamplerState*)*) VSSetSamplers;
    extern(Windows) void function(void*, ID3D11Asynchronous*) Begin;
    extern(Windows) void function(void*, ID3D11Asynchronous*) End;
    extern(Windows) HRESULT function(void*, ID3D11Asynchronous*, void*, u32, u32) GetData;
    extern(Windows) void function(void*, ID3D11Predicate*, s32) SetPredication;
    extern(Windows) void function(void*, u32, u32, const(ID3D11ShaderResourceView*)*) GSSetShaderResources;
    extern(Windows) void function(void*, u32, u32, const(ID3D11SamplerState*)*) GSSetSamplers;
    extern(Windows) void function(void*, u32, const(ID3D11RenderTargetView*)*, ID3D11DepthStencilView*) OMSetRenderTargets;
    extern(Windows) void function(void*, u32, const(ID3D11RenderTargetView*)*, ID3D11DepthStencilView*, u32, u32, const(ID3D11UnorderedAccessView*)*, const(u32)*) OMSetRenderTargetsAndUnorderedAccessViews;
    extern(Windows) void function(void*, ID3D11BlendState*, const(f32)*, u32) OMSetBlendState;
    extern(Windows) void function(void*, ID3D11DepthStencilState*, u32) OMSetDepthStencilState;
    extern(Windows) void function(void*, u32, const(ID3D11Buffer*)*, const(u32)*) SOSetTargets;
    extern(Windows) void function(void*) DrawAuto;
    extern(Windows) void function(void*, ID3D11Buffer*, u32) DrawIndexedInstancedIndirect;
    extern(Windows) void function(void*, ID3D11Buffer*, u32) DrawInstancedIndirect;
    extern(Windows) void function(void*, u32, u32, u32) Dispatch;
    extern(Windows) void function(void*, ID3D11Buffer*, u32) DispatchIndirect;
    extern(Windows) void function(void*, ID3D11RasterizerState*) RSSetState;
    extern(Windows) void function(void*, u32, const(D3D11_VIEWPORT)*) RSSetViewports;
    extern(Windows) void function(void*, u32, const(RECT)*) RSSetScissorRects;
    extern(Windows) void function(void*, ID3D11Resource*, u32, u32, u32, u32, ID3D11Resource*, u32, const(D3D11_BOX)*) CopySubresourceRegion;
    extern(Windows) void function(void*, ID3D11Resource*, ID3D11Resource*) CopyResource;
    extern(Windows) void function(void*, ID3D11Resource*, u32, const(D3D11_BOX)*, const(void)*, u32, u32) UpdateSubresource;
    extern(Windows) void function(void*, ID3D11Buffer*, u32, ID3D11UnorderedAccessView*) CopyStructureCount;
    extern(Windows) void function(void*, ID3D11RenderTargetView*, const(f32)*) ClearRenderTargetView;
    extern(Windows) void function(void*, ID3D11UnorderedAccessView*, const(u32)*) ClearUnorderedAccessViewUint;
    extern(Windows) void function(void*, ID3D11UnorderedAccessView*, const(f32)*) ClearUnorderedAccessViewFloat;
    extern(Windows) void function(void*, ID3D11DepthStencilView*, u32, f32, u8) ClearDepthStencilView;
    extern(Windows) void function(void*, ID3D11ShaderResourceView*) GenerateMips;
    extern(Windows) void function(void*, ID3D11Resource*, f32) SetResourceMinLOD;
    extern(Windows) f32 function(void*, ID3D11Resource*) GetResourceMinLOD;
    extern(Windows) void function(void*, ID3D11Resource*, u32, ID3D11Resource*, u32, DXGI_FORMAT) ResolveSubresource;
    extern(Windows) void function(void*, ID3D11CommandList*, s32) ExecuteCommandList;
    extern(Windows) void function(void*, u32, u32, const(ID3D11ShaderResourceView*)*) HSSetShaderResources;
    extern(Windows) void function(void*, ID3D11HullShader*, const(ID3D11ClassInstance*)*, u32) HSSetShader;
    extern(Windows) void function(void*, u32, u32, const(ID3D11SamplerState*)*) HSSetSamplers;
    extern(Windows) void function(void*, u32, u32, const(ID3D11Buffer*)*) HSSetConstantBuffers;
    extern(Windows) void function(void*, u32, u32, const(ID3D11ShaderResourceView*)*) DSSetShaderResources;
    extern(Windows) void function(void*, ID3D11DomainShader*, const(ID3D11ClassInstance*)*, u32) DSSetShader;
    extern(Windows) void function(void*, u32, u32, const(ID3D11SamplerState*)*) DSSetSamplers;
    extern(Windows) void function(void*, u32, u32, const(ID3D11Buffer*)*) DSSetConstantBuffers;
    extern(Windows) void function(void*, u32, u32, const(ID3D11ShaderResourceView*)*) CSSetShaderResources;
    extern(Windows) void function(void*, u32, u32, const(ID3D11UnorderedAccessView*)*, const(u32)*) CSSetUnorderedAccessViews;
    extern(Windows) void function(void*, ID3D11ComputeShader*, const(ID3D11ClassInstance*)*, u32) CSSetShader;
    extern(Windows) void function(void*, u32, u32, const(ID3D11SamplerState*)*) CSSetSamplers;
    extern(Windows) void function(void*, u32, u32, const(ID3D11Buffer*)*) CSSetConstantBuffers;
    extern(Windows) void function(void*, u32, u32, ID3D11Buffer**) VSGetConstantBuffers;
    extern(Windows) void function(void*, u32, u32, ID3D11ShaderResourceView**) PSGetShaderResources;
    extern(Windows) void function(void*, ID3D11PixelShader**, ID3D11ClassInstance**, u32*) PSGetShader;
    extern(Windows) void function(void*, u32, u32, ID3D11SamplerState**) PSGetSamplers;
    extern(Windows) void function(void*, ID3D11VertexShader**, ID3D11ClassInstance**, u32*) VSGetShader;
    extern(Windows) void function(void*, u32, u32, ID3D11Buffer**) PSGetConstantBuffers;
    extern(Windows) void function(void*, ID3D11InputLayout**) IAGetInputLayout;
    extern(Windows) void function(void*, u32, u32, ID3D11Buffer**, u32*, u32*) IAGetVertexBuffers;
    extern(Windows) void function(void*, ID3D11Buffer**, DXGI_FORMAT*, u32*) IAGetIndexBuffer;
    extern(Windows) void function(void*, u32, u32, ID3D11Buffer**) GSGetConstantBuffers;
    extern(Windows) void function(void*, ID3D11GeometryShader**, ID3D11ClassInstance**, u32*) GSGetShader;
    extern(Windows) void function(void*, D3D11_PRIMITIVE_TOPOLOGY*) IAGetPrimitiveTopology;
    extern(Windows) void function(void*, u32, u32, ID3D11ShaderResourceView**) VSGetShaderResources;
    extern(Windows) void function(void*, u32, u32, ID3D11SamplerState**) VSGetSamplers;
    extern(Windows) void function(void*, ID3D11Predicate**, s32*) GetPredication;
    extern(Windows) void function(void*, u32, u32, ID3D11ShaderResourceView**) GSGetShaderResources;
    extern(Windows) void function(void*, u32, u32, ID3D11SamplerState**) GSGetSamplers;
    extern(Windows) void function(void*, u32, ID3D11RenderTargetView**, ID3D11DepthStencilView**) OMGetRenderTargets;
    extern(Windows) void function(void*, u32, ID3D11RenderTargetView**, ID3D11DepthStencilView**, u32, u32, ID3D11UnorderedAccessView**) OMGetRenderTargetsAndUnorderedAccessViews;
    extern(Windows) void function(void*, ID3D11BlendState, f32*, u32*) OMGetBlendState;
    extern(Windows) void function(void*, ID3D11DepthStencilState**, u32*) OMGetDepthStencilState;
    extern(Windows) void function(void*, u32, ID3D11Buffer**) SOGetTargets;
    extern(Windows) void function(void*, ID3D11RasterizerState**) RSGetState;
    extern(Windows) void function(void*, u32*, D3D11_VIEWPORT*) RSGetViewports;
    extern(Windows) void function(void*, u32*, RECT*) RSGetScissorRects;
    extern(Windows) void function(void*, u32, u32, ID3D11ShaderResourceView**) HSGetShaderResources;
    extern(Windows) void function(void*, ID3D11HullShader**, ID3D11ClassInstance**, u32*) HSGetShader;
    extern(Windows) void function(void*, u32, u32, ID3D11SamplerState**) HSGetSamplers;
    extern(Windows) void function(void*, u32, u32, ID3D11Buffer**) HSGetConstantBuffers;
    extern(Windows) void function(void*, u32, u32, ID3D11ShaderResourceView**) DSGetShaderResources;
    extern(Windows) void function(void*, ID3D11DomainShader**, ID3D11ClassInstance**, u32*) DSGetShader;
    extern(Windows) void function(void*, u32, u32, ID3D11SamplerState**) DSGetSamplers;
    extern(Windows) void function(void*, u32, u32, ID3D11Buffer**) DSGetConstantBuffers;
    extern(Windows) void function(void*, u32, u32, ID3D11ShaderResourceView**) CSGetShaderResources;
    extern(Windows) void function(void*, u32, u32, ID3D11UnorderedAccessView**) CSGetUnorderedAccessViews;
    extern(Windows) void function(void*, ID3D11ComputeShader**, ID3D11ClassInstance**, u32*) CSGetShader;
    extern(Windows) void function(void*, u32, u32, ID3D11SamplerState**) CSGetSamplers;
    extern(Windows) void function(void*, u32, u32, ID3D11Buffer**) CSGetConstantBuffers;
    extern(Windows) void function(void*) ClearState;
    extern(Windows) void function(void*) Flush;
    extern(Windows) D3D11_DEVICE_CONTEXT_TYPE function(void*) GetType;
    extern(Windows) u32 function(void*) GetContextFlags;
    extern(Windows) HRESULT function(void*, s32, ID3D11CommandList**) FinishCommandList;
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
struct ID3D11GeometryShader {
  struct VTable {
    ID3D11DeviceChild.VTable id3d11devicechild_vtable;
    alias this = id3d11devicechild_vtable;
  }
  mixin COMClass;
}
struct ID3D11HullShader {
  struct VTable {
    ID3D11DeviceChild.VTable id3d11devicechild_vtable;
    alias this = id3d11devicechild_vtable;
  }
  mixin COMClass;
}
struct ID3D11DomainShader {
  struct VTable {
    ID3D11DeviceChild.VTable id3d11devicechild_vtable;
    alias this = id3d11devicechild_vtable;
  }
  mixin COMClass;
}
struct ID3D11ComputeShader {
  struct VTable {
    ID3D11DeviceChild.VTable id3d11devicechild_vtable;
    alias this = id3d11devicechild_vtable;
  }
  mixin COMClass;
}
struct ID3D11BlendState {
  struct VTable {
    ID3D11DeviceChild.VTable id3d11devicechild_vtable;
    alias this = id3d11devicechild_vtable;
    extern(Windows) void function(void*, D3D11_BLEND_DESC*) GetDesc;
  }
  mixin COMClass;
}
struct ID3D11DepthStencilState {
  struct VTable {
    ID3D11DeviceChild.VTable id3d11devicechild_vtable;
    alias this = id3d11devicechild_vtable;
    extern(Windows) void function(void*, D3D11_DEPTH_STENCIL_DESC*) GetDesc;
  }
  mixin COMClass;
}
struct ID3D11RasterizerState {
  struct VTable {
    ID3D11DeviceChild.VTable id3d11devicechild_vtable;
    alias this = id3d11devicechild_vtable;
    extern(Windows) void function(void*, D3D11_RASTERIZER_DESC*) GetDesc;
  }
  mixin COMClass;
}
struct ID3D11SamplerState {
  struct VTable {
    ID3D11DeviceChild.VTable id3d11devicechild_vtable;
    alias this = id3d11devicechild_vtable;
    extern(Windows) void function(void*, D3D11_SAMPLER_DESC*) GetDesc;
  }
  mixin COMClass;
}
struct ID3D11CommandList {
  struct VTable {
    ID3D11DeviceChild.VTable id3d11devicechild_vtable;
    alias this = id3d11devicechild_vtable;
    extern(Windows) u32 function(void*) GetContextFlags;
  }
  mixin COMClass;
}
struct ID3D11ClassInstance {
  struct VTable {
    ID3D11DeviceChild.VTable id3d11devicechild_vtable;
    alias this = id3d11devicechild_vtable;
    extern(Windows) void function(void*, ID3D11ClassLinkage**) GetClassLinkage;
    extern(Windows) void function(void*, D3D11_CLASS_INSTANCE_DESC*) GetDesc;
    extern(Windows) void function(void*, char*, usize*) GetInstanceName;
    extern(Windows) void function(void*, char*, usize*) GetTypeName;
  }
  mixin COMClass;
}
struct ID3D11ClassLinkage {
  struct VTable {
    ID3D11DeviceChild.VTable id3d11devicechild_vtable;
    alias this = id3d11devicechild_vtable;
    extern(Windows) HRESULT function(void*, const(char)*, u32, ID3D11ClassInstance**) GetClassInstance;
    extern(Windows) HRESULT function(void*, const(char)*, u32, u32, u32, u32, ID3D11ClassInstance**) CreateClassInstance;
  }
  mixin COMClass;
}
struct ID3D11Asynchronous {
  struct VTable {
    ID3D11DeviceChild.VTable id3d11devicechild_vtable;
    alias this = id3d11devicechild_vtable;
    extern(Windows) u32 function(void*) GetDataSize;
  }
  mixin COMClass;
}
struct ID3D11Counter {
  struct VTable {
    ID3D11Asynchronous.VTable id3d11asynchronous_vtable;
    alias this = id3d11asynchronous_vtable;
    extern(Windows) void function(void*, D3D11_COUNTER_DESC*) GetDesc;
  }
  mixin COMClass;
}
struct ID3D11Query {
  struct VTable {
    ID3D11Asynchronous.VTable id3d11asynchronous_vtable;
    alias this = id3d11asynchronous_vtable;
    extern(Windows) void function(void*, D3D11_QUERY_DESC*) GetDesc;
  }
  mixin COMClass;
}
struct ID3D11Predicate {
  struct VTable {
    ID3D11Query.VTable id3d11query_vtable;
    alias this = id3d11query_vtable;
  }
  mixin COMClass;
}
struct ID3D11Resource {
  struct VTable {
    ID3D11DeviceChild.VTable id3d11devicechild_vtable;
    alias this = id3d11devicechild_vtable;
    extern(Windows) void function(void*, D3D11_RESOURCE_DIMENSION*) GetType;
    extern(Windows) void function(void*, u32) SetEvictionPriority;
    extern(Windows) u32 function(void*) GetEvictionPriority;
  }
  mixin COMClass;
}
struct ID3D11Buffer {
  struct VTable {
    ID3D11Resource.VTable id3d11resource_vtable;
    alias this = id3d11resource_vtable;
    extern(Windows) void function(void*, D3D11_BUFFER_DESC*) GetDesc;
  }
  mixin COMClass;
}
struct ID3D11Texture1D {
  struct VTable {
    ID3D11Resource.VTable id3d11resource_vtable;
    alias this = id3d11resource_vtable;
    extern(Windows) void function(void*, D3D11_TEXTURE1D_DESC*) GetDesc;
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
struct ID3D11Texture3D {
  struct VTable {
    ID3D11Resource.VTable id3d11resource_vtable;
    alias this = id3d11resource_vtable;
    extern(Windows) void function(void*, D3D11_TEXTURE3D_DESC*) GetDesc;
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
struct ID3D11ShaderResourceView {
  struct VTable {
    ID3D11View.VTable id3d11view_vtable;
    alias this = id3d11view_vtable;
    extern(Windows) void function(void*, D3D11_SHADER_RESOURCE_VIEW_DESC*) GetDesc;
  }
  mixin COMClass;
}
struct ID3D11UnorderedAccessView {
  struct VTable {
    ID3D11View.VTable id3d11view_vtable;
    alias this = id3d11view_vtable;
    extern(Windows) void function(void*, D3D11_UNORDERED_ACCESS_VIEW_DESC*) GetDesc;
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
    extern(Windows) void function(void*, D3D11_DEPTH_STENCIL_VIEW_DESC*) GetDesc;
  }
  mixin COMClass;
}

@foreign("d3d11") extern(Windows) {
  HRESULT D3D11CreateDeviceAndSwapChain(IDXGIAdapter*, D3D_DRIVER_TYPE, HMODULE, u32, const(D3D_FEATURE_LEVEL)*, u32, u32, const(DXGI_SWAP_CHAIN_DESC)*, IDXGISwapChain**, ID3D11Device**, D3D_FEATURE_LEVEL*, ID3D11DeviceContext**);
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
struct DXGI_SAMPLE_DESC {
  u32 Count;
  u32 Quality;
}
struct DXGI_SURFACE_DESC {
  u32 Width;
  u32 Height;
  DXGI_FORMAT Format;
  DXGI_SAMPLE_DESC SampleDesc;
}
struct DXGI_RATIONAL {
  u32 Numerator;
  u32 Denominator;
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
struct DXGI_MODE_DESC {
  u32 Width;
  u32 Height;
  DXGI_RATIONAL RefreshRate;
  DXGI_FORMAT Format;
  DXGI_MODE_SCANLINE_ORDER ScanlineOrdering;
  DXGI_MODE_SCALING Scaling;
}
struct DXGI_MAPPED_RECT {
  s32 Pitch;
  u8* pBits;
}
enum DXGI_MODE_ROTATION : s32 {
  UNSPECIFIED = 0,
  IDENTITY = 1,
  ROTATE90 = 2,
  ROTATE180 = 3,
  ROTATE270 = 4,
}
struct DXGI_OUTPUT_DESC {
  wchar[32] DeviceName;
  RECT DesktopCoordinates;
  s32 AttachedToDesktop;
  DXGI_MODE_ROTATION Rotation;
  HMONITOR Monitor;
}
struct DXGI_GAMMA_CONTROL_CAPABILITIES {
  s32 ScaleAndOffsetSupported;
  f32 MaxConvertedValue;
  f32 MinConvertedValue;
  u32 NumGammaControlPoints;
  f32[1025] ControlPointPositions;
}
struct DXGI_RGB {
  f32 Red;
  f32 Green;
  f32 Blue;
}
struct DXGI_GAMMA_CONTROL {
  DXGI_RGB Scale;
  DXGI_RGB Offset;
  DXGI_RGB[1025] GammaCurve;
}
struct DXGI_FRAME_STATISTICS {
  u32 PresentCount;
  u32 PresentRefreshCount;
  u32 SyncRefreshCount;
  s64 SyncQPCTime;
  s64 SyncGPUTime;
}
struct DXGI_ADAPTER_DESC {
  wchar[128] Description;
  u32 VendorId;
  u32 DeviceId;
  u32 SubSysId;
  u32 Revision;
  usize DedicatedVideoMemory;
  usize DedicatedSystemMemory;
  usize SharedSystemMemory;
  LUID AdapterLuid;
}
enum DXGI_USAGE : u32 {
  CPU_ACCESS_NONE = 0,
  CPU_ACCESS_DYNAMIC = 1,
  CPU_ACCESS_READ_WRITE = 2,
  CPU_ACCESS_SCRATCH = 3,
  CPU_ACCESS_FIELD = 15,
  SHADER_INPUT = 1 << (0 + 4),
  RENDER_TARGET_OUTPUT = 1 << (1 + 4),
  BACK_BUFFER = 1 << (2 + 4),
  SHARED = 1 << (3 + 4),
  READ_ONLY = 1 << (4 + 4),
  DISCARD_ON_PRESENT = 1 << (5 + 4),
  UNORDERED_ACCESS = 1 << (6 + 4),
}
enum DXGI_SWAP_EFFECT : s32 {
  DISCARD = 0,
  SEQUENTIAL = 1,
  FLIP_SEQUENTIAL = 3,
  FLIP_DISCARD = 4,
}
enum DXGI_SWAP_CHAIN_FLAG : s32 {
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
  u32 BufferCount;
  HWND OutputWindow;
  s32 Windowed;
  DXGI_SWAP_EFFECT SwapEffect;
  u32 Flags;
}
struct DXGI_SHARED_RESOURCE {
  HANDLE Handle;
}
enum DXGI_RESIDENCY : s32 {
  FULLY_RESIDENT = 1,
  RESIDENT_IN_SHARED_MEMORY = 2,
  EVICTED_TO_DISK = 3,
}
enum DXGI_MWA : s32 {
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
struct IDXGIFactory {
  __gshared immutable uuidof = IID(0x7B7166EC, 0x21C7, 0x44AE, [0xB2, 0x1A, 0xC9, 0xAE, 0x32, 0x1A, 0xE3, 0x69]);
  struct VTable {
    IDXGIObject.VTable idxgiobject_vtable;
    alias this = idxgiobject_vtable;
    extern(Windows) HRESULT function(void*, u32, IDXGIAdapter**) EnumAdapters;
    extern(Windows) HRESULT function(void*, HWND, u32) MakeWindowAssociation;
    extern(Windows) HRESULT function(void*, HWND*) GetWindowAssociation;
    extern(Windows) HRESULT function(void*, IUnknown*, DXGI_SWAP_CHAIN_DESC*, IDXGISwapChain**) CreateSwapChain;
    extern(Windows) HRESULT function(void*, HMODULE, IDXGIAdapter**) CreateSoftwareAdapter;
  }
  mixin COMClass;
}
struct IDXGIDevice {
  __gshared immutable uuidof = IID(0x54EC77FA, 0x1377, 0x44E6, [0x8C, 0x32, 0x88, 0xFD, 0x5F, 0x44, 0xC8, 0x4C]);
  struct VTable {
    IDXGIObject.VTable idxgiobject_vtable;
    alias this = idxgiobject_vtable;
    extern(Windows) HRESULT function(void*, IDXGIAdapter**) GetAdapter;
    extern(Windows) HRESULT function(void*, const(DXGI_SURFACE_DESC)*, u32, DXGI_USAGE, const(DXGI_SHARED_RESOURCE)*, IDXGISurface**) CreateSurface;
    extern(Windows) HRESULT function(void*, const(IUnknown*)*, DXGI_RESIDENCY*, u32) QueryResourceResidency;
    extern(Windows) HRESULT function(void*, s32) SetGPUThreadPriority;
    extern(Windows) HRESULT function(void*, s32*) GetGPUThreadPriority;
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
struct IDXGISurface {
  struct VTable {
    IDXGIDeviceSubObject.VTable idxgisubobject_vtable;
    alias this = idxgisubobject_vtable;
    extern(Windows) HRESULT function(void*, DXGI_SURFACE_DESC*) GetDesc;
    extern(Windows) HRESULT function(void*, DXGI_MAPPED_RECT*, u32) Map;
    extern(Windows) HRESULT function(void*) Unmap;
  }
  mixin COMClass;
}
struct IDXGISwapChain {
  struct VTable {
    IDXGIDeviceSubObject.VTable idxgisubobject_vtable;
    alias this = idxgisubobject_vtable;
    extern(Windows) HRESULT function(void*, u32, u32) Present;
    extern(Windows) HRESULT function(void*, u32, IID*, void**) GetBuffer;
    extern(Windows) HRESULT function(void*, s32, IDXGIOutput*) SetFullscreenState;
    extern(Windows) HRESULT function(void*, s32*, IDXGIOutput**) GetFullscreenState;
    extern(Windows) HRESULT function(void*, DXGI_SWAP_CHAIN_DESC*) GetDesc;
    extern(Windows) HRESULT function(void*, u32, u32, u32, DXGI_FORMAT, u32) ResizeBuffers;
    extern(Windows) HRESULT function(void*, const(DXGI_MODE_DESC)*) ResizeTarget;
    extern(Windows) HRESULT function(void*, IDXGIOutput**) GetContainingOutput;
    extern(Windows) HRESULT function(void*, DXGI_FRAME_STATISTICS*) GetFrameStatistics;
    extern(Windows) HRESULT function(void*, u32*) GetLastPresentCount;
  }
  mixin COMClass;
}
struct IDXGIOutput {
  struct VTable {
    IDXGIObject.VTable idxgiobject_vtable;
    alias this = idxgiobject_vtable;
    extern(Windows) HRESULT function(void*, DXGI_OUTPUT_DESC*) GetDesc;
    extern(Windows) HRESULT function(void*, DXGI_FORMAT, u32, u32*, DXGI_MODE_DESC*) GetDisplayModeList;
    extern(Windows) HRESULT function(void*, const(DXGI_MODE_DESC)*, DXGI_MODE_DESC*, IUnknown*) FindClosestMatchingMode;
    extern(Windows) HRESULT function(void*) WaitForVBlank;
    extern(Windows) HRESULT function(void*, IUnknown*, s32) TakeOwnership;
    extern(Windows) void function(void*) ReleaseOwnership;
    extern(Windows) HRESULT function(void*, DXGI_GAMMA_CONTROL_CAPABILITIES*) GetGammaControlCapabilities;
    extern(Windows) HRESULT function(void*, const(DXGI_GAMMA_CONTROL)*) SetGammaControl;
    extern(Windows) HRESULT function(void*, DXGI_GAMMA_CONTROL*) GetGammaControl;
    extern(Windows) HRESULT function(void*, IDXGISurface*) SetDisplaySurface;
    extern(Windows) HRESULT function(void*, IDXGISurface*) GetDisplaySurfaceData;
    extern(Windows) HRESULT function(void*, DXGI_FRAME_STATISTICS*) GetFrameStatistics;
  }
  mixin COMClass;
}
struct IDXGIAdapter {
  struct VTable {
    IDXGIObject.VTable idxgiobject_vtable;
    alias this = idxgiobject_vtable;
    extern(Windows) HRESULT function(void*, u32, IDXGIOutput**) EnumOutputs;
    extern(Windows) HRESULT function(void*, DXGI_ADAPTER_DESC*) GetDesc;
    extern(Windows) HRESULT function(void*, GUID*, s64*) CheckInterfaceSupport;
  }
  mixin COMClass;
}
