#import "Basic2";
#import "Windows2";

#load "renderer.jai";
#load "renderer_d3d11.jai";
#load "renderer_opengl.jai";

platform_hinstance: HINSTANCE;
platform_hwnd: HWND;
platform_hdc: HDC;
platform_width: u16;
platform_height: u16;
platform_renderer_ := *null_renderer;

set_platform_renderer :: (renderer: *Platform_Renderer, arena: *Arena) #no_context {
  platform_renderer_ = renderer;
  SetWindowTextA(platform_hwnd, renderer.pretty_name.data);
}

switch_platform_renderer :: (renderer: *Platform_Renderer, arena: *Arena) #no_context {
  platform_renderer_.deinit();
  set_platform_renderer(renderer, arena);
  platform_renderer_.init();
  platform_renderer_.resize();
}

toggle_fullscreen_save_placement := WINDOWPLACEMENT.{length=size_of(WINDOWPLACEMENT)};
toggle_fullscreen :: () #no_context {
  style := GetWindowLongPtrW(platform_hwnd, GWL_STYLE);
  if style & WS_OVERLAPPEDWINDOW {
    mi := MONITORINFO.{cbSize=size_of(MONITORINFO)};
    GetMonitorInfoW(MonitorFromWindow(platform_hwnd, MONITOR_DEFAULTTOPRIMARY), *mi);

    GetWindowPlacement(platform_hwnd, *toggle_fullscreen_save_placement);
    SetWindowLongPtrW(platform_hwnd, GWL_STYLE, style & ~WS_OVERLAPPEDWINDOW);
    SetWindowPos(platform_hwnd, HWND_TOP, mi.rcMonitor.left, mi.rcMonitor.top,
      mi.rcMonitor.right - mi.rcMonitor.left,
      mi.rcMonitor.bottom - mi.rcMonitor.top,
      SWP_FRAMECHANGED);
  } else {
    SetWindowLongPtrW(platform_hwnd, GWL_STYLE, style | WS_OVERLAPPEDWINDOW);
    SetWindowPlacement(platform_hwnd, *toggle_fullscreen_save_placement);
    SetWindowPos(platform_hwnd, null, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE |
      SWP_NOZORDER | SWP_FRAMECHANGED);
  }
}

update_cursor_clip :: () #no_context {
  ClipCursor(null);
}

clear_held_keys :: () #no_context {

}

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

        platform_renderer_.resize();
      case WM_CREATE;
        platform_hwnd = hwnd;
        platform_hdc = GetDC(hwnd);

        dark_mode: s32 = xx true;
        DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, *dark_mode, 4);
        round_mode: s32 = DWMWCP_DONOTROUND;
        DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE, *round_mode, 4);

        set_platform_renderer(*d3d11_renderer, null);
        platform_renderer_.init();
      case WM_DESTROY;
        platform_renderer_.deinit();

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
              #if DEBUG if wParam == VK_ESCAPE DestroyWindow(platform_hwnd);
              if wParam == VK_F11 toggle_fullscreen();
              if wParam == VK_RETURN && alt toggle_fullscreen();
              #if DEBUG if wParam == VK_F6 switch_platform_renderer(ifx platform_renderer_ == *d3d11_renderer then *opengl_renderer else *d3d11_renderer, null);
            }
          }
        case WM_QUIT; break main_loop;
        case; DispatchMessageW(*msg);
      }
    }

    platform_renderer_.present();

    if sleep_is_granular {
      Sleep(1);
    }
  }

  if networking_supported WSACleanup();

  ExitProcess(0);
}

#program_export _fltused: s32;
