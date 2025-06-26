#if !defined(OP_DEBUG)
#define OP_DEBUG 1
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

#define null nullptr
#define size_of(T) sizeof(T)
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
#elif OP_CPU_WASM32
typedef signed char S8;
typedef short S16;
typedef int S32;
typedef int SSize;

typedef unsigned char U8;
typedef unsigned short U16;
typedef unsigned int U32;
typedef unsigned int USize;
#endif

typedef U8 B8;
typedef U32 B32;

typedef float F32;
typedef double F64;

template<typename T>
struct Array {
  USize count;
  T *data;

  Array(USize count, T const *data) : count(count), data(cast(T *, data)) {}
  template<USize N> Array(T const (&x)[N]) : count(N), data(cast(T *, x)) {}
};

struct String {
  USize count;
  char *data;

  String(USize count, char const *data) : count(count), data(cast(char *, data)) {}
  template<USize N> String(char const (&x)[N]) : count(N - 1), data(cast(char *, x)) {}
};

#define OP_RENDERER_NULL   (0 << 0)
#define OP_RENDERER_D3D11  (1 << 0)
#define OP_RENDERER_OPENGL (1 << 1)

#if !defined(OP_RENDERERS)
#if OP_OS_WINDOWS
#define OP_RENDERERS (OP_RENDERER_NULL | OP_RENDERER_D3D11)
#else
#define OP_RENDERERS (OP_RENDERER_NULL)
#endif
#endif

struct Platform_Renderer {
  void (*init)(void);
  void (*deinit)(void);
  void (*resize)(void);
  void (*present)(void);
};

static void null_renderer_proc(void) {}
static Platform_Renderer null_renderer = {
  null_renderer_proc,
  null_renderer_proc,
  null_renderer_proc,
  null_renderer_proc,
};

#if OP_OS_WINDOWS
#define WIN32_LEAN_AND_MEAN
#define UNICODE
#include <Windows.h>
#include <Dwmapi.h>
#include <mmsystem.h>
#endif

#if OP_OS_WINDOWS
static HINSTANCE platform_hinstance;
static HWND platform_hwnd;
static HDC platform_hdc;
static U16 platform_width;
static U16 platform_height;
static Platform_Renderer platform_renderer;
#endif

#if OP_RENDERERS & OP_RENDERER_D3D11
#include <D3D11.h>
#include <dxgi.h>

static struct {
  B8 initted;
  IDXGISwapChain *swapchain;
  ID3D11Device *device;
  ID3D11DeviceContext *context;
  ID3D11Texture2D *backbuffer;
  ID3D11RenderTargetView *backbuffer_view;
} d3d11;

static void d3d11_deinit(void);

static void d3d11_init(void) {
  {
    HRESULT hr;

    Array<D3D_FEATURE_LEVEL> requested_feature_levels({D3D_FEATURE_LEVEL_11_0});
    DXGI_SWAP_CHAIN_DESC swapchain_descriptor = {};
    swapchain_descriptor.BufferCount = 1;
    swapchain_descriptor.BufferDesc.Width = platform_width;
    swapchain_descriptor.BufferDesc.Height = platform_height;
    swapchain_descriptor.BufferDesc.Format = DXGI_FORMAT_R8G8B8A8_UNORM;
    swapchain_descriptor.BufferDesc.RefreshRate.Numerator = 144;
    swapchain_descriptor.BufferDesc.RefreshRate.Denominator = 1;
    swapchain_descriptor.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT;
    swapchain_descriptor.OutputWindow = platform_hwnd;
    swapchain_descriptor.SampleDesc.Count = 1;
    swapchain_descriptor.SampleDesc.Quality = 0;
    swapchain_descriptor.Windowed = true;
    swapchain_descriptor.Flags = DXGI_SWAP_CHAIN_FLAG_ALLOW_MODE_SWITCH;
    hr = D3D11CreateDeviceAndSwapChain(null, D3D_DRIVER_TYPE_HARDWARE, null, D3D11_CREATE_DEVICE_DEBUG,
      requested_feature_levels.data, cast(U32, requested_feature_levels.count),
      D3D11_SDK_VERSION, &swapchain_descriptor,
      &d3d11.swapchain, &d3d11.device, null, &d3d11.context);
    if (FAILED(hr)) goto error;

    IDXGIDevice* dxgi_device;
    if (SUCCEEDED(d3d11.swapchain->GetDevice(__uuidof(IDXGIDevice), cast(void **, &dxgi_device)))) {
      IDXGIAdapter *dxgi_adapter;
      if (SUCCEEDED(dxgi_device->GetAdapter(&dxgi_adapter))) {
        IDXGIFactory *dxgi_factory;
        if (SUCCEEDED(dxgi_adapter->GetParent(__uuidof(IDXGIFactory), cast(void **, &dxgi_factory)))) {
          dxgi_factory->MakeWindowAssociation(platform_hwnd, DXGI_MWA_NO_ALT_ENTER);
          dxgi_factory->Release();
        }
        dxgi_adapter->Release();
      }
      dxgi_device->Release();
    }

    hr = d3d11.swapchain->GetBuffer(0, __uuidof(ID3D11Texture2D), cast(void **, &d3d11.backbuffer));
    if (FAILED(hr)) goto error;

    hr = d3d11.device->CreateRenderTargetView(d3d11.backbuffer, null, &d3d11.backbuffer_view);
    if (FAILED(hr)) goto error;

    d3d11.initted = true;
  }
  return;
error:
  d3d11_deinit();
}

static void d3d11_deinit(void) {
  if (d3d11.initted) {
    d3d11.swapchain->SetFullscreenState(false, null);
  }

  if (d3d11.backbuffer_view) d3d11.backbuffer_view->Release();
  if (d3d11.swapchain) d3d11.swapchain->Release();
  if (d3d11.context) d3d11.context->Release();
  if (d3d11.device) d3d11.device->Release();
  d3d11 = {};
}

static void d3d11_resize(void) {
  if (!d3d11.initted) return;
  d3d11.swapchain->ResizeBuffers(1, platform_width, platform_height, DXGI_FORMAT_UNKNOWN, DXGI_SWAP_CHAIN_FLAG_ALLOW_MODE_SWITCH);
}

static void d3d11_present(void) {
  if (!d3d11.initted) return;

  d3d11.context->OMSetRenderTargets(1, &d3d11.backbuffer_view, null);

  D3D11_VIEWPORT viewport = {};
  viewport.Width = platform_width;
  viewport.Height = platform_height;
  viewport.MaxDepth = 1.0f;
  d3d11.context->RSSetViewports(1, &viewport);

  F32 clear_color[4] = {0.3f, 0.3f, 0.3f, 1.0f};
  d3d11.context->ClearRenderTargetView(d3d11.backbuffer_view, clear_color);

  d3d11.swapchain->Present(0, 0);
}

static Platform_Renderer d3d11_renderer = {
  d3d11_init,
  d3d11_deinit,
  d3d11_resize,
  d3d11_present,
};
#endif

#if OP_OS_WINDOWS
static void platform_choose_best_renderer(void) {
#if OP_RENDERERS & OP_RENDERER_D3D11
  platform_renderer = d3d11_renderer;
#elif OP_RENDERERS & OP_RENDERER_OPENGL
  platform_renderer = opengl_renderer;
#else
  platform_renderer = null_renderer;
#endif
}

static void platform_update_cursor_clip(void) {
  ClipCursor(null);
}

static void platform_clear_held_keys(void) {

}

static void platform_toggle_fullscreen(void) {
  static WINDOWPLACEMENT save_placement = {size_of(WINDOWPLACEMENT)};
  auto style = cast(U32, GetWindowLongPtrW(platform_hwnd, GWL_STYLE));
  if (style & WS_OVERLAPPEDWINDOW) {
    MONITORINFO mi = {size_of(MONITORINFO)};
    GetMonitorInfo(MonitorFromWindow(platform_hwnd, MONITOR_DEFAULTTOPRIMARY), &mi);

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

extern "C" [[noreturn]] void WINAPI WinMainCRTStartup(void) {
  platform_hinstance = GetModuleHandleW(null);

  B8 sleep_is_granular = timeBeginPeriod(1) == TIMERR_NOERROR;

  SetProcessDPIAware();
  WNDCLASSEXW wndclass = {};
  wndclass.cbSize = size_of(WNDCLASSEXW);
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

        platform_renderer.resize();
        return 0;
      case WM_CREATE: {
        platform_hwnd = hwnd;
        platform_hdc = GetDC(hwnd);

        S32 dark_mode = true;
        DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &dark_mode, size_of(dark_mode));
        S32 round_mode = DWMWCP_DONOTROUND;
        DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE, &round_mode, size_of(round_mode));

        platform_choose_best_renderer();
        platform_renderer.init();
        return 0;
      }
      case WM_DESTROY:
        platform_renderer.deinit();

        PostQuitMessage(0);
        return 0;
      case WM_SYSCOMMAND:
        if (wParam == SC_KEYMENU) return 0;
        // fallthrough;
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
        case WM_KEYDOWN:
        case WM_KEYUP:
        case WM_SYSKEYDOWN:
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
        case WM_QUIT: goto main_loop_end;
        default: DispatchMessageW(&msg);
      }
    }

    platform_renderer.present();

    if (sleep_is_granular) {
      Sleep(1);
    }
  }
main_loop_end:

  ExitProcess(0);
}

extern "C" int _fltused = 0;
#endif

#if OP_CPU_WASM32
__attribute__((import_name("console_log")))
void console_log(USize count, char const *data);

extern "C" void _start() {
  auto hw = String("Hello, world!");
  console_log(hw.count, hw.data);
}
#endif
