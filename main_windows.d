import basic;
import basic.windows;

import renderer : Platform_Renderer;
import renderer_null : null_renderer;

__gshared {
  HINSTANCE platform_hinstance;
  HWND platform_hwnd;
  HDC platform_hdc;
  u16[2] platform_size;
  immutable(Platform_Renderer)* platform_renderer;
  debug {
    HMODULE platform_renderer_dll;
    const(wchar)[] platform_renderer_path; // NOTE(dfra): path and name are only valid if dll is not null.
    const(char)[] platform_renderer_name;
  }
}

debug {
  void set_window_title_to_platform_renderer_name() {
    if (!platform_renderer_dll) SetWindowTextA(platform_hwnd, "Outbreak Protocol [NULL]");
    else if (platform_renderer_name.length == "d3d11_renderer".length) SetWindowTextA(platform_hwnd, "Outbreak Protocol [D3D11]"); // @LengthHack
    else if (platform_renderer_name.length == "opengl_renderer".length) SetWindowTextA(platform_hwnd, "Outbreak Protocol [OpenGL]");
  }

  void set_platform_renderer_from_dll(const(wchar)[] path, const(char)[] name) {
    platform_renderer_dll = LoadLibraryW(path.ptr);
    if (platform_renderer_dll) {
      platform_renderer_path = path;
      platform_renderer_name = name;
      platform_renderer = cast(immutable(Platform_Renderer)*) GetProcAddress(platform_renderer_dll, name.ptr);
      set_window_title_to_platform_renderer_name();
    } else {
      platform_renderer = &null_renderer;
    }
  }

  void switch_to_renderer_in_dll(const(wchar)[] path, const(char)[] name) {
    platform_renderer.deinit();
    if (platform_renderer_dll) FreeLibrary(platform_renderer_dll);
    set_platform_renderer_from_dll(path, name);
    auto init_data = Platform_Renderer.Init_Data(hwnd: platform_hwnd, size: platform_size);
    platform_renderer.init_(&init_data);
    platform_renderer.resize(platform_size);
  }

  void reload_dll_renderer() {
    if (!platform_renderer_dll) return;

    platform_renderer.deinit();
    if (platform_renderer_dll) FreeLibrary(platform_renderer_dll);
    // TODO(dfra): rebuild here!
    set_platform_renderer_from_dll(platform_renderer_path, platform_renderer_name);
    auto init_data = Platform_Renderer.Init_Data(hwnd: platform_hwnd, size: platform_size);
    platform_renderer.init_(&init_data);
    platform_renderer.resize(platform_size);
  }
}

void switch_renderer(immutable(Platform_Renderer)* renderer) {
  platform_renderer.deinit();
  platform_renderer = renderer;
  auto init_data = Platform_Renderer.Init_Data(hwnd: platform_hwnd, size: platform_size);
  platform_renderer.init_(&init_data);
  platform_renderer.resize(platform_size);
}

void toggle_fullscreen() {
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

void update_cursor_clip() {
  ClipCursor(null);
}

void clear_held_keys() {

}

extern(Windows) noreturn WinMainCRTStartup() {
  platform_hinstance = GetModuleHandleW(null);

  bool sleep_is_granular = timeBeginPeriod(1) == TIMERR_NOERROR;

  WSADATA wsadata = void;
  bool networking_supported = WSAStartup(0x202, &wsadata) == 0;

  SetProcessDPIAware();
  WNDCLASSEXW wndclass;
  wndclass.cbSize = WNDCLASSEXW.sizeof;
  wndclass.style = CS_OWNDC;
  wndclass.lpfnWndProc = (hwnd, message, wParam, lParam) {
    switch (message) {
      case WM_INPUT:
        RAWINPUT raw_input = void;
        u32 raw_input_size = raw_input.sizeof;
        GetRawInputData(cast(HRAWINPUT) lParam, RID_INPUT, &raw_input, &raw_input_size, RAWINPUTHEADER.sizeof);
        return 0;
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
        platform_size = [cast(u16) lParam, cast(u16) (lParam >>> 16)];

        platform_renderer.resize(platform_size);
        return 0;
      case WM_CREATE:
        platform_hwnd = hwnd;
        platform_hdc = GetDC(hwnd);

        RAWINPUTDEVICE[1] raw_input_devices;
        raw_input_devices[0].usUsagePage = HID_USAGE_PAGE_GENERIC;
        raw_input_devices[0].usUsage = HID_USAGE_GENERIC_MOUSE;
        RegisterRawInputDevices(raw_input_devices.ptr, raw_input_devices.length, raw_input_devices[0].sizeof);

        s32 dark_mode = true;
        DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &dark_mode, dark_mode.sizeof);
        s32 round_mode = DWMWCP_DONOTROUND;
        DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE, &round_mode, round_mode.sizeof);

        debug set_platform_renderer_from_dll(".build/renderer_d3d11.dll", "d3d11_renderer");
        else {
          import renderer_d3d11 : d3d11_renderer;
          platform_renderer = &d3d11_renderer;
        }
        auto init_data = Platform_Renderer.Init_Data(hwnd: platform_hwnd, size: platform_size);
        platform_renderer.init_(&init_data);
        return 0;
      case WM_DESTROY:
        platform_renderer.deinit();

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
              debug if (wParam == VK_ESCAPE) DestroyWindow(platform_hwnd);
              if (wParam == VK_F11) toggle_fullscreen();
              if (wParam == VK_RETURN && alt) toggle_fullscreen();
              debug if (wParam == VK_F6) {
                if (platform_renderer_name.length == "opengl_renderer".length) // @LengthHack
                  switch_to_renderer_in_dll(".build/renderer_d3d11.dll", "d3d11_renderer");
                else
                  switch_to_renderer_in_dll(".build/renderer_opengl.dll", "opengl_renderer");
              }
              debug if (wParam == VK_F7) reload_dll_renderer();
            }
          }
          break;
        case WM_QUIT:
          break main_loop;
        default:
          DispatchMessageW(&msg);
      }
    }

    platform_renderer.present();

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
