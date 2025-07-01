import renderer;

version (Windows) {
  import basic.windows;

  __gshared HINSTANCE platform_hinstance;
  __gshared HWND platform_hwnd;
  __gshared HDC platform_hdc;
  __gshared ushort[2] platform_size;
  debug __gshared HANDLE platform_stdout;
  debug __gshared HANDLE platform_stderr;

  void platform_toggle_fullscreen() {
    __gshared WINDOWPLACEMENT save_placement = {WINDOWPLACEMENT.sizeof};
    const style = GetWindowLongPtrW(platform_hwnd, GWL_STYLE);
    if (style & WS_OVERLAPPEDWINDOW) {
      MONITORINFO mi = {MONITORINFO.sizeof};
      GetMonitorInfoW(MonitorFromWindow(platform_hwnd, MONITOR_DEFAULTTOPRIMARY), &mi);

      GetWindowPlacement(platform_hwnd, &save_placement);
      SetWindowLongPtrW(platform_hwnd, GWL_STYLE, style & ~WS_OVERLAPPEDWINDOW);
      SetWindowPos(platform_hwnd, HWND_TOP, mi.rcMonitor.left, mi.rcMonitor.top,
        mi.rcMonitor.right - mi.rcMonitor.left,
        mi.rcMonitor.bottom - mi.rcMonitor.top,
        SWP_FRAMECHANGED);
    } else {
      SetWindowLongPtrW(platform_hwnd, GWL_STYLE, style | WS_OVERLAPPEDWINDOW);
      SetWindowPlacement(platform_hwnd, &save_placement);
      SetWindowPos(platform_hwnd, null, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE |
        SWP_NOZORDER | SWP_FRAMECHANGED);
    }
  }

  void platform_update_cursor_clip() {
    ClipCursor(null);
  }

  void platform_clear_held_keys() {

  }

  extern(Windows) noreturn WinMainCRTStartup() {
    platform_hinstance = GetModuleHandleW(null);

    debug {
      AllocConsole();
      platform_stdout = GetStdHandle(STD_OUTPUT_HANDLE);
      platform_stderr = GetStdHandle(STD_ERROR_HANDLE);
    }

    WSADATA wsadata = void;
    bool networking_supported = WSAStartup(0x202, &wsadata) == 0;

    bool sleep_is_granular = timeBeginPeriod(1) == TIMERR_NOERROR;

    SetProcessDPIAware();
    WNDCLASSEXW wndclass;
    wndclass.cbSize = WNDCLASSEXW.sizeof;
    wndclass.style = CS_OWNDC;
    wndclass.lpfnWndProc = (hwnd, message, wParam, lParam) {
      switch (message) {
        case WM_PAINT:
          ValidateRect(hwnd, null);
          return 0;
        case WM_ERASEBKGND:
          return 1;
        case WM_ACTIVATEAPP:
          bool tabbing_in = wParam != 0;
          if (tabbing_in) platform_update_cursor_clip();
          else platform_clear_held_keys();
          return 0;
        case WM_SIZE:
          platform_size = [cast(ushort) lParam, cast(ushort) (lParam >> 16)];

          d3d11_renderer.resize();
          return 0;
        case WM_CREATE:
          platform_hwnd = hwnd;
          platform_hdc = GetDC(hwnd);

          int dark_mode = true;
          DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &dark_mode, dark_mode.sizeof);
          int round_mode = DWMWCP_DONOTROUND;
          DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE, &round_mode, round_mode.sizeof);

          d3d11_renderer.init();
          return 0;
        case WM_DESTROY:
          d3d11_renderer.deinit();

          PostQuitMessage(0);
          return 0;
        case WM_SYSCOMMAND:
          if (wParam == SC_KEYMENU) return 0;
          goto default;
        default:
          return DefWindowProcW(hwnd, message, wParam, lParam);
      }
    };
    wndclass.hInstance = platform_hinstance;
    wndclass.hIcon = LoadIconW(null, IDI_WARNING);
    wndclass.hCursor = LoadCursorW(null, IDC_CROSS);
    wndclass.lpszClassName = "A";
    RegisterClassExW(&wndclass);
    CreateWindowExW(0, wndclass.lpszClassName, "Outbreak Protocol",
      WS_OVERLAPPEDWINDOW | WS_VISIBLE,
      CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
      null, null, platform_hinstance, null);

    main_loop: while (true) {
      MSG msg = void;
      while (PeekMessageW(&msg, null, 0, 0, PM_REMOVE)) {
        TranslateMessage(&msg);
        with (msg) switch (message) {
          case WM_KEYDOWN: goto case;
          case WM_KEYUP: goto case;
          case WM_SYSKEYDOWN: goto case;
          case WM_SYSKEYUP:
            bool pressed = (lParam & (1 << 31)) == 0;
            bool repeat = pressed && (lParam & (1 << 30)) != 0;
            bool sys = message == WM_SYSKEYDOWN || message == WM_SYSKEYUP;
            bool alt = sys && (lParam & (1 << 29)) != 0;

            if (!repeat && (!sys || alt || wParam == VK_MENU || wParam == VK_F10)) {
              if (pressed) {
                if (wParam == VK_F4 && alt) DestroyWindow(platform_hwnd);
                debug if (wParam == VK_ESCAPE) DestroyWindow(platform_hwnd);
                if (wParam == VK_F11) platform_toggle_fullscreen();
                if (wParam == VK_RETURN && alt) platform_toggle_fullscreen();
              }
            }
            break;
          case WM_QUIT:
            break main_loop;
          default:
            DispatchMessageW(&msg);
        }
      }

      d3d11_renderer.present();

      if (sleep_is_granular) {
        Sleep(1);
      }
    }

    if (networking_supported) WSACleanup();

    ExitProcess(0);
  }

  pragma(linkerDirective, "-subsystem:windows");
  pragma(lib, "kernel32");
  pragma(lib, "user32");
  pragma(lib, "ws2_32");
  pragma(lib, "dwmapi");
  pragma(lib, "winmm");
}

version (OSX) {
  import basic.macos;

  __gshared NSApplication* platform_app;

  extern(C) noreturn main() {
    NSApplicationLoad();
    init_objc_classes_and_selectors();

    platform_app = NSApplication.sharedApplication();
    platform_app.setActivationPolicy(NSApplication.ActivationPolicy.REGULAR);

    _exit(0);
  }

  pragma(linkerDirective, "-framework", "AppKit");
}

version (WebAssembly) {
  import ldc.attributes : llvmAttr;

  @llvmAttr("wasm-import-name", "console_log") extern(C) void console_log(const(char)[]);

  extern(C) void _start() {
    console_log("Hello, world!\n");
  }
}
