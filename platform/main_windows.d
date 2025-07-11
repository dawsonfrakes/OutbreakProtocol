import basic;
import basic.windows;
import platform.renderer;

__gshared {
  HINSTANCE platform_hinstance;
  HWND platform_hwnd;
  HDC platform_hdc;
  u16 platform_width;
  u16 platform_height;
  immutable(PlatformRenderer)* platform_renderer_;
  u32 platform_dynamic_renderer_index;
}

PlatformRenderer.Init get_renderer_init_data() {
  return PlatformRenderer.Init(hwnd: platform_hwnd, hdc: platform_hdc);
}

PlatformRenderer.Resize get_renderer_resize_data() {
  return PlatformRenderer.Resize(width: platform_width, height: platform_height);
}

struct DynamicRenderer {
  const(wchar)[] path;
  const(char)[] name;
  HMODULE loaded_lib = null;
}
__gshared DynamicRenderer[] dynamic_renderers = [
  DynamicRenderer("renderer_d3d11.dll", "d3d11_renderer"),
  DynamicRenderer("renderer_opengl.dll", "opengl_renderer"),
];

void set_platform_renderer(immutable(PlatformRenderer)* renderer) {
  platform_renderer_ = renderer;
  SetWindowTextA(platform_hwnd, renderer.pretty_name.ptr);
}

void switch_platform_renderer(immutable(PlatformRenderer)* renderer) {
  platform_renderer_.deinit();
  set_platform_renderer(renderer);
  platform_renderer_.init_(get_renderer_init_data());
  platform_renderer_.resize(get_renderer_resize_data());
}

immutable(PlatformRenderer)* get_renderer_from_dll(DynamicRenderer* dyn) {
  if (dyn.loaded_lib) FreeLibrary(dyn.loaded_lib);
  dyn.loaded_lib = LoadLibraryW(dyn.path.ptr);
  if (dyn.loaded_lib) return cast(immutable(PlatformRenderer)*) GetProcAddress(dyn.loaded_lib, dyn.name.ptr);
  return &null_renderer;
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
  platform_hinstance = GetModuleHandleW(null);

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
        if (tabbing_in) update_cursor_clip();
        else clear_held_keys();
        return 0;
      case WM_SIZE:
        platform_width = cast(u16) lParam;
        platform_height = cast(u16) (lParam >> 16);

        platform_renderer_.resize(get_renderer_resize_data());
        return 0;
      case WM_CREATE:
        platform_hwnd = hwnd;
        platform_hdc = GetDC(hwnd);

        s32 dark_mode = true;
        DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &dark_mode, dark_mode.sizeof);
        s32 round_mode = DWMWCP_DONOTROUND;
        DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE, &round_mode, round_mode.sizeof);

        version (DLL) {
          auto renderer = get_renderer_from_dll(&dynamic_renderers.ptr[0]);
          set_platform_renderer(renderer);
        } else {
          import platform.renderer_d3d11 : d3d11_renderer;
          set_platform_renderer(&d3d11_renderer);
        }
        platform_renderer_.init_(get_renderer_init_data());
        return 0;
      case WM_DESTROY:
        platform_renderer_.deinit();

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
              debug if (wParam == VK_F6) {
                platform_dynamic_renderer_index += 1;
                platform_dynamic_renderer_index %= dynamic_renderers.length;
                auto renderer = get_renderer_from_dll(&dynamic_renderers.ptr[platform_dynamic_renderer_index]);
                switch_platform_renderer(renderer);
              }
            }
          }
          break;
        case WM_QUIT:
          break main_loop;
        default:
          DispatchMessageW(&msg);
      }
    }

    platform_renderer_.present();

    if (sleep_is_granular) {
      Sleep(1);
    }
  }

  if (networking_supported) WSACleanup();

  ExitProcess(0);
}

extern(Windows) __gshared int _fltused;

pragma(linkerDirective, "-subsystem:windows");
pragma(lib, "Kernel32");
pragma(lib, "User32");
pragma(lib, "Ws2_32");
pragma(lib, "Dwmapi");
pragma(lib, "Winmm");
