#import "Basic2";
#import "Windows2";

platform_hinstance: HINSTANCE;
platform_hwnd: HWND;
platform_hdc: HDC;
platform_width: u16;
platform_height: u16;

WinMainCRTStartup :: () -> noreturn #c_call {
  platform_hinstance = GetModuleHandleW(null);

  sleep_is_granular := timeBeginPeriod(1) == TIMERR_NOERROR;

  SetProcessDPIAware();
  wndclass: WNDCLASSEXW;
  wndclass.cbSize = size_of(WNDCLASSEXW);
  wndclass.style = CS_OWNDC;
  wndclass.lpfnWndProc = (hwnd: HWND, message: u32, wParam: usize, lParam: ssize) -> ssize #c_call {
    if message == {
      case WM_QUIT;
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

  while main_loop := true {
    msg: MSG = ---;

    if sleep_is_granular {
      Sleep(1);
    }
  }

  ExitProcess(0);
}
