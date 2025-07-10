import basic;
import basic.windows;
static import game;

import renderer : Platform_Renderer;
import renderer_null : null_renderer;

__gshared {
  HINSTANCE platform_hinstance;
  HWND platform_hwnd;
  HDC platform_hdc;
  u16[2] platform_size;
  immutable(Platform_Renderer)* platform_renderer;
  debug {
    HANDLE platform_stdin;
    HANDLE platform_stdout;
    HANDLE platform_stderr;
  }
  version (DLL) {
    HMODULE platform_renderer_dll;
    const(wchar)[] platform_renderer_path; // NOTE(dfra): path and name are only valid if dll is not null.
    const(char)[] platform_renderer_name;
  }
}

version (DLL) {
  void set_window_title_to_platform_renderer_name() {
    if (!platform_renderer_dll) SetWindowTextA(platform_hwnd, "Outbreak Protocol [NULL]");
    else if (platform_renderer_name.length == "d3d11_renderer_".length) SetWindowTextA(platform_hwnd, "Outbreak Protocol [D3D11]"); // @LengthHack
    else if (platform_renderer_name.length == "opengl_renderer_".length) SetWindowTextA(platform_hwnd, "Outbreak Protocol [OpenGL]");
  }

  void set_platform_renderer_from_dll(const(wchar)[] path, const(char)[] name) {
    platform_renderer_dll = LoadLibraryW(path.ptr);
    if (platform_renderer_dll) {
      platform_renderer_path = path;
      platform_renderer_name = name;
      platform_renderer = cast(immutable(Platform_Renderer)*) GetProcAddress(platform_renderer_dll, name.ptr);
      set_window_title_to_platform_renderer_name();
      platform_log("Switching API");
    } else {
      platform_renderer = &null_renderer;
    }
  }

  void switch_to_renderer_in_dll(const(wchar)[] path, const(char)[] name) {
    platform_renderer.deinit();
    if (platform_renderer_dll) FreeLibrary(platform_renderer_dll);
    set_platform_renderer_from_dll(path, name);
    auto init_data = Platform_Renderer.Init_Data(hwnd: platform_hwnd, hdc: platform_hdc, size: platform_size, log: &platform_log);
    platform_renderer.init_(&init_data);
    platform_renderer.resize(platform_size);
  }

  void rebuild_dll_renderer() {
    if (!platform_renderer_dll) return;

    platform_renderer.deinit();
    if (platform_renderer_dll) FreeLibrary(platform_renderer_dll);
    { // do rebuild
      __gshared wchar[32] cmdline = "dmd -run build reload\0";
      STARTUPINFOW startinfo;
      startinfo.cb = STARTUPINFOW.sizeof;
      PROCESS_INFORMATION procinfo = void;
      if (CreateProcessW(null, cmdline.ptr, null, null, true, 0, null, null, &startinfo, &procinfo)) {
        WaitForSingleObject(procinfo.hProcess, INFINITE);
        CloseHandle(procinfo.hThread);
        CloseHandle(procinfo.hProcess);
      }
    }
    set_platform_renderer_from_dll(platform_renderer_path, platform_renderer_name);
    auto init_data = Platform_Renderer.Init_Data(hwnd: platform_hwnd, hdc: platform_hdc, size: platform_size, log: &platform_log);
    platform_renderer.init_(&init_data);
    platform_renderer.resize(platform_size);
  }
}

void platform_log(const(char)[] s) {
  debug {
    string prefix = "LOG: ";
    WriteFile(platform_stdout, prefix.ptr, cast(u32) prefix.length, null, null);
    WriteFile(platform_stdout, s.ptr, cast(u32) s.length, null, null);
    WriteFile(platform_stdout, "\n".ptr, 1, null, null);
  }
}

void switch_renderer(immutable(Platform_Renderer)* renderer) {
  platform_renderer.deinit();
  platform_renderer = renderer;
  auto init_data = Platform_Renderer.Init_Data(hwnd: platform_hwnd, hdc: platform_hdc, size: platform_size, log: &platform_log);
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

  debug {
    AllocConsole();
    platform_stdin = GetStdHandle(STD_INPUT_HANDLE);
    platform_stdout = GetStdHandle(STD_OUTPUT_HANDLE);
    platform_stderr = GetStdHandle(STD_ERROR_HANDLE);
  }

  bool sleep_is_granular = timeBeginPeriod(1) == TIMERR_NOERROR;

  WSADATA wsadata = void;
  bool networking_supported = WSAStartup(0x202, &wsadata) == 0;

  __gshared u8[64 * 1024 * 1024] buffer;
  HANDLE file = CreateFileA("models/sponza.obj", GENERIC_READ, 0, null, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, null);
  if (file != INVALID_HANDLE_VALUE) {
    s64 size = void;
    GetFileSizeEx(file, &size);
    u32 nread = void;
    ReadFile(file, buffer.ptr, cast(u32) size, &nread, null);
    CloseHandle(file);
  }

  usize game_memory_size = 1 * 1024 * 1024 * 1024;
  void* game_memory_ptr = VirtualAlloc(cast(void*) 0, game_memory_size, MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE);
  assert(game_memory_ptr);
  u8[] game_memory = (cast(u8*) game_memory_ptr)[0..game_memory_size];

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

        version (DLL) set_platform_renderer_from_dll(".build/renderer_d3d11.dll", "d3d11_renderer_");
        else {
          import renderer_d3d11 : d3d11_renderer;
          platform_renderer = &d3d11_renderer;
        }
        auto init_data = Platform_Renderer.Init_Data(hwnd: platform_hwnd, hdc: platform_hdc, size: platform_size, log: &platform_log);
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
              version (DLL) if (wParam == VK_F6) {
                if (platform_renderer_name.length == "opengl_renderer_".length) // @LengthHack
                  switch_to_renderer_in_dll(".build/renderer_d3d11.dll", "d3d11_renderer_");
                else
                  switch_to_renderer_in_dll(".build/renderer_opengl.dll", "opengl_renderer_");
              }
              version (DLL) if (wParam == VK_F7) rebuild_dll_renderer();
            }
          }
          break;
        case WM_QUIT:
          break main_loop;
        default:
          DispatchMessageW(&msg);
      }
    }

    game.Game_Renderer game_renderer;
    version (DLL) {
      HMODULE lib = LoadLibraryW(".build/game.dll");
      auto game_update_and_render = cast(typeof(game.game_update_and_render_)*) GetProcAddress(lib, "game_update_and_render_");
      game_update_and_render(game_memory, &game_renderer);
      FreeLibrary(lib);
    } else {
      game.game_update_and_render(game_memory, &game_renderer);
    }
    platform_renderer.present(&game_renderer);

    if (sleep_is_granular) {
      Sleep(1);
    }
  }

  if (networking_supported) WSACleanup();

  ExitProcess(0);
}

debug extern(C) noreturn _assert(const(char)* exp, const(char)* file, u32 line) {
  platform_log(file[0..strlen(file)]);
  platform_log(exp[0..strlen(exp)]);
  char buf = void;
  ReadFile(platform_stdin, &buf, 1, null, null);
  ExitProcess(1);
}

extern(C) int _fltused;

pragma(linkerDirective, "-subsystem:windows");
pragma(lib, "Kernel32");
pragma(lib, "User32");
pragma(lib, "Ws2_32");
pragma(lib, "Dwmapi");
pragma(lib, "Winmm");
