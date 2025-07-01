#if OS == .WINDOWS {
  #import "OP_Windows";
  using kernel32;
  using user32;

  utf16lez :: ($s: string) -> [s.count + 1]u16 {
    result: [s.count + 1]u16;
    for s result[it_index] = it;
    return result;
  }

  platform_hinstance: HINSTANCE;
  platform_hwnd: HWND;
  platform_hdc: HDC;
  platform_size: [2]u16;

  #program_export
  WinMainCRTStartup :: () #c_call {
    platform_hinstance = GetModuleHandleW(null);

    SetProcessDPIAware();
    wndclass: WNDCLASSEXW;
    wndclass.cbSize = size_of(WNDCLASSEXW);
    wndclass.style = CS_OWNDC;
    wndclass.lpfnWndProc = (hwnd: HWND, message: u32, wParam: u64, lParam: s64) -> s64 #c_call {
      if message == {
        case WM_CREATE;
          platform_hwnd = hwnd;
          platform_hdc = GetDC(hwnd);
        case WM_DESTROY;
          PostQuitMessage(0);
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
          case WM_QUIT;
            break main_loop;
          case;
            DispatchMessageW(*msg);
        }
      }
    }

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
