kernel32 :: struct {
  kernel32_library :: #library,system "kernel32";

  HINSTANCE :: *struct {};
  HMODULE :: HINSTANCE;

  GetModuleHandleW :: (name: *u16) -> HINSTANCE #foreign kernel32_library;
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
  WM_QUIT :: 0x0012;

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
}
