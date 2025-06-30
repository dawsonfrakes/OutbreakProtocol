#if !defined(OP_DEBUG)
  #error Are we debug?
#endif

#if defined(_MSC_VER)
  #define OP_COMPILER_MSVC 1
#else
  #define OP_COMPILER_MSVC 0
#endif

#if defined(__clang__)
  #define OP_COMPILER_CLANG 1
#else
  #define OP_COMPILER_CLANG 0
#endif

#if !OP_COMPILER_CLANG && defined(__GNUC__)
  #define OP_COMPILER_GCC 1
#else
  #define OP_COMPILER_GCC 0
#endif

#if defined(__x86_64__) || defined(_M_AMD64)
  #define OP_CPU_AMD64 1
#else
  #define OP_CPU_AMD64 0
#endif

#if defined(__aarch64__) || defined(_M_ARM64)
  #define OP_CPU_ARM64 1
#else
  #define OP_CPU_ARM64 0
#endif

#if defined(__wasm32__)
  #define OP_CPU_WASM32 1
#else
  #define OP_CPU_WASM32 0
#endif

#if defined(_WIN32) || defined(__WIN32__)
  #define OP_OS_WINDOWS 1
#else
  #define OP_OS_WINDOWS 0
#endif

#if defined(__APPLE__) && defined(__MACH__)
  #define OP_OS_MACOS 1
#else
  #define OP_OS_MACOS 0
#endif

#if defined(__linux__)
  #define OP_OS_LINUX 1
#else
  #define OP_OS_LINUX 0
#endif

constexpr auto null = nullptr;
#define cast(T, V) ((T) (V))

#if OP_CPU_AMD64 || OP_CPU_ARM64
  typedef signed char S8;
  typedef short S16;
  typedef int S32;
  typedef long long S64;
  typedef long long SSize;

  typedef unsigned char U8;
  typedef unsigned short U16;
  typedef unsigned int U32;
  typedef unsigned long long U64;
  typedef unsigned long long USize;
#endif

typedef U8 B8;
typedef U32 B32;

typedef float F32;
typedef double F64;

#define OP_RENDERER_NULL (0)
#define OP_RENDERER_D3D11 (1 << 0)
#define OP_RENDERER_OPENGL (1 << 1)

#if OP_OS_WINDOWS
  #define WIN32_LEAN_AND_MEAN
  #define UNICODE
  #include <Windows.h>
  #include <Winsock2.h>
  #include <Dwmapi.h>
  #include <mmsystem.h>

  #define OP_RENDERERS (OP_RENDERER_NULL | OP_RENDERER_D3D11 | OP_RENDERER_OPENGL)

  static HINSTANCE platform_hinstance;
  static HWND platform_hwnd;
  static HDC platform_hdc;
  static U16 platform_width;
  static U16 platform_height;
#endif

#if OP_RENDERERS & OP_RENDERER_D3D11
  #include <D3D11.h>
  #include <dxgi.h>

  struct {
    B8 initted;
    IDXGISwapChain* swapchain;
    ID3D11Device* device;
    ID3D11DeviceContext* ctx;
    ID3D11RenderTargetView* backbuffer_view;
  } d3d11;

  static void d3d11_deinit(void);

  static void d3d11_init(void) {
    {
      HRESULT hr;

      DXGI_SWAP_CHAIN_DESC swapchain_descriptor = {};
      swapchain_descriptor.BufferDesc.Width = platform_width;
      swapchain_descriptor.BufferDesc.Height = platform_height;
      swapchain_descriptor.BufferDesc.RefreshRate.Numerator = 144;
      swapchain_descriptor.BufferDesc.RefreshRate.Denominator = 1;
      swapchain_descriptor.BufferDesc.Format = DXGI_FORMAT_R8G8B8A8_UNORM;
      swapchain_descriptor.SampleDesc.Count = 8;
      swapchain_descriptor.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT;
      swapchain_descriptor.BufferCount = 1;
      swapchain_descriptor.OutputWindow = platform_hwnd;
      swapchain_descriptor.Windowed = true;
      swapchain_descriptor.Flags = DXGI_SWAP_CHAIN_FLAG_ALLOW_MODE_SWITCH;
      hr = D3D11CreateDeviceAndSwapChain(null, D3D_DRIVER_TYPE_HARDWARE, null,
        D3D11_CREATE_DEVICE_DEBUG, null, 0, D3D11_SDK_VERSION,
        &swapchain_descriptor, &d3d11.swapchain, &d3d11.device, null, &d3d11.ctx);
      if (hr < 0) goto error;

      IDXGIDevice* dxgi_device;
      if (d3d11.swapchain->GetDevice(__uuidof(IDXGIDevice), cast(void**, &dxgi_device)) >= 0) {
        IDXGIAdapter* dxgi_adapter;
        if (dxgi_device->GetAdapter(&dxgi_adapter) >= 0) {
          IDXGIFactory* dxgi_factory;
          if (dxgi_adapter->GetParent(__uuidof(IDXGIFactory), cast(void**, &dxgi_factory)) >= 0) {
            dxgi_factory->MakeWindowAssociation(platform_hwnd, DXGI_MWA_NO_ALT_ENTER);
            dxgi_factory->Release();
          }
          dxgi_adapter->Release();
        }
        dxgi_device->Release();
      }

      d3d11.initted = true;
    }
    return;
  error:
    d3d11_deinit();
  }

  static void d3d11_deinit(void) {
    if (d3d11.backbuffer_view) d3d11.backbuffer_view->Release();
    if (d3d11.ctx) d3d11.ctx->Release();
    if (d3d11.device) d3d11.device->Release();
    if (d3d11.swapchain) d3d11.swapchain->Release();
    d3d11 = {};
  }

  static void d3d11_resize(void) {
    if (!d3d11.initted) return;
    ID3D11Texture2D* backbuffer = null;
    {
      HRESULT hr;

      if (d3d11.backbuffer_view) d3d11.backbuffer_view->Release();

      hr = d3d11.swapchain->ResizeBuffers(1, platform_width, platform_height,
        DXGI_FORMAT_UNKNOWN, DXGI_SWAP_CHAIN_FLAG_ALLOW_MODE_SWITCH);
      if (hr < 0) goto error;

      hr = d3d11.swapchain->GetBuffer(0, __uuidof(ID3D11Texture2D), cast(void**, &backbuffer));
      if (hr < 0) goto error;

      hr = d3d11.device->CreateRenderTargetView(backbuffer, null, &d3d11.backbuffer_view);
      if (hr < 0) goto error;

      backbuffer->Release();
      backbuffer = null;
    }
    return;
  error:
    if (backbuffer) backbuffer->Release();
    d3d11_deinit();
  }

  static void d3d11_present(void) {
    if (!d3d11.initted) return;
    F32 clear_color0[4] = {0.6f, 0.2f, 0.2f, 1.0f};
    d3d11.ctx->ClearRenderTargetView(d3d11.backbuffer_view, clear_color0);
    d3d11.swapchain->Present(0, 0);
  }
#endif

#if OP_OS_WINDOWS
  static void platform_toggle_fullscreen(void) {
    static WINDOWPLACEMENT save_placement = {sizeof(WINDOWPLACEMENT)};
    SSize style = GetWindowLongPtrW(platform_hwnd, GWL_STYLE);
    if (style & WS_OVERLAPPEDWINDOW) {
      MONITORINFO mi = {sizeof(MONITORINFO)};
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

  static void platform_update_cursor_clip(void) {
    ClipCursor(null);
  }

  static void platform_clear_held_keys(void) {

  }

  extern "C" [[noreturn]] void WINAPI WinMainCRTStartup(void) {
    platform_hinstance = GetModuleHandleW(null);

    WSADATA wsadata;
    B8 networking_supported = WSAStartup(0x202, &wsadata) == 0;

    B8 sleep_is_granular = timeBeginPeriod(1) == TIMERR_NOERROR;

    SetProcessDPIAware();
    WNDCLASSEXW wndclass = {};
    wndclass.cbSize = sizeof(WNDCLASSEXW);
    wndclass.style = CS_OWNDC;
    wndclass.lpfnWndProc = [](HWND hwnd, U32 message, USize wParam, SSize lParam) -> SSize {
      switch (message) {
        case WM_PAINT:
          ValidateRect(hwnd, null);
          return 0;
        case WM_ERASEBKGND:
          return 1;
        case WM_ACTIVATEAPP: {
          B8 tabbing_in = wParam != 0;
          if (tabbing_in) platform_update_cursor_clip();
          else platform_clear_held_keys();
          return 0;
        }
        case WM_SIZE:
          platform_width = cast(U16, lParam);
          platform_height = cast(U16, lParam >> 16);

          d3d11_resize();
          return 0;
        case WM_CREATE: {
          platform_hwnd = hwnd;
          platform_hdc = GetDC(hwnd);

          B32 dark_mode = true;
          DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &dark_mode, sizeof(dark_mode));
          B32 round_mode = DWMWCP_DONOTROUND;
          DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE, &round_mode, sizeof(round_mode));

          d3d11_init();
          return 0;
        }
        case WM_DESTROY:
          d3d11_deinit();

          PostQuitMessage(0);
          return 0;
        case WM_SYSCOMMAND:
          if (wParam == SC_KEYMENU) return 0;
          // fallthrough
        default:
          return DefWindowProcW(hwnd, message, wParam, lParam);
      }
    };
    wndclass.hInstance = platform_hinstance;
    wndclass.hIcon = LoadIconW(null, IDI_WARNING);
    wndclass.hCursor = LoadCursorW(null, IDC_CROSS);
    wndclass.lpszClassName = L"A";
    RegisterClassExW(&wndclass);
    CreateWindowExW(0, wndclass.lpszClassName, L"Outbreak Protocol",
      WS_OVERLAPPEDWINDOW | WS_VISIBLE,
      CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
      null, null, platform_hinstance, null);

    for (;;) {
      MSG msg;
      while (PeekMessageW(&msg, null, 0, 0, PM_REMOVE)) {
        TranslateMessage(&msg);
        switch (msg.message) {
          case WM_KEYDOWN: // fallthrough
          case WM_KEYUP: // fallthrough
          case WM_SYSKEYDOWN: // fallthrough
          case WM_SYSKEYUP: {
            B8 pressed = (msg.lParam & (1 << 31)) == 0;
            B8 repeat = pressed && (msg.lParam & (1 << 30)) != 0;
            B8 sys = msg.message == WM_SYSKEYDOWN || msg.message == WM_SYSKEYUP;
            B8 alt = sys && (msg.lParam & (1 << 29)) != 0;

            if (!repeat && (!sys || alt || msg.wParam == VK_MENU || msg.wParam == VK_F10)) {
              if (pressed) {
                if (msg.wParam == VK_F4 && alt) DestroyWindow(platform_hwnd);
                if (OP_DEBUG && msg.wParam == VK_ESCAPE) DestroyWindow(platform_hwnd);
                if (msg.wParam == VK_F11) platform_toggle_fullscreen();
                if (msg.wParam == VK_RETURN && alt) platform_toggle_fullscreen();
              }
            }
            break;
          }
          case WM_QUIT:
            goto main_loop_end;
          default:
            DispatchMessageW(&msg);
        }
      }

      d3d11_present();

      if (sleep_is_granular) {
        Sleep(1);
      }
    }
  main_loop_end:

    if (networking_supported) WSACleanup();

    ExitProcess(0);
  }

  extern "C" int _fltused = 0;
#endif

#if OP_OS_MACOS
  #import "AppKit/AppKit.h"

  static NSApplication* platform_app;
  static NSWindow* platform_window;

  extern "C" [[noreturn]] void _start() __asm__("_main");
  extern "C" [[noreturn]] void _start() {
    NSApplicationLoad();

    platform_app = [NSApplication sharedApplication];
    [platform_app setActivationPolicy:NSApplicationActivationPolicyRegular];

    platform_window = [[NSWindow alloc]
      initWithContentRect:CGRect{CGPoint{0, 0}, CGSize{640, 480}}
      styleMask:NSWindowStyleMaskTitled|NSWindowStyleMaskClosable|NSWindowStyleMaskResizable
      backing:NSBackingStoreBuffered defer:NO];
    [platform_window setTitle:@"Outbreak Protocol"];
    [platform_window makeKeyAndOrderFront:nil];
    [platform_app run];

    _exit(0);
  }
#endif
