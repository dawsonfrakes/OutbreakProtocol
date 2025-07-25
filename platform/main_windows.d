import basic;
mixin(import_dynamic("basic.windows", attributes: ["__gshared"], except: ["Kernel32"]));

__gshared {
  HINSTANCE platform_hinstance;
  HWND platform_hwnd;
  HDC platform_hdc;
  u16 platform_width;
  u16 platform_height;
}

void toggle_fullscreen() {
  __gshared WINDOWPLACEMENT save_placement = {WINDOWPLACEMENT.sizeof};
  ssize style = GetWindowLongPtrW(platform_hwnd, GWL_STYLE);
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

void update_cursor_clip() {
  ClipCursor(null);
}

void clear_held_keys() {

}

extern(Windows) noreturn WinMainCRTStartup() {
  auto User32_dll = LoadLibraryW("USER32.DLL");
  auto Ws2_32_dll = LoadLibraryW("WS2_32.DLL");
  auto Dwmapi_dll = LoadLibraryW("DWMAPI.DLL");
  auto Winmm_dll = LoadLibraryW("WINMM.DLL");
  static foreach (member; __traits(allMembers, basic.windows)) {
    static if (has_uda!(foreign, __traits(getMember, basic.windows, member)) &&
     !string_equal!(get_uda!(foreign, __traits(getMember, basic.windows, member)).library, "Kernel32"))
    {
      mixin(member~` = cast(typeof(`~member~`)) GetProcAddress(`~get_uda!(foreign, __traits(getMember, basic.windows, member)).library~`_dll, "`~member~`");`);
    }
  }

  platform_hinstance = GetModuleHandleW(null);

  WSADATA wsadata = void;
  bool networking_supported = WSAStartup && WSAStartup(0x202, &wsadata) == 0;

  bool sleep_is_granular = timeBeginPeriod && timeBeginPeriod(1) == TIMERR_NOERROR;

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
        if (tabbing_in) update_cursor_clip();
        else clear_held_keys();
        return 0;
      case WM_SIZE:
        platform_width = cast(u16) lParam;
        platform_height = cast(u16) (lParam >> 16);
        return 0;
      case WM_CREATE:
        platform_hwnd = hwnd;
        platform_hdc = GetDC(hwnd);

        if (DwmSetWindowAttribute) {
          s32 dark_mode = true;
          DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &dark_mode, dark_mode.sizeof);
          s32 round_mode = DWMWCP_DONOTROUND;
          DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE, &round_mode, round_mode.sizeof);
        }
        return 0;
      case WM_DESTROY:
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
        case WM_KEYDOWN:
        case WM_KEYUP:
        case WM_SYSKEYDOWN:
        case WM_SYSKEYUP:
          bool pressed = (lParam & (1 << 31)) == 0;
          bool repeat = pressed && (lParam & (1 << 30)) != 0;
          bool sys = message == WM_SYSKEYDOWN || message == WM_SYSKEYUP;
          bool alt = sys && (lParam & (1 << 29)) != 0;

          if (!repeat && (!sys || alt || wParam == VK_MENU || wParam == VK_F10)) {
            if (pressed) {
              if (wParam == VK_F4 && alt) DestroyWindow(platform_hwnd);
              if (wParam == VK_F11) toggle_fullscreen();
              if (wParam == VK_RETURN && alt) toggle_fullscreen();
            }
          }
          break;
        case WM_QUIT:
          break main_loop;
        default:
          DispatchMessageW(&msg);
      }
    }

    if (sleep_is_granular) {
      Sleep(1);
    }
  }

  if (networking_supported) WSACleanup();

  ExitProcess(0);
}

extern(Windows) s32 _fltused;

pragma(linkerDirective, "-subsystem:windows");
pragma(lib, "Kernel32");
