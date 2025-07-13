#import "Basic2";
#import "Windows2";

#load "renderer_d3d11.jai";

platform_hinstance: HINSTANCE;
platform_hwnd: HWND;
platform_hdc: HDC;
platform_width: u16;
platform_height: u16;
platform_save_placement := WINDOWPLACEMENT.{length=size_of(WINDOWPLACEMENT)};

utf16lez :: ($s: string) -> [s.count + 1]u16 {
  result: [s.count + 1]u16;
  for s result[it_index] = it;
  return result;
}

toggle_fullscreen :: () #no_context {
  style := GetWindowLongPtrW(platform_hwnd, GWL_STYLE);
  if style & WS_OVERLAPPEDWINDOW {
    mi := MONITORINFO.{cbSize=size_of(MONITORINFO)};
    GetMonitorInfoW(MonitorFromWindow(platform_hwnd, MONITOR_DEFAULTTOPRIMARY), *mi);

    GetWindowPlacement(platform_hwnd, *platform_save_placement);
    SetWindowLongPtrW(platform_hwnd, GWL_STYLE, style & ~WS_OVERLAPPEDWINDOW);
    SetWindowPos(platform_hwnd, HWND_TOP, mi.rcMonitor.left, mi.rcMonitor.top,
      mi.rcMonitor.right - mi.rcMonitor.left,
      mi.rcMonitor.bottom - mi.rcMonitor.top,
      SWP_FRAMECHANGED);
  } else {
    SetWindowLongPtrW(platform_hwnd, GWL_STYLE, style | WS_OVERLAPPEDWINDOW);
    SetWindowPlacement(platform_hwnd, *platform_save_placement);
    SetWindowPos(platform_hwnd, null, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE |
      SWP_NOZORDER | SWP_FRAMECHANGED);
  }
}

update_cursor_clip :: () #no_context {
  ClipCursor(null);
}

clear_held_keys :: () #no_context {

}

WinMainCRTStartup :: () #c_call {
  platform_hinstance = GetModuleHandleW(null);

  wsadata: WSADATA = ---;
  networking_supported := WSAStartup(0x202, *wsadata) == 0;

  sleep_is_granular := timeBeginPeriod(1) == TIMERR_NOERROR;

  SetProcessDPIAware();
  wndclass: WNDCLASSEXW;
  wndclass.cbSize = size_of(WNDCLASSEXW);
  wndclass.style = CS_OWNDC;
  wndclass.lpfnWndProc = (hwnd: HWND, message: u32, wParam: usize, lParam: ssize) -> ssize #c_call {
    if message == {
      case WM_PAINT;
        ValidateRect(hwnd, null);
      case WM_ERASEBKGND;
        return 1;
      case WM_ACTIVATEAPP;
        tabbing_in := wParam != 0;
        if tabbing_in update_cursor_clip();
        else clear_held_keys();
      case WM_SIZE;
        platform_width = cast,no_check(u16) lParam;
        platform_height = cast,no_check(u16) (lParam >> 16);

        renderer_d3d11.resize();
      case WM_CREATE;
        platform_hwnd = hwnd;
        platform_hdc = GetDC(hwnd);

        dark_mode: s32 = xx true;
        DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, *dark_mode, size_of(type_of(dark_mode)));
        round_mode: s32 = DWMWCP_DONOTROUND;
        DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE, *round_mode, size_of(type_of(round_mode)));

        renderer_d3d11.init();
      case WM_DESTROY;
        renderer_d3d11.deinit();

        PostQuitMessage(0);
      case WM_SYSCOMMAND;
        if wParam == SC_KEYMENU return 0;
        #through;
      case;
        return DefWindowProcW(hwnd, message, wParam, lParam);
    }
    return 0;
  };
  wndclass.hInstance = platform_hinstance;
  wndclass.hIcon = LoadIconW(null, IDI_WARNING);
  wndclass.hCursor = LoadCursorW(null, IDC_CROSS);
  wndclass.lpszClassName = (#run utf16lez("A")).data;
  RegisterClassExW(*wndclass);
  CreateWindowExW(0, wndclass.lpszClassName, (#run utf16lez("Outbreak Protocol")).data,
    WS_OVERLAPPEDWINDOW | WS_VISIBLE,
    CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
    null, null, platform_hinstance, null);

  while main_loop := true {
    msg: MSG = ---;
    while PeekMessageW(*msg, null, 0, 0, PM_REMOVE) {
      using msg;
      TranslateMessage(*msg);
      if message == {
        case WM_KEYDOWN; #through;
        case WM_KEYUP; #through;
        case WM_SYSKEYDOWN; #through;
        case WM_SYSKEYUP;
          pressed := lParam & (1 << 31) == 0;
          repeat := pressed && lParam & (1 << 30) != 0;
          sys := message == WM_SYSKEYDOWN || message == WM_SYSKEYUP;
          alt := sys && lParam & (1 << 29) != 0;

          if !repeat && (!sys || alt || wParam == VK_MENU || wParam == VK_F10) {
            if pressed {
              if wParam == VK_F4 && alt DestroyWindow(platform_hwnd);
              if wParam == VK_F11 toggle_fullscreen();
              if wParam == VK_RETURN && alt toggle_fullscreen();
            }
          }
        case WM_QUIT;
          break main_loop;
        case;
          DispatchMessageW(*msg);
      }
    }

    renderer_d3d11.present();

    if sleep_is_granular {
      Sleep(1);
    }
  }

  if networking_supported WSACleanup();

  ExitProcess(0);
}
