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
MONITOR_DEFAULTTOPRIMARY :: 1;
HWND_TOP :: cast(HWND) 0;
SWP_NOSIZE :: 0x0001;
SWP_NOMOVE :: 0x0002;
SWP_NOZORDER :: 0x0004;
SWP_FRAMECHANGED :: 0x0020;
VK_RETURN :: 0x0D;
VK_MENU :: 0x12;
VK_ESCAPE :: 0x1B;
VK_F4 :: 0x73;
VK_F6 :: 0x75;
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
PostQuitMessage :: (status: s32) #foreign User32;
DefWindowProcW :: (hwnd: HWND, message: u32, wParam: usize, lParam: ssize) -> ssize #foreign User32;
GetDC :: (hwnd: HWND) -> HDC #foreign User32;
ValidateRect :: (hwnd: HWND, rect: *RECT) -> s32 #foreign User32;
DestroyWindow :: (hwnd: HWND) -> s32 #foreign User32;
ClipCursor :: (rect: *RECT) -> s32 #foreign User32;
SetWindowTextA :: (hwnd: HWND, s: *u8) -> s32 #foreign User32;
GetWindowLongPtrW :: (hwnd: HWND, index: s32) -> ssize #foreign User32;
SetWindowLongPtrW :: (hwnd: HWND, index: s32, value: ssize) -> ssize #foreign User32;
GetWindowPlacement :: (hwnd: HWND, placement: *WINDOWPLACEMENT) -> s32 #foreign User32;
SetWindowPlacement :: (hwnd: HWND, placement: *WINDOWPLACEMENT) -> s32 #foreign User32;
SetWindowPos :: (hwnd: HWND, after: HWND, x: s32, y: s32, w: s32, h: s32, flags: u32) -> s32 #foreign User32;
MonitorFromWindow :: (hwnd: HWND, flags: u32) -> HMONITOR #foreign User32;
GetMonitorInfoW :: (monitor: HMONITOR, info: *MONITORINFO) -> s32 #foreign User32;

// Ws2_32
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

WSAStartup :: (version: u16, wsadata: *WSADATA) -> s32 #foreign Ws2_32;
WSACleanup :: () -> s32 #foreign Ws2_32;

// Dwmapi
Dwmapi :: #library,system "Dwmapi";

DWMWA_USE_IMMERSIVE_DARK_MODE :: 20;
DWMWA_WINDOW_CORNER_PREFERENCE :: 33;
DWMWCP_DONOTROUND :: 1;

DwmSetWindowAttribute :: (hwnd: HWND, attribute: u32, data: *void, size: u32) -> HRESULT #foreign Dwmapi;

// Winmm
Winmm :: #library,system "Winmm";

TIMERR_NOERROR :: 0;

timeBeginPeriod :: (interval: u32) -> u32 #foreign Winmm;
