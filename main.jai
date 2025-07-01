Platform_Renderer_Tag :: enum_flags u32 {
  NULL :: 0;
  D3D11 :: 1 << 0;
  OPENGL :: 1 << 1;
}

null_renderer :: struct {
  init :: () #no_context {}
  deinit :: () #no_context {}
  resize :: () #no_context {}
  present :: () #no_context {}
}

#if OS == {
  case .WINDOWS; RENDERERS :: Platform_Renderer_Tag.NULL | .D3D11 | .OPENGL;
  case;          RENDERERS :: Platform_Renderer_Tag.NULL;
}

#if RENDERERS & .D3D11 {
  #import "OP_Windows";
  using d3d11;
  using dxgi;

  d3dobj: struct {
    initted: bool;
    swapchain: *IDXGISwapChain;
    device: *ID3D11Device;
    ctx: *ID3D11DeviceContext;
  }

  d3d11_init :: () #no_context {
    hr: HRESULT = ---;
    while label := true {
      swapchain_descriptor: DXGI_SWAP_CHAIN_DESC;
      swapchain_descriptor.BufferDesc.Width = platform_size[0];
      swapchain_descriptor.BufferDesc.Height = platform_size[1];
      swapchain_descriptor.BufferDesc.RefreshRate.Numerator = 60;
      swapchain_descriptor.BufferDesc.RefreshRate.Denominator = 1;
      swapchain_descriptor.BufferDesc.Format = .R8G8B8A8_UNORM;
      swapchain_descriptor.SampleDesc.Count = 8;
      swapchain_descriptor.BufferUsage = .RENDER_TARGET_OUTPUT;
      swapchain_descriptor.BufferCount = 1;
      swapchain_descriptor.OutputWindow = platform_hwnd;
      swapchain_descriptor.Windowed = xx true;
      swapchain_descriptor.Flags = xx DXGI_SWAP_CHAIN_FLAG.ALLOW_MODE_SWITCH;
      hr = D3D11CreateDeviceAndSwapChain(null, .HARDWARE, null,
        xx D3D11_CREATE_DEVICE_FLAG.DEBUG,
        null, 0, D3D11_SDK_VERSION, *swapchain_descriptor,
        *d3dobj.swapchain, *d3dobj.device, null, *d3dobj.ctx);
      if hr < 0 break label;

      d3dobj.initted = true;
      return;
    }
    d3d11_deinit();
  }

  d3d11_deinit :: () #no_context {
    if d3dobj.ctx d3dobj.ctx.Release(d3dobj.ctx);
    if d3dobj.device d3dobj.device.Release(d3dobj.device);
    if d3dobj.swapchain d3dobj.swapchain.Release(d3dobj.swapchain);
    d3dobj = .{};
  }

  d3d11_resize :: () #no_context {

  }

  d3d11_present :: () #no_context {
    if !d3dobj.initted return;
    d3dobj.swapchain.Present(d3dobj.swapchain, 0, 0);
  }

  d3d11_renderer :: struct {
    init :: d3d11_init;
    deinit :: d3d11_deinit;
    resize :: d3d11_resize;
    present :: d3d11_present;
  }
}

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
  #if RENDERERS & .D3D11 platform_renderer :: d3d11_renderer;
  else platform_renderer :: null_renderer;

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

          platform_renderer.resize();
        case WM_CREATE;
          platform_hwnd = hwnd;
          platform_hdc = GetDC(hwnd);

          dark_mode: s32 = xx true;
          DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, *dark_mode, size_of(type_of(dark_mode)));
          round_mode: s32 = DWMWCP_DONOTROUND;
          DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE, *round_mode, size_of(type_of(round_mode)));

          platform_renderer.init();
        case WM_DESTROY;
          platform_renderer.deinit();

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

      platform_renderer.present();

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
