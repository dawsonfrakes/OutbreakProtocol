noreturn :: void;
ssize :: s64;
usize :: u64;

// kernel32
kernel32 :: #library,system "kernel32";

HINSTANCE :: *struct {};
HMODULE :: HINSTANCE;

GetModuleHandleW :: (name: *u16) -> HMODULE #foreign kernel32;
ExitProcess :: (status: u32) -> noreturn #foreign kernel32;

// user32
IDI_WARNING :: cast(*u16)32515;
IDC_CROSS :: cast(*u16)32515;

platform_hinstance: HINSTANCE;

#program_export WinMainCRTStartup :: () -> noreturn #c_call {
  platform_hinstance = GetModuleHandleW(null);

  wsadata: WSADATA = ---;
  networking_supported := WSAStartup(0x202, *wsadata) == 0;

  sleep_is_granular := timeBeginPeriod(1) == TIMERR_NOERROR;

  SetProcessDPIAware();
  wndclass: WNDCLASSEXW;
  wndclass.cbSize = size_of(WNDCLASSEXW);
  wndclass.style = CS_OWNDC;
  wndclass.lpfnWndProc = xx (hwnd: HWND, message: u32, wParam: usize, lParam: ssize) -> ssize #c_call {
    if message == {
      case WM_DESTROY;
        PostQuitMessage(0);
      case;
        return DefWindowProcW(hwnd, message, wParam, lParam);
    }
    return 0;
  };
  wndclass.hInstance = platform_hinstance;
  wndclass.hIcon = LoadIconW(null, IDI_WARNING);
  wndclass.hCursor = LoadCursorW(null, IDC_CROSS);
  wndclass.lpszClassName = u16.[#char "A", 0].data;
  RegisterClassExW(*wndclass);
  CreateWindowExW(0, wndclass.lpszClassName, u16.[#char "O", #char "u", #char "t", #char "b", #char "r", #char "e", #char "a", #char "k", #char "P", #char "r", #char "o", #char "t", #char "o", #char "c", #char "o", #char "l", 0].data,
    WS_OVERLAPPEDWINDOW | WS_VISIBLE,
    CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
    null, null, platform_hinstance, null);

  while main_loop := true {
    msg: MSG = ---;
    while PeekMessageW(*msg, null, 0, 0, PM_REMOVE) {
      using msg;
      TranslateMessage(*msg);
      if message == {
        case WM_QUIT; break main_loop;
        case; DispatchMessageW(*msg);
      }
    }

    if sleep_is_granular {
      Sleep(1);
    }
  }

  if networking_supported WSACleanup();

  ExitProcess(0);
}

#program_export _fltused: s32;
