version (OSX) {
  enum STDOUT_FILENO = 1;

  extern(C) ptrdiff_t write(int, const(void)*, size_t);
  extern(C) noreturn _exit(int);

  struct objc_Class__; alias objc_Class = objc_Class__*;
  struct objc_SEL__; alias objc_SEL = objc_SEL__*;

  extern(C) void objc_msgSend();
  extern(C) objc_Class objc_getClass(const(char)*);
  extern(C) objc_SEL sel_getUid(const(char)*);

  struct NSApplication {
    enum ActivationPolicy : int {
      REGULAR = 0,
      ACCESSORY = 1,
      PROHIBITED = 2,
    }

    extern(C) static NSApplication* sharedApplication() {
      alias PFN = extern(C) NSApplication* function(objc_Class, objc_SEL);
      return (cast(PFN) &objc_msgSend)(objc_getClass("NSApplication"), sel_getUid("sharedApplication"));
    }

    extern(C) bool setActivationPolicy(ActivationPolicy policy) {
      alias PFN = extern(C) bool function(NSApplication*, objc_SEL, ActivationPolicy);
      return (cast(PFN) &objc_msgSend)(&this, sel_getUid("setActivationPolicy:"), policy);
    }
  }

  extern(C) bool NSApplicationLoad();

  __gshared NSApplication* platform_app;

  extern(C) noreturn main() {
    NSApplicationLoad();
    platform_app = NSApplication.sharedApplication();
    platform_app.setActivationPolicy(NSApplication.ActivationPolicy.REGULAR);

    _exit(0);
  }

  pragma(linkerDirective, "-framework", "AppKit");
}

version (Windows) version = D3D11;

version (D3D11) {
  struct DXGI_RATIONAL {
    uint Numerator;
    uint Denominator;
  }

  enum DXGI_FORMAT : int {
    UNKNOWN = 0,
    R32G32B32A32_TYPELESS = 1,
    R32G32B32A32_FLOAT = 2,
    R32G32B32A32_UINT = 3,
    R32G32B32A32_SINT = 4,
    R32G32B32_TYPELESS = 5,
    R32G32B32_FLOAT = 6,
    R32G32B32_UINT = 7,
    R32G32B32_SINT = 8,
    R16G16B16A16_TYPELESS = 9,
    R16G16B16A16_FLOAT = 10,
    R16G16B16A16_UNORM = 11,
    R16G16B16A16_UINT = 12,
    R16G16B16A16_SNORM = 13,
    R16G16B16A16_SINT = 14,
    R32G32_TYPELESS = 15,
    R32G32_FLOAT = 16,
    R32G32_UINT = 17,
    R32G32_SINT = 18,
    R32G8X24_TYPELESS = 19,
    D32_FLOAT_S8X24_UINT = 20,
    R32_FLOAT_X8X24_TYPELESS = 21,
    X32_TYPELESS_G8X24_UINT = 22,
    R10G10B10A2_TYPELESS = 23,
    R10G10B10A2_UNORM = 24,
    R10G10B10A2_UINT = 25,
    R11G11B10_FLOAT = 26,
    R8G8B8A8_TYPELESS = 27,
    R8G8B8A8_UNORM = 28,
    R8G8B8A8_UNORM_SRGB = 29,
    R8G8B8A8_UINT = 30,
    R8G8B8A8_SNORM = 31,
    R8G8B8A8_SINT = 32,
    R16G16_TYPELESS = 33,
    R16G16_FLOAT = 34,
    R16G16_UNORM = 35,
    R16G16_UINT = 36,
    R16G16_SNORM = 37,
    R16G16_SINT = 38,
    R32_TYPELESS = 39,
    D32_FLOAT = 40,
    R32_FLOAT = 41,
    R32_UINT = 42,
    R32_SINT = 43,
    R24G8_TYPELESS = 44,
    D24_UNORM_S8_UINT = 45,
    R24_UNORM_X8_TYPELESS = 46,
    X24_TYPELESS_G8_UINT = 47,
    R8G8_TYPELESS = 48,
    R8G8_UNORM = 49,
    R8G8_UINT = 50,
    R8G8_SNORM = 51,
    R8G8_SINT = 52,
    R16_TYPELESS = 53,
    R16_FLOAT = 54,
    D16_UNORM = 55,
    R16_UNORM = 56,
    R16_UINT = 57,
    R16_SNORM = 58,
    R16_SINT = 59,
    R8_TYPELESS = 60,
    R8_UNORM = 61,
    R8_UINT = 62,
    R8_SNORM = 63,
    R8_SINT = 64,
    A8_UNORM = 65,
    R1_UNORM = 66,
    R9G9B9E5_SHAREDEXP = 67,
    R8G8_B8G8_UNORM = 68,
    G8R8_G8B8_UNORM = 69,
    BC1_TYPELESS = 70,
    BC1_UNORM = 71,
    BC1_UNORM_SRGB = 72,
    BC2_TYPELESS = 73,
    BC2_UNORM = 74,
    BC2_UNORM_SRGB = 75,
    BC3_TYPELESS = 76,
    BC3_UNORM = 77,
    BC3_UNORM_SRGB = 78,
    BC4_TYPELESS = 79,
    BC4_UNORM = 80,
    BC4_SNORM = 81,
    BC5_TYPELESS = 82,
    BC5_UNORM = 83,
    BC5_SNORM = 84,
    B5G6R5_UNORM = 85,
    B5G5R5A1_UNORM = 86,
    B8G8R8A8_UNORM = 87,
    B8G8R8X8_UNORM = 88,
    R10G10B10_XR_BIAS_A2_UNORM = 89,
    B8G8R8A8_TYPELESS = 90,
    B8G8R8A8_UNORM_SRGB = 91,
    B8G8R8X8_TYPELESS = 92,
    B8G8R8X8_UNORM_SRGB = 93,
    BC6H_TYPELESS = 94,
    BC6H_UF16 = 95,
    BC6H_SF16 = 96,
    BC7_TYPELESS = 97,
    BC7_UNORM = 98,
    BC7_UNORM_SRGB = 99,
    AYUV = 100,
    Y410 = 101,
    Y416 = 102,
    NV12 = 103,
    P010 = 104,
    P016 = 105,
    _420_OPAQUE = 106,
    YUY2 = 107,
    Y210 = 108,
    Y216 = 109,
    NV11 = 110,
    AI44 = 111,
    IA44 = 112,
    P8 = 113,
    A8P8 = 114,
    B4G4R4A4_UNORM = 115,
    P208 = 130,
    V208 = 131,
    V408 = 132,
    SAMPLER_FEEDBACK_MIN_MIP_OPAQUE = 189,
    SAMPLER_FEEDBACK_MIP_REGION_USED_OPAQUE = 190,
    FORCE_UINT = 0xFFFFFFFF,
  }

  enum DXGI_MODE_SCANLINE_ORDER : int {
    UNSPECIFIED = 0,
    PROGRESSIVE = 1,
    UPPER_FIELD_FIRST = 2,
    LOWER_FIELD_FIRST = 3,
  }

  enum DXGI_MODE_SCALING : int {
    UNSPECIFIED = 0,
    CENTERED = 1,
    STRETCHED = 2,
  }

  struct DXGI_MODE_DESC {
    uint Width;
    uint Height;
    DXGI_RATIONAL RefreshRate;
    DXGI_FORMAT Format;
    DXGI_MODE_SCANLINE_ORDER ScanlineOrdering;
    DXGI_MODE_SCALING Scaling;
  }

  struct DXGI_SAMPLE_DESC {
    uint Count;
    uint Quality;
  }

  enum DXGI_USAGE : uint {
    SHADER_INPUT = 1 << (0 + 4),
    RENDER_TARGET_OUTPUT = 1 << (1 + 4),
    BACK_BUFFER = 1 << (2 + 4),
    SHARED = 1 << (3 + 4),
    READ_ONLY = 1 << (4 + 4),
    DISCARD_ON_PRESENT = 1 << (5 + 4),
    UNORDERED_ACCESS = 1 << (6 + 4),
  }

  enum DXGI_SWAP_EFFECT : int {
    DISCARD = 0,
    SEQUENTIAL = 1,
    FLIP_SEQUENTIAL = 3,
    FLIP_DISCARD = 4,
  }

  struct DXGI_SWAP_CHAIN_DESC {
    DXGI_MODE_DESC BufferDesc;
    DXGI_SAMPLE_DESC SampleDesc;
    DXGI_USAGE BufferUsage;
    uint BufferCount;
    HWND OutputWindow;
    int Windowed;
    DXGI_SWAP_EFFECT SwapEffect;
    uint Flags;
  }

  struct DXGI_FRAME_STATISTICS {
    uint PresentCount;
    uint PresentRefreshCount;
    uint SyncRefreshCount;
    ulong SyncQPCTime;
    ulong SyncGPUTime;
  }

  enum DXGI_SWAP_CHAIN_FLAG : int {
    NONPREROTATED = 1,
    ALLOW_MODE_SWITCH = 2,
    GDI_COMPATIBLE = 4,
    RESTRICTED_CONTENT = 8,
    RESTRICT_SHARED_RESOURCE_DRIVER = 16,
    DISPLAY_ONLY = 32,
    FRAME_LATENCY_WAITABLE_OBJECT = 64,
    FOREGROUND_LAYER = 128,
    FULLSCREEN_VIDEO = 256,
    YUV_VIDEO = 512,
    HW_PROTECTED = 1024,
    ALLOW_TEARING = 2048,
    RESTRICTED_TO_ALL_HOLOGRAPHIC_DISPLAYS = 4096,
  }

  align(1) struct GUID {
    uint Data1;
    ushort Data2;
    ushort Data3;
    ubyte[8] Data4;
  }
  alias IID = const(GUID);

  struct IUnknown {
    struct VTable {
      extern(Windows) HRESULT function(void*, IID*, void**) QueryInterface;
      extern(Windows) uint function(void*) AddRef;
      extern(Windows) uint function(void*) Release;
    }
    VTable* lpVtbl;
    alias this = lpVtbl;
  }

  struct IDXGIObject {
    struct VTable {
      IUnknown.VTable iunknown;
      alias this = iunknown;
      extern(Windows) HRESULT function(void*, IID*, void**) GetParent;
      extern(Windows) HRESULT function(void*, const(GUID)*, uint*, void*) GetPrivateData;
      extern(Windows) HRESULT function(void*, const(GUID)*, uint, const(void)*) SetPrivateData;
      extern(Windows) HRESULT function(void*, const(GUID)*, const(IUnknown)*) SetPrivateDataInterface;
    }
    VTable* lpVtbl;
    alias this = lpVtbl;
  }

  struct IDXGIOutput {
    struct VTable {
      IDXGIObject.VTable idxgiobject;
      alias this = idxgiobject;
      // ...
    }
    VTable* lpVtbl;
    alias this = lpVtbl;
  }

  struct IDXGIAdapter {
    struct VTable {
      IDXGIObject.VTable idxgiobject;
      alias this = idxgiobject;
      // ...
    }
    VTable* lpVtbl;
    alias this = lpVtbl;
  }

  struct IDXGIDeviceSubObject {
    struct VTable {
      IDXGIObject.VTable idxgiobject;
      alias this = idxgiobject;
      extern(Windows) HRESULT function(void*, IID*, void**) GetDevice;
    }
    VTable* lpVtbl;
    alias this = lpVtbl;
  }

  enum D3D11_SDK_VERSION = 7;

  enum D3D_DRIVER_TYPE : int {
    UNKNOWN = 0,
    HARDWARE = 1,
    REFERENCE = 2,
    NULL = 3,
    SOFTWARE = 4,
    WARP = 5,
  }

  enum D3D_FEATURE_LEVEL : int {
    _1_0_GENERIC = 0,
    _1_0_CORE = 1,
    _9_1 = 2,
    _9_2 = 3,
    _9_3 = 4,
    _10_0 = 5,
    _10_1 = 6,
    _11_0 = 7,
    _11_1 = 8,
    _12_0 = 9,
    _12_1 = 10,
    _12_2 = 11,
  }

  enum D3D11_CREATE_DEVICE_FLAG : int {
    SINGLETHREADED = 0x1,
    DEBUG = 0x2,
    SWITCH_TO_REF = 0x4,
    PREVENT_INTERNAL_THREADING_OPTIMIZATIONS = 0x8,
    BGRA_SUPPORT = 0x20,
    DEBUGGABLE = 0x40,
    PREVENT_ALTERING_LAYER_SETTINGS_FROM_REGISTRY = 0x80,
    DISABLE_GPU_TIMEOUT = 0x100,
    VIDEO_SUPPORT = 0x800,
  }

  struct IDXGISwapChain {
    struct VTable {
      IDXGIDeviceSubObject.VTable idxgidevicesubobject;
      alias this = idxgidevicesubobject;
      extern(Windows) HRESULT function(void*, uint, IID*, void**) GetBuffer;
      extern(Windows) HRESULT function(void*, IDXGIOutput**) GetContainingOutput;
      extern(Windows) HRESULT function(void*, DXGI_SWAP_CHAIN_DESC*) GetDesc;
      extern(Windows) HRESULT function(void*, DXGI_FRAME_STATISTICS*) GetFrameStatistics;
      extern(Windows) HRESULT function(void*, int, IDXGIOutput**) GetFullscreenState;
      extern(Windows) HRESULT function(void*, uint*) GetLastPresentCount;
      extern(Windows) HRESULT function(void*, uint, uint) Present;
      extern(Windows) HRESULT function(void*, uint, uint, uint, DXGI_FORMAT, uint) ResizeBuffers;
      extern(Windows) HRESULT function(void*, const(DXGI_MODE_DESC)*) ResizeTarget;
      extern(Windows) HRESULT function(void*, int, IDXGIOutput*) SetFullscreenState;
    }
    VTable* lpVtbl;
    alias this = lpVtbl;
  }

  struct ID3D11Device {
    struct VTable {
      IUnknown.VTable iunknown;
      alias this = iunknown;
      // ...
    }
    VTable* lpVtbl;
    alias this = lpVtbl;
  }

  struct ID3D11DeviceChild {
    struct VTable {
      IUnknown.VTable iunknown;
      alias this = iunknown;
      // ...
    }
    VTable* lpVtbl;
    alias this = lpVtbl;
  }

  struct ID3D11DeviceContext {
    struct VTable {
      ID3D11DeviceChild.VTable id3d11devicechild;
      alias this = id3d11devicechild;
      // ...
    }
    VTable* lpVtbl;
    alias this = lpVtbl;
  }

  extern(Windows) HRESULT D3D11CreateDeviceAndSwapChain(IDXGIAdapter*, D3D_DRIVER_TYPE, HMODULE, uint, const(D3D_FEATURE_LEVEL)*, uint, uint, const(DXGI_SWAP_CHAIN_DESC)*, IDXGISwapChain**, ID3D11Device**, D3D_FEATURE_LEVEL*, ID3D11DeviceContext**);

  struct D3D11Data {
    bool initted;
    IDXGISwapChain* swapchain;
    ID3D11Device* device;
    ID3D11DeviceContext* ctx;
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

    d3d11.initted = true;
    return;
  error:
    d3d11_deinit();
  }

  void d3d11_deinit() {
    if (d3d11.ctx) d3d11.ctx.Release(d3d11.ctx);
    if (d3d11.device) d3d11.device.Release(d3d11.device);
    if (d3d11.swapchain) d3d11.swapchain.Release(d3d11.swapchain);
    d3d11 = d3d11.init;
  }

  void d3d11_resize() {

  }

  void d3d11_present() {
    if (!d3d11.initted) return;
    // d3d11.ctx.ClearRenderTargetView(d3d11.ctx);
    d3d11.swapchain.Present(d3d11.swapchain, 0, 0);
  }
}

version (Windows) {
  // kernel32
  alias HRESULT = int;
  struct HINSTANCE__; alias HINSTANCE = HINSTANCE__*;
  alias HMODULE = HINSTANCE;

  extern(Windows) HMODULE GetModuleHandleW(const(wchar)*);
  extern(Windows) noreturn ExitProcess(uint);

  // user32
  enum CS_OWNDC = 0x0020;
  enum IDI_WARNING = cast(const(wchar)*) 32515;
  enum IDC_CROSS = cast(const(wchar)*) 32515;
  enum WS_MAXIMIZEBOX = 0x00010000;
  enum WS_MINIMIZEBOX = 0x00020000;
  enum WS_THICKFRAME = 0x00040000;
  enum WS_SYSMENU = 0x00080000;
  enum WS_CAPTION = 0x00C00000;
  enum WS_VISIBLE = 0x10000000;
  enum WS_OVERLAPPEDWINDOW = WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX;
  enum CW_USEDEFAULT = 0x80000000;
  enum PM_REMOVE = 0x0001;
  enum WM_CREATE = 0x0001;
  enum WM_DESTROY = 0x0002;
  enum WM_SIZE = 0x0005;
  enum WM_QUIT = 0x0012;
  enum WM_KEYDOWN = 0x0100;
  enum WM_KEYUP = 0x0101;
  enum WM_SYSKEYDOWN = 0x0104;
  enum WM_SYSKEYUP = 0x0105;
  enum WM_SYSCOMMAND = 0x0112;
  enum SC_KEYMENU = 0xF100;
  enum GWL_STYLE = -16;
  enum MONITOR_DEFAULTTOPRIMARY = 1;
  enum HWND_TOP = cast(HWND) 0;
  enum SWP_NOSIZE = 0x0001;
  enum SWP_NOMOVE = 0x0002;
  enum SWP_NOZORDER = 0x0004;
  enum SWP_FRAMECHANGED = 0x0020;
  enum VK_RETURN = 0x0D;
  enum VK_MENU = 0x12;
  enum VK_ESCAPE = 0x1B;
  enum VK_F4 = 0x73;
  enum VK_F10 = 0x79;
  enum VK_F11 = 0x7A;

  struct HDC__; alias HDC = HDC__*;
  struct HWND__; alias HWND = HWND__*;
  struct HMENU__; alias HMENU = HMENU__*;
  struct HICON__; alias HICON = HICON__*;
  struct HBRUSH__; alias HBRUSH = HBRUSH__*;
  struct HCURSOR__; alias HCURSOR = HCURSOR__*;
  struct HMONITOR__; alias HMONITOR = HMONITOR__*;
  alias WNDPROC = extern(Windows) ptrdiff_t function(HWND, uint, size_t, ptrdiff_t);
  struct POINT {
    int x;
    int y;
  }
  struct RECT {
    int left;
    int top;
    int right;
    int bottom;
  }
  struct WNDCLASSEXW {
    uint cbSize;
    uint style;
    WNDPROC lpfnWndProc;
    int cbClsExtra;
    int cbWndExtra;
    HINSTANCE hInstance;
    HICON hIcon;
    HCURSOR hCursor;
    HBRUSH hbrBackground;
    const(wchar)* lpszMenuName;
    const(wchar)* lpszClassName;
    HICON hIconSm;
  }
  struct MSG {
    HWND hwnd;
    uint message;
    size_t wParam;
    ptrdiff_t lParam;
    uint time;
    POINT pt;
    uint lPrivate;
  }
  struct WINDOWPLACEMENT {
    uint length;
    uint flags;
    uint showCmd;
    POINT ptMinPosition;
    POINT ptMaxPosition;
    RECT rcNormalPosition;
    RECT rcDevice;
  }
  struct MONITORINFO {
    uint cbSize;
    RECT rcMonitor;
    RECT rcWork;
    uint dwFlags;
  }

  extern(Windows) int SetProcessDPIAware();
  extern(Windows) HICON LoadIconW(HINSTANCE, const(wchar)*);
  extern(Windows) HCURSOR LoadCursorW(HINSTANCE, const(wchar)*);
  extern(Windows) ushort RegisterClassExW(const(WNDCLASSEXW)*);
  extern(Windows) HWND CreateWindowExW(uint, const(wchar)*, const(wchar)*, uint, int, int, int, int, HWND, HMENU, HINSTANCE, void*);
  extern(Windows) int PeekMessageW(MSG*, HWND, uint, uint, uint);
  extern(Windows) int TranslateMessage(const(MSG)*);
  extern(Windows) ptrdiff_t DispatchMessageW(const(MSG)*);
  extern(Windows) HDC GetDC(HWND);
  extern(Windows) ptrdiff_t DefWindowProcW(HWND, uint, size_t, ptrdiff_t);
  extern(Windows) int DestroyWindow(HWND);
  extern(Windows) void PostQuitMessage(int);
  extern(Windows) ptrdiff_t GetWindowLongPtrW(HWND, int);
  extern(Windows) ptrdiff_t SetWindowLongPtrW(HWND, int, ptrdiff_t);
  extern(Windows) int GetWindowPlacement(HWND, WINDOWPLACEMENT*);
  extern(Windows) int SetWindowPlacement(HWND, const(WINDOWPLACEMENT)*);
  extern(Windows) int SetWindowPos(HWND, HWND, int, int, int, int, uint);
  extern(Windows) HMONITOR MonitorFromWindow(HWND, uint);
  extern(Windows) int GetMonitorInfoW(HMONITOR, MONITORINFO*);

  // dwmapi
  enum DWMWA_USE_IMMERSIVE_DARK_MODE = 20;
  enum DWMWA_WINDOW_CORNER_PREFERENCE = 33;
  enum DWMWCP_DONOTROUND = 1;

  extern(Windows) HRESULT DwmSetWindowAttribute(HWND, uint, const(void)*, uint);

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

  pragma(linkerDirective, "-subsystem:windows");
  pragma(lib, "kernel32");
  pragma(lib, "user32");
  pragma(lib, "gdi32");
  pragma(lib, "dwmapi");
  pragma(lib, "d3d11");
}
