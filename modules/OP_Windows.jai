kernel32 :: struct {
  kernel32_library :: #library,system "kernel32";

  STD_INPUT_HANDLE :: cast,no_check(u32) -10;
  STD_OUTPUT_HANDLE :: cast,no_check(u32) -11;
  STD_ERROR_HANDLE :: cast,no_check(u32) -12;

  HANDLE :: *void;
  HRESULT :: s32;
  HINSTANCE :: *struct {};
  HMODULE :: HINSTANCE;

  GetModuleHandleW :: (name: *u16) -> HINSTANCE #foreign kernel32_library;
  AllocConsole :: () -> s32 #foreign kernel32_library;
  GetStdHandle :: (index: u32) -> HANDLE #foreign kernel32_library;
  WriteFile :: (file: HANDLE, data: *void, size: u32, written: *u32, overlapped: *void) -> s32 #foreign kernel32_library;
  Sleep :: (milliseconds: u32) #foreign kernel32_library;
  ExitProcess :: (exit_code: u32) #foreign kernel32_library;
}

user32 :: struct {
  user32_library :: #library,system "user32";

  CS_OWNDC :: 0x0020;
  IDI_WARNING :: cast(*void) 32515;
  IDC_CROSS :: cast(*void) 32515;
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
  HWND_TOP :: cast(HWND) 0;
  MONITOR_DEFAULTTOPRIMARY :: 1;
  GWL_STYLE :: -16;
  SWP_NOSIZE :: 0x0001;
  SWP_NOMOVE :: 0x0002;
  SWP_NOZORDER :: 0x0004;
  SWP_FRAMECHANGED :: 0x0020;
  VK_RETURN :: 0x0D;
  VK_MENU :: 0x12;
  VK_ESCAPE :: 0x1B;
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
  WNDPROC :: #type (HWND, u32, u64, s64) -> s64 #c_call;
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
    hInstance: kernel32.HINSTANCE;
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
    wParam: u64;
    lParam: s64;
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

  SetProcessDPIAware :: () -> s32 #foreign user32_library;
  LoadIconW :: (instance: kernel32.HINSTANCE, name: *u16) -> HICON #foreign user32_library;
  LoadCursorW :: (instance: kernel32.HINSTANCE, name: *u16) -> HCURSOR #foreign user32_library;
  RegisterClassExW :: (wndclass: *WNDCLASSEXW) -> u16 #foreign user32_library;
  CreateWindowExW :: (ex_style: u32, class_name: *u16, window_name: *u16, style: u32, x: s32, y: s32, w: s32, h: s32, parent: HWND, menu: HMENU, instance: kernel32.HINSTANCE, param: *void) -> HWND #foreign user32_library;
  PeekMessageW :: (msg: *MSG, hwnd: HWND, mmin: u32, mmax: u32, mremove: u32) -> s32 #foreign user32_library;
  TranslateMessage :: (msg: *MSG) -> s32 #foreign user32_library;
  DispatchMessageW :: (msg: *MSG) -> s64 #foreign user32_library;
  GetDC :: (hwnd: HWND) -> HDC #foreign user32_library;
  DefWindowProcW :: (hwnd: HWND, message: u32, wParam: u64, lParam: s64) -> s64 #foreign user32_library;
  PostQuitMessage :: (status: int) #foreign user32_library;
  ValidateRect :: (hwnd: HWND, rect: *RECT) -> s32 #foreign user32_library;
  DestroyWindow :: (hwnd: HWND) -> s32 #foreign user32_library;
  GetWindowLongPtrW :: (hwnd: HWND, index: s32) -> s64 #foreign user32_library;
  SetWindowLongPtrW :: (hwnd: HWND, index: s32, value: s64) -> s64 #foreign user32_library;
  GetWindowPlacement :: (hwnd: HWND, *WINDOWPLACEMENT) -> s32 #foreign user32_library;
  SetWindowPlacement :: (hwnd: HWND, *WINDOWPLACEMENT) -> s32 #foreign user32_library;
  SetWindowPos :: (hwnd: HWND, after: HWND, x: s32, y: s32, w: s32, h: s32, flags: u32) -> s32 #foreign user32_library;
  MonitorFromWindow :: (hwnd: HWND, flags: u32) -> HMONITOR #foreign user32_library;
  GetMonitorInfoW :: (monitor: HMONITOR, mi: *MONITORINFO) -> s32 #foreign user32_library;
}

ws2_32 :: struct {
  ws2_32_library :: #library,system "ws2_32";

  WSADESCRIPTION_LEN :: 256;
  WSASYS_STATUS_LEN :: 128;

  WSADATA :: struct {
    wVersion: u16;
    wHighVersion: u16;
    #if CPU == .X64 || CPU == .ARM64 {
      iMaxSockets: u16;
      iMaxUdpDg: u16;
      lpVendorInfo: *u8;
      szDescription: [WSADESCRIPTION_LEN + 1]u8;
      szSystemStatus: [WSASYS_STATUS_LEN + 1]u8;
    } else {
      szDescription: [WSADESCRIPTION_LEN + 1]u8;
      szSystemStatus: [WSASYS_STATUS_LEN + 1]u8;
      iMaxSockets: u16;
      iMaxUdpDg: u16;
      lpVendorInfo: *u8;
    }
  }

  WSAStartup :: (version: u16, wsadata: *WSADATA) -> s32 #foreign ws2_32_library;
  WSACleanup :: () -> s32 #foreign ws2_32_library;
}

dwmapi :: struct {
  dwmapi_library :: #library,system "dwmapi";

  DWMWA_USE_IMMERSIVE_DARK_MODE :: 20;
  DWMWA_WINDOW_CORNER_PREFERENCE :: 33;
  DWMWCP_DONOTROUND :: 1;

  DwmSetWindowAttribute :: (hwnd: user32.HWND, attribute: u32, value: *void, size: u32) -> kernel32.HRESULT #foreign dwmapi_library;
}

winmm :: struct {
  winmm_library :: #library,system "winmm";

  TIMERR_NOERROR :: 0;

  timeBeginPeriod :: (interval: u32) -> u32 #foreign winmm_library;
}
