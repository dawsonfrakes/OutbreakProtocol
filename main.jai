#if OS == .WINDOWS {
  #import "OP_Windows";
  using kernel32;
  using user32;
  using ws2_32;
  using dwmapi;
  using winmm;

  utf16lez :: ($s: string) -> [s.count + 1]u16 {
    result: [s.count + 1]u16;
    for s result[it_index] = it;
    return result;
  }

  platform_hinstance: HINSTANCE;
  platform_hwnd: HWND;
  platform_hdc: HDC;
  platform_size: [2]u16;
  #if DEBUG {
    platform_stdout: HANDLE;
    platform_stderr: HANDLE;
  }

  platform_write :: (s: string, prefix: string, handle: HANDLE) #no_context {
    #if DEBUG {
      WriteFile(handle, prefix.data, cast(u32) prefix.count, null, null);
      WriteFile(handle, s.data, cast(u32) s.count, null, null);
      WriteFile(handle, "\n".data, 1, null, null);
    }
  }

  platform_log :: inline (s: string) {
    #if DEBUG platform_write(s, "INFO: ", platform_stdout);
  }

  platform_error :: inline (s: string) {
    #if DEBUG platform_write(s, "ERROR: ", platform_stderr);
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

  }

  clear_held_keys :: () #no_context {

  }

  #program_export
  WinMainCRTStartup :: () #c_call {
    platform_hinstance = GetModuleHandleW(null);

    #if DEBUG {
      AllocConsole();
      platform_stdout = GetStdHandle(STD_OUTPUT_HANDLE);
      platform_stderr = GetStdHandle(STD_ERROR_HANDLE);
    }

    wsadata: WSADATA = ---;
    networking_supported := WSAStartup(0x202, *wsadata) == 0;

    sleep_is_granular := timeBeginPeriod(1) == TIMERR_NOERROR;

    SetProcessDPIAware();
    wndclass: WNDCLASSEXW;
    wndclass.cbSize = size_of(WNDCLASSEXW);
    wndclass.style = CS_OWNDC;
    wndclass.lpfnWndProc = (hwnd: HWND, message: u32, wParam: u64, lParam: s64) -> s64 #c_call {
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
          platform_size = .[cast,no_check(u16)lParam, cast,no_check(u16) (lParam >> 16)];
        case WM_CREATE;
          platform_hwnd = hwnd;
          platform_hdc = GetDC(hwnd);

          dark_mode: s32 = xx true;
          DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, *dark_mode, size_of(type_of(dark_mode)));
          round_mode: s32 = DWMWCP_DONOTROUND;
          DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE, *round_mode, size_of(type_of(round_mode)));
        case WM_DESTROY;
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
            alt := message == WM_SYSKEYDOWN || message == WM_SYSKEYUP;
            sys := alt && lParam & (1 << 29) != 0;

            if !repeat && (!sys || alt || wParam == VK_MENU || wParam == VK_F4) {
              if pressed {
                if wParam == VK_F4 && alt DestroyWindow(platform_hwnd);
                if DEBUG && wParam == VK_ESCAPE DestroyWindow(platform_hwnd);
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

      if sleep_is_granular {
        Sleep(1);
      }
    }

    if networking_supported WSACleanup();

    ExitProcess(0);
  }

  #program_export
  memcpy :: (a: *void, b: *void, size: u64) -> *void #c_call {
    a8, b8 := cast(*u8) a, cast(*u8) b;
    for 1..size a8[it - 1] = b8[it - 1];
    return a;
  }

  #program_export
  memset :: (a: *void, b: s32, size: u64) -> *void #c_call {
    a8 := cast(*u8) a;
    for 1..size a8[it - 1] = cast,no_check(u8) b;
    return a;
  }
} else #if OS == .MACOS {
  #import "OP_macOS";

  platform_app: *NSApplication;
  platform_window: *NSWindow;

  #program_export "main"
  entry :: (argc: s32, argv: **u8) #c_call {
    NSApplicationLoad();
    init_objc_classes_and_selectors();

    platform_app = NSApplication.sharedApplication();
    NSApplication.setActivationPolicy(platform_app, .REGULAR);

    platform_window = NSWindow.init(NSWindow.alloc(), .{.{0, 0}, .{640, 480}}, .TITLED | .CLOSABLE | .RESIZABLE | .MINIATURIZABLE, .BUFFERED, false);
    // NSWindow.setTitle(platform_window, NSString.init(NSString.alloc(), "Outbreak Protocol"));
    NSWindow.makeKeyAndOrderFront(platform_window, null);

    NSApplication.run(platform_app);

    _exit(0);
  }
}
