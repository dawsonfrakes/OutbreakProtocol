module basic.windows;

import basic;

// Kernel32
alias HRESULT = s32;
struct HINSTANCE__; alias HINSTANCE = HINSTANCE__*;
alias HMODULE = HINSTANCE;
alias PROC = extern(Windows) ssize function();

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
