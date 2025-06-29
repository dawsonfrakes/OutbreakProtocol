version (Windows) version = D3D11;

version (OSX) {
  import basic.macos;

  __gshared NSApplication* platform_app;

  extern(C) noreturn main() {
    NSApplicationLoad();
    platform_app = NSApplication.sharedApplication();
    platform_app.setActivationPolicy(NSApplication.ActivationPolicy.REGULAR);

    _exit(0);
  }

  pragma(linkerDirective, "-framework", "AppKit");
}

version (D3D11) {
  import basic.windows.d3d11;
  import basic.windows.dxgi;

  struct D3D11Data {
    bool initted;
    IDXGISwapChain* swapchain;
    ID3D11Device* device;
    ID3D11DeviceContext* ctx;
    ID3D11Texture2D* backbuffer;
    ID3D11RenderTargetView* backbuffer_view;
  }

  __gshared D3D11Data d3d11;

  void d3d11_init() {
    HRESULT hr = void;

    DXGI_SWAP_CHAIN_DESC swapchain_descriptor;
    swapchain_descriptor.BufferDesc.Width = platform_width;
    swapchain_descriptor.BufferDesc.Height = platform_height;
    swapchain_descriptor.BufferDesc.RefreshRate.Numerator = 60;
    swapchain_descriptor.BufferDesc.RefreshRate.Denominator = 1;
    swapchain_descriptor.BufferDesc.Format = DXGI_FORMAT.R8G8B8A8_UNORM;
    swapchain_descriptor.SampleDesc.Count = 1;
    swapchain_descriptor.BufferUsage = DXGI_USAGE.RENDER_TARGET_OUTPUT;
    swapchain_descriptor.BufferCount = 1;
    swapchain_descriptor.OutputWindow = platform_hwnd;
    swapchain_descriptor.Windowed = true;
    // swapchain_descriptor.SwapEffect = DXGI_SWAP_EFFECT.FLIP_DISCARD;
    swapchain_descriptor.Flags = DXGI_SWAP_CHAIN_FLAG.ALLOW_MODE_SWITCH;
    hr = D3D11CreateDeviceAndSwapChain(null, D3D_DRIVER_TYPE.HARDWARE, null, D3D11_CREATE_DEVICE_FLAG.DEBUG, null, 0, D3D11_SDK_VERSION, &swapchain_descriptor,
      &d3d11.swapchain, &d3d11.device, null, &d3d11.ctx);
    if (hr < 0) goto error;

    hr = d3d11.swapchain.GetBuffer(d3d11.swapchain, 0, &ID3D11Texture2D.uuidof, cast(void**) &d3d11.backbuffer);
    if (hr < 0) goto error;
    hr = d3d11.device.CreateRenderTargetView(d3d11.device, cast(ID3D11Resource*) d3d11.backbuffer, null, &d3d11.backbuffer_view);
    if (hr < 0) goto error;

    d3d11.initted = true;
    return;
  error:
    d3d11_deinit();
  }

  void d3d11_deinit() {
    if (d3d11.backbuffer_view) d3d11.backbuffer_view.Release(d3d11.backbuffer_view);
    if (d3d11.ctx) d3d11.ctx.Release(d3d11.ctx);
    if (d3d11.device) d3d11.device.Release(d3d11.device);
    if (d3d11.swapchain) d3d11.swapchain.Release(d3d11.swapchain);
    d3d11 = d3d11.init;
  }

  void d3d11_resize() {

  }

  void d3d11_present() {
    if (!d3d11.initted) return;
    d3d11.ctx.ClearRenderTargetView(d3d11.ctx, d3d11.backbuffer_view, [0.6, 0.2, 0.2, 1.0]);
    d3d11.swapchain.Present(d3d11.swapchain, 0, 0);
  }
}

version (Windows) {
  import basic.windows;

  __gshared HINSTANCE platform_hinstance;
  __gshared HWND platform_hwnd;
  __gshared HDC platform_hdc;
  __gshared ushort platform_width;
  __gshared ushort platform_height;

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

  extern(Windows) noreturn WinMainCRTStartup() {
    platform_hinstance = GetModuleHandleW(null);

    SetProcessDPIAware();
    WNDCLASSEXW wndclass;
    wndclass.cbSize = WNDCLASSEXW.sizeof;
    wndclass.style = CS_OWNDC;
    wndclass.lpfnWndProc = (hwnd, message, wParam, lParam) {
      switch (message) {
        case WM_SIZE:
          platform_width = cast(ushort) lParam;
          platform_height = cast(ushort) (lParam >>> 16);

          d3d11_resize();
          return 0;
        case WM_CREATE:
          platform_hwnd = hwnd;
          platform_hdc = GetDC(hwnd);

          int dark_mode = true;
          DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &dark_mode, dark_mode.sizeof);
          int round_mode = DWMWCP_DONOTROUND;
          DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE, &round_mode, round_mode.sizeof);

          d3d11_init();
          return 0;
        case WM_DESTROY: d3d11_deinit(); PostQuitMessage(0); return 0;
        case WM_SYSCOMMAND: if (wParam == SC_KEYMENU) return 0; goto default;
        default: return DefWindowProcW(hwnd, message, wParam, lParam);
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
          case WM_QUIT: break main_loop;
          default: DispatchMessageW(&msg);
        }
      }

      d3d11_present();
    }

    ExitProcess(0);
  }

  extern(C) int _fltused;
  pragma(linkerDirective, "-subsystem:windows");
  pragma(lib, "kernel32");
  pragma(lib, "user32");
  pragma(lib, "gdi32");
  pragma(lib, "dwmapi");
  pragma(lib, "d3d11");
}

version (D_BetterC) {
  extern(C) float* _memsetFloat(float* p, float value, size_t count) {
    float* pstart = p;
    for (float* ptop = &p[count]; p < ptop; p++) *p = value;
    return pstart;
  }
}
