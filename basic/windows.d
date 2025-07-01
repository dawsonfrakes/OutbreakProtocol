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

// dxgi
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
