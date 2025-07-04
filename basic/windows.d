module basic.windows;

import basic;

alias HANDLE = void*;
alias HRESULT = s32;
alias PROC = extern(Windows) ssize function();
struct GUID {
  u32 Data1;
  u16 Data2;
  u16 Data3;
  u8[8] Data4;
}
alias IID = const(GUID);
struct IUnknown {
  struct VTable {
    HRESULT function(void*, IID*, void**) QueryInterface;
    u32 function(void*) AddRef;
    u32 function(void*) Release;
  }
  mixin COMClass;
}

// kernel32
enum STD_INPUT_HANDLE = -10;
enum STD_OUTPUT_HANDLE = -11;
enum STD_ERROR_HANDLE = -12;

struct HINSTANCE__; alias HINSTANCE = HINSTANCE__*;
alias HMODULE = HINSTANCE;

@foreign("kernel32") extern(Windows) HMODULE GetModuleHandleW(const(wchar)*);
@foreign("kernel32") extern(Windows) void Sleep(u32);
@foreign("kernel32") extern(Windows) s32 AllocConsole();
@foreign("kernel32") extern(Windows) HANDLE GetStdHandle(u32);
@foreign("kernel32") extern(Windows) noreturn ExitProcess(u32);

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
enum WM_PAINT = 0x000F;
enum WM_QUIT = 0x0012;
enum WM_ERASEBKGND = 0x0014;
enum WM_ACTIVATEAPP = 0x001C;
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
alias WNDPROC = extern(Windows) ssize function(HWND, u32, usize, ssize);
struct POINT {
  s32 x;
  s32 y;
}
struct RECT {
  s32 left;
  s32 top;
  s32 right;
  s32 bottom;
}
struct WNDCLASSEXW {
  u32 cbSize;
  u32 style;
  WNDPROC lpfnWndProc;
  s32 cbClsExtra;
  s32 cbWndExtra;
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
  u32 message;
  usize wParam;
  ssize lParam;
  u32 time;
  POINT pt;
  u32 lPrivate;
}
struct WINDOWPLACEMENT {
  u32 length;
  u32 flags;
  u32 showCmd;
  POINT ptMinPosition;
  POINT ptMaxPosition;
  RECT rcNormalPosition;
  RECT rcDevice;
}
struct MONITORINFO {
  u32 cbSize;
  RECT rcMonitor;
  RECT rcWork;
  u32 dwFlags;
}

@foreign("user32") extern(Windows) s32 SetProcessDPIAware();
@foreign("user32") extern(Windows) HICON LoadIconW(HINSTANCE, const(wchar)*);
@foreign("user32") extern(Windows) HCURSOR LoadCursorW(HINSTANCE, const(wchar)*);
@foreign("user32") extern(Windows) u16 RegisterClassExW(const(WNDCLASSEXW)*);
@foreign("user32") extern(Windows) HWND CreateWindowExW(u32, const(wchar)*, const(wchar)*, u32, s32, s32, s32, s32, HWND, HMENU, HINSTANCE, void*);
@foreign("user32") extern(Windows) s32 PeekMessageW(MSG*, HWND, u32, u32, u32);
@foreign("user32") extern(Windows) s32 TranslateMessage(const(MSG)*);
@foreign("user32") extern(Windows) ssize DispatchMessageW(const(MSG)*);
@foreign("user32") extern(Windows) ssize DefWindowProcW(HWND, u32, usize, ssize);
@foreign("user32") extern(Windows) void PostQuitMessage(s32);
@foreign("user32") extern(Windows) HDC GetDC(HWND);
@foreign("user32") extern(Windows) s32 DestroyWindow(HWND);
@foreign("user32") extern(Windows) s32 ClipCursor(const(RECT)*);
@foreign("user32") extern(Windows) s32 ValidateRect(HWND, const(RECT)*);
@foreign("user32") extern(Windows) ssize GetWindowLongPtrW(HWND, s32);
@foreign("user32") extern(Windows) ssize SetWindowLongPtrW(HWND, s32, ssize);
@foreign("user32") extern(Windows) s32 GetWindowPlacement(HWND, WINDOWPLACEMENT*);
@foreign("user32") extern(Windows) s32 SetWindowPlacement(HWND, const(WINDOWPLACEMENT)*);
@foreign("user32") extern(Windows) s32 SetWindowPos(HWND, HWND, s32, s32, s32, s32, u32);
@foreign("user32") extern(Windows) HMONITOR MonitorFromWindow(HWND, u32);
@foreign("user32") extern(Windows) s32 GetMonitorInfoW(HMONITOR, MONITORINFO*);

// ws2_32
enum WSADESCRIPTION_LEN = 256;
enum WSASYS_STATUS_LEN = 128;

struct WSADATA32 {
  u16 wVersion;
  u16 wHighVersion;
  char[WSADESCRIPTION_LEN + 1] szDescription;
  char[WSASYS_STATUS_LEN + 1] szSystemStatus;
  u16 iMaxSockets;
  u16 iMaxUdpDg;
  char* lpVendorInfo;
}
struct WSADATA64 {
  u16 wVersion;
  u16 wHighVersion;
  u16 iMaxSockets;
  u16 iMaxUdpDg;
  char* lpVendorInfo;
  char[WSADESCRIPTION_LEN + 1] szDescription;
  char[WSASYS_STATUS_LEN + 1] szSystemStatus;
}
version (Win64) alias WSADATA = WSADATA64;
else            alias WSADATA = WSADATA32;

@foreign("ws2_32") extern(Windows) s32 WSAStartup(u16, WSADATA*);
@foreign("ws2_32") extern(Windows) s32 WSACleanup();

// dwmapi
enum DWMWA_USE_IMMERSIVE_DARK_MODE = 20;
enum DWMWA_WINDOW_CORNER_PREFERENCE = 33;
enum DWMWCP_DONOTROUND = 1;

@foreign("dwmapi") extern(Windows) HRESULT DwmSetWindowAttribute(HWND, u32, const(void)*, u32);

// winmm
enum TIMERR_NOERROR = 0;

@foreign("winmm") extern(Windows) u32 timeBeginPeriod(u32);

// d3d11
struct ID3D11Device {
  struct VTable {
    IUnknown.VTable iunknown_vtable;
    alias this = iunknown_vtable;
    // ...
  }
  mixin COMClass;
}
struct ID3D11DeviceChild {
  struct VTable {
    IUnknown.VTable iunknown_vtable;
    alias this = iunknown_vtable;
    void function(void*) GetDevice;
    void function(void*) GetPrivateData;
    void function(void*) SetPrivateData;
    void function(void*) SetPrivateDataInterface;
  }
  mixin COMClass;
}
struct ID3D11DeviceContext {
  struct VTable {
    ID3D11DeviceChild.VTable id3d11devicechild_vtable;
    alias this = id3d11devicechild_vtable;
    void function(void*) VSSetConstantBuffers;
    void function(void*) PSSetShaderResources;
    void function(void*) PSSetShader;
    void function(void*) PSSetSamplers;
    void function(void*) VSSetShader;
    void function(void*) DrawIndexed;
    void function(void*) Draw;
    void function(void*) Map;
    void function(void*) Unmap;
    void function(void*) PSSetConstantBuffers;
    void function(void*) IASetInputLayout;
    void function(void*) IASetVertexBuffers;
    void function(void*) IASetIndexBuffer;
    void function(void*) DrawIndexedInstanced;
    void function(void*) DrawInstanced;
    void function(void*) GSSetConstantBuffers;
    void function(void*) GSSetShader;
    void function(void*) IASetPrimitiveTopology;
    void function(void*) VSSetShaderResources;
    void function(void*) VSSetSamplers;
    void function(void*) Begin;
    void function(void*) End;
    void function(void*) GetData;
    void function(void*) SetPredication;
    void function(void*) GSSetShaderResources;
    void function(void*) GSSetSamplers;
    void function(void*) OMSetRenderTargets;
    void function(void*) OMSetRenderTargetsAndUnorderedAccessViews;
    void function(void*) OMSetBlendState;
    void function(void*) OMSetDepthStencilState;
    void function(void*) SOSetTargets;
    void function(void*) DrawAuto;
    void function(void*) DrawIndexedInstancedIndirect;
    void function(void*) DrawInstancedIndirect;
    void function(void*) Dispatch;
    void function(void*) DispatchIndirect;
    void function(void*) RSSetState;
    void function(void*) RSSetViewports;
    void function(void*) RSSetScissorRects;
    void function(void*) CopySubresourceRegion;
    void function(void*) CopyResource;
    void function(void*) UpdateSubresource;
    void function(void*) CopyStructureCount;
    void function(void*) ClearRenderTargetView;
    void function(void*) ClearUnorderedAccessViewUint;
    void function(void*) ClearUnorderedAccessViewFloat;
    void function(void*) ClearDepthStencilView;
    void function(void*) GenerateMips;
    void function(void*) SetResourceMinLOD;
    void function(void*) GetResourceMinLOD;
    void function(void*) ResolveSubresource;
    void function(void*) ExecuteCommandList;
    void function(void*) HSSetShaderResources;
    void function(void*) HSSetShader;
    void function(void*) HSSetSamplers;
    void function(void*) HSSetConstantBuffers;
    void function(void*) DSSetShaderResources;
    void function(void*) DSSetShader;
    void function(void*) DSSetSamplers;
    void function(void*) DSSetConstantBuffers;
    void function(void*) CSSetShaderResources;
    void function(void*) CSSetUnorderedAccessViews;
    void function(void*) CSSetShader;
    void function(void*) CSSetSamplers;
    void function(void*) CSSetConstantBuffers;
    void function(void*) VSGetConstantBuffers;
    void function(void*) PSGetShaderResources;
    void function(void*) PSGetShader;
    void function(void*) PSGetSamplers;
    void function(void*) VSGetShader;
    void function(void*) PSGetConstantBuffers;
    void function(void*) IAGetInputLayout;
    void function(void*) IAGetVertexBuffers;
    void function(void*) IAGetIndexBuffer;
    void function(void*) GSGetConstantBuffers;
    void function(void*) GSGetShader;
    void function(void*) IAGetPrimitiveTopology;
    void function(void*) VSGetShaderResources;
    void function(void*) VSGetSamplers;
    void function(void*) GetPredication;
    void function(void*) GSGetShaderResources;
    void function(void*) GSGetSamplers;
    void function(void*) OMGetRenderTargets;
    void function(void*) OMGetRenderTargetsAndUnorderedAccessViews;
    void function(void*) OMGetBlendState;
    void function(void*) OMGetDepthStencilState;
    void function(void*) SOGetTargets;
    void function(void*) RSGetState;
    void function(void*) RSGetViewports;
    void function(void*) RSGetScissorRects;
    void function(void*) HSGetShaderResources;
    void function(void*) HSGetShader;
    void function(void*) HSGetSamplers;
    void function(void*) HSGetConstantBuffers;
    void function(void*) DSGetShaderResources;
    void function(void*) DSGetShader;
    void function(void*) DSGetSamplers;
    void function(void*) DSGetConstantBuffers;
    void function(void*) CSGetShaderResources;
    void function(void*) CSGetUnorderedAccessViews;
    void function(void*) CSGetShader;
    void function(void*) CSGetSamplers;
    void function(void*) CSGetConstantBuffers;
    void function(void*) ClearState;
    void function(void*) Flush;
    void function(void*) GetType;
    void function(void*) GetContextFlags;
    void function(void*) FinishCommandList;
  }
  mixin COMClass;
}

// dxgi
struct IDXGIObject {
  struct VTable {
    IUnknown.VTable iunknown_vtable;
    alias this = iunknown_vtable;
    HRESULT function(void*, GUID*, u32, const(void)*) SetPrivateData;
    HRESULT function(void*, GUID*, const(IUnknown)*) SetPrivateDataInterface;
    HRESULT function(void*, GUID*, u32*, void*) GetPrivateData;
    HRESULT function(void*, IID*, void**) GetParent;
  }
  mixin COMClass;
}
struct IDXGIDeviceSubObject {
  struct VTable {
    IDXGIObject.VTable idxgiobject_vtable;
    alias this = idxgiobject_vtable;
    HRESULT function(void*, IID*, void**) GetDevice;
  }
  mixin COMClass;
}
struct IDXGISwapChain {
  struct VTable {
    IDXGIDeviceSubObject.VTable idxgidevicesubobject_vtable;
    alias this = idxgidevicesubobject_vtable;
    void function(void*) Present;
    void function(void*) GetBuffer;
    void function(void*) SetFullscreenState;
    void function(void*) GetFullscreenState;
    void function(void*) GetDesc;
    void function(void*) ResizeBuffers;
    void function(void*) ResizeTarget;
    void function(void*) GetContainingOutput;
    void function(void*) GetFrameStatistics;
    void function(void*) GetLastPresentCount;
  }
  mixin COMClass;
}
