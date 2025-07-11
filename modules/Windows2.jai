#import "Basic2";

// Kernel32
Kernel32 :: #library,system "Kernel32";

HRESULT :: s32;
HINSTANCE :: *struct {};
HMODULE :: HINSTANCE;
PROC :: #type () -> ssize #c_call;

GetModuleHandleW :: (name: *u16) -> HMODULE #foreign Kernel32;
LoadLibraryW :: (name: *u16) -> HMODULE #foreign Kernel32;
GetProcAddress :: (module: HMODULE, name: *u8) -> PROC #foreign Kernel32;
FreeLibrary :: (module: HMODULE) -> s32 #foreign Kernel32;
Sleep :: (milli: u32) #foreign Kernel32;
ExitProcess :: (status: u32) -> noreturn #foreign Kernel32;

// User32
User32 :: #library,system "User32";

CS_OWNDC :: 0x0020;
IDI_WARNING :: cast(*u16) 32515;
IDC_CROSS :: cast(*u16) 32515;
PM_REMOVE :: 0x0001;
WM_CREATE :: 0x0001;
WM_DESTROY :: 0x0002;
WM_QUIT :: 0x0012;

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

SetProcessDPIAware :: () -> s32 #foreign User32;
LoadIconW :: (instance: HINSTANCE, name: *u16) -> HICON #foreign User32;
LoadCursorW :: (instance: HINSTANCE, name: *u16) -> HCURSOR #foreign User32;
RegisterClassExW :: (wndclass: *WNDCLASSEXW) -> u16 #foreign User32;
DefWindowProcW :: (hwnd: HWND, message: u32, wParam: usize, lParam: ssize) -> ssize #foreign User32;
PostQuitMessage :: (status: s32) #foreign User32;

// Dwmapi
Dwmapi :: #library,system "Dwmapi";

DwmSetWindowAttribute :: (hwnd: HWND, attribute: u32, data: *void, size: u32) -> HRESULT #foreign Dwmapi;

// Winmm
Winmm :: #library,system "Winmm";

TIMERR_NOERROR :: 0;

timeBeginPeriod :: (interval: u32) -> u32 #foreign Winmm;
