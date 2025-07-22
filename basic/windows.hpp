#if OP_CPU_X64 || OP_CPU_ARM64
  #define WINAPI
#else
  #define WINAPI __stdcall
#endif

typedef s32 HRESULT;
typedef struct HINSTANCE__ *HINSTANCE;
typedef HINSTANCE HMODULE;
typedef ssize (WINAPI*PROC)(void);

// Kernel32
#define KERNEL32_FUNCTIONS(X) \
  X(HMODULE, GetModuleHandleW, u16*) \
  X(HMODULE, LoadLibraryW, u16*) \
  X(PROC, GetProcAddress, HMODULE, u8*) \
  X(void, Sleep, u32) \
  X([[noreturn]] void, ExitProcess, u32)

// User32
#define CS_OWNDC 0x0020
#define IDC_CROSS cast(u16*, 32515)
#define IDI_WARNING cast(u16*, 32515)
#define WS_MAXIMIZEBOX 0x00010000
#define WS_MINIMIZEBOX 0x00020000
#define WS_THICKFRAME 0x00040000
#define WS_SYSMENU 0x00080000
#define WS_CAPTION 0x00C00000
#define WS_VISIBLE 0x10000000
#define WS_OVERLAPPEDWINDOW (WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX)
#define CW_USEDEFAULT 0x80000000
#define PM_REMOVE 0x0001
#define WM_CREATE 0x0001
#define WM_DESTROY 0x0002
#define WM_SIZE 0x0005
#define WM_PAINT 0x000F
#define WM_QUIT 0x0012
#define WM_ERASEBKGND 0x0014
#define WM_ACTIVATEAPP 0x001C
#define WM_KEYDOWN 0x0100
#define WM_KEYUP 0x0101
#define WM_SYSKEYDOWN 0x0104
#define WM_SYSKEYUP 0x0105
#define WM_SYSCOMMAND 0x0112
#define GWL_STYLE (-16)
#define HWND_TOP cast(HWND, 0)
#define MONITOR_DEFAULTTOPRIMARY 1
#define SWP_NOSIZE 0x0001
#define SWP_NOMOVE 0x0002
#define SWP_NOZORDER 0x0004
#define SWP_FRAMECHANGED 0x0020
#define SC_KEYMENU 0xF100
#define VK_RETURN 0x0D
#define VK_MENU 0x12
#define VK_F4 0x73
#define VK_F10 0x79
#define VK_F11 0x7A

typedef struct HDC__ *HDC;
typedef struct HWND__ *HWND;
typedef struct HMENU__ *HMENU;
typedef struct HICON__ *HICON;
typedef struct HBRUSH__ *HBRUSH;
typedef struct HCURSOR__ *HCURSOR;
typedef struct HMONITOR__ *HMONITOR;
typedef ssize (WINAPI*WNDPROC)(HWND, u32, usize, ssize);
struct POINT {
  s32 x;
  s32 y;
};
struct RECT {
  s32 left;
  s32 top;
  s32 right;
  s32 bottom;
};
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
  u16* lpszMenuName;
  u16* lpszClassName;
  HICON hIconSm;
};
struct MSG {
  HWND hwnd;
  u32 message;
  usize wParam;
  ssize lParam;
  u32 time;
  POINT pt;
  u32 lPrivate;
};
struct WINDOWPLACEMENT {
  u32 length;
  u32 flags;
  u32 showCmd;
  POINT ptMinPosition;
  POINT ptMaxPosition;
  RECT rcNormalPosition;
  RECT rcDevice;
};
struct MONITORINFO {
  u32 cbSize;
  RECT rcMonitor;
  RECT rcWork;
  u32 dwFlags;
};

#define USER32_FUNCTIONS(X) \
  X(s32, SetProcessDPIAware, void) \
  X(HICON, LoadIconW, HINSTANCE, u16*) \
  X(HCURSOR, LoadCursorW, HINSTANCE, u16*) \
  X(u16, RegisterClassExW, WNDCLASSEXW*) \
  X(HWND, CreateWindowExW, u32, u16*, u16*, u32, s32, s32, s32, s32, HWND, HMENU, HINSTANCE, void*) \
  X(s32, PeekMessageW, MSG*, HWND, u32, u32, u32) \
  X(s32, TranslateMessage, MSG*) \
  X(ssize, DispatchMessageW, MSG*) \
  X(ssize, DefWindowProcW, HWND, u32, usize, ssize) \
  X(void, PostQuitMessage, s32) \
  X(s32, ValidateRect, HWND, RECT*) \
  X(s32, DestroyWindow, HWND) \
  X(HDC, GetDC, HWND) \
  X(s32, ClipCursor, RECT*) \
  X(ssize, GetWindowLongPtrW, HWND, s32) \
  X(ssize, SetWindowLongPtrW, HWND, s32, ssize) \
  X(s32, GetWindowPlacement, HWND, WINDOWPLACEMENT*) \
  X(s32, SetWindowPlacement, HWND, WINDOWPLACEMENT*) \
  X(s32, SetWindowPos, HWND, HWND, s32, s32, s32, s32, u32) \
  X(HMONITOR, MonitorFromWindow, HWND, u32) \
  X(s32, GetMonitorInfoW, HMONITOR, MONITORINFO*)

// Ws2_32
#define WSADESCRIPTION_LEN 256
#define WSASYS_STATUS_LEN 128

struct WSADATA32 {
  u16 wVersion;
  u16 wHighVersion;
  u8 szDescription[WSADESCRIPTION_LEN + 1];
  u8 szSystemStatus[WSASYS_STATUS_LEN + 1];
  u16 iMaxSockets;
  u16 iMaxUdpDg;
  u8* lpVendorInfo;
};
struct WSADATA64 {
  u16 wVersion;
  u16 wHighVersion;
  u16 iMaxSockets;
  u16 iMaxUdpDg;
  u8* lpVendorInfo;
  u8 szDescription[WSADESCRIPTION_LEN + 1];
  u8 szSystemStatus[WSASYS_STATUS_LEN + 1];
};
#if OP_CPU_X64 || OP_CPU_ARM64
  typedef WSADATA64 WSADATA;
#else
  typedef WSADATA32 WSADATA;
#endif

#define WS2_32_FUNCTIONS(X) \
  X(s32, WSAStartup, u16, WSADATA*) \
  X(s32, WSACleanup, void)

// Dwmapi
#define DWMWA_USE_IMMERSIVE_DARK_MODE 20
#define DWMWA_WINDOW_CORNER_PREFERENCE 33
#define DWMWCP_DONOTROUND 1

#define DWMAPI_FUNCTIONS(X) \
  X(HRESULT, DwmSetWindowAttribute, HWND, u32, void*, u32)

// Winmm
#define TIMERR_NOERROR 0

#define WINMM_FUNCTIONS(X) \
  X(u32, timeBeginPeriod, u32)
