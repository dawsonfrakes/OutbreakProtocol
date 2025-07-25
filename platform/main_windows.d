import basic;
mixin(import_dynamic("basic.windows", attributes: ["__gshared"], except: ["Kernel32"]));

__gshared {
  HINSTANCE platform_hinstance;
  HWND platform_hwnd;
  HDC platform_hdc;
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
