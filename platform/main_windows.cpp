#include "../basic/basic.hpp"
#include "../basic/windows.hpp"

#define X(RET, NAME, ...) extern "C" RET WINAPI NAME(__VA_ARGS__);
  KERNEL32_FUNCTIONS(X)
#undef X
#define X(RET, NAME, ...) static RET (WINAPI*NAME)(__VA_ARGS__);
  USER32_FUNCTIONS(X)
  WS2_32_FUNCTIONS(X)
  DWMAPI_FUNCTIONS(X)
  WINMM_FUNCTIONS(X)
#undef X

static HINSTANCE platform_hinstance;
static HWND platform_hwnd;
static HDC platform_hdc;
static u16 platform_width;
static u16 platform_height;

static void platform_toggle_fullscreen(void) {
  static WINDOWPLACEMENT save_placement = {size_of(WINDOWPLACEMENT)};
  ssize style = GetWindowLongPtrW(platform_hwnd, GWL_STYLE);
  if (style & WS_OVERLAPPEDWINDOW) {
    MONITORINFO mi = {size_of(MONITORINFO)};
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
  #define X(RET, NAME, ...) NAME = cast(RET (WINAPI*)(__VA_ARGS__), GetProcAddress(lib, cast(u8*, #NAME)));
    HMODULE lib = LoadLibraryW(cast(u16*, L"USER32.DLL"));
    USER32_FUNCTIONS(X)
    lib = LoadLibraryW(cast(u16*, L"WS2_32.DLL"));
    WS2_32_FUNCTIONS(X)
    lib = LoadLibraryW(cast(u16*, L"DWMAPI.DLL"));
    DWMAPI_FUNCTIONS(X)
    lib = LoadLibraryW(cast(u16*, L"WINMM.DLL"));
    WINMM_FUNCTIONS(X)
  #undef X

  platform_hinstance = GetModuleHandleW(null);

  WSADATA wsadata;
  bool networking_supported = WSAStartup && WSAStartup(0x202, &wsadata) == 0;

  bool sleep_is_granular = timeBeginPeriod && timeBeginPeriod(1) == TIMERR_NOERROR;

  SetProcessDPIAware();
  WNDCLASSEXW wndclass = {};
  wndclass.cbSize = size_of(WNDCLASSEXW);
  wndclass.style = CS_OWNDC;
  wndclass.lpfnWndProc = [](HWND hwnd, u32 message, usize wParam, ssize lParam) -> ssize {
    switch (message) {
      case WM_PAINT:
        ValidateRect(hwnd, null);
        return 0;
      case WM_ERASEBKGND:
        return 1;
      case WM_ACTIVATEAPP: {
        bool tabbing_in = wParam != 0;
        if (tabbing_in) platform_update_cursor_clip();
        else platform_clear_held_keys();
        return 0;
      }
      case WM_SIZE: {
        platform_width = cast(u16, lParam);
        platform_height = cast(u16, lParam >> 16);
        return 0;
      }
      case WM_CREATE: {
        platform_hwnd = hwnd;
        platform_hdc = GetDC(hwnd);

        if (DwmSetWindowAttribute) {
          s32 dark_mode = true;
          DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &dark_mode, size_of(type_of(dark_mode)));
          s32 round_mode = DWMWCP_DONOTROUND;
          DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE, &round_mode, size_of(type_of(round_mode)));
        }
        return 0;
      }
      case WM_DESTROY:
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
  wndclass.lpszClassName = cast(u16*, L"A");
  RegisterClassExW(&wndclass);
  CreateWindowExW(0, wndclass.lpszClassName, cast(u16*, L"Outbreak Protocol"),
    WS_OVERLAPPEDWINDOW | WS_VISIBLE,
    CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
    null, null, platform_hinstance, null);

  for (;;) {
    MSG msg;
    while (PeekMessageW(&msg, null, 0, 0, PM_REMOVE)) {
      TranslateMessage(&msg);
      switch (msg.message) {
        case WM_KEYDOWN: // fallthrough;
        case WM_KEYUP: // fallthrough;
        case WM_SYSKEYDOWN: // fallthrough;
        case WM_SYSKEYUP: {
          bool pressed = (msg.lParam & (1 << 31)) == 0;
          bool repeat = pressed && (msg.lParam & (1 << 30)) != 0;
          bool sys = msg.message == WM_SYSKEYDOWN || msg.message == WM_SYSKEYUP;
          bool alt = sys && (msg.lParam & (1 << 29)) != 0;

          if (!repeat && (!sys || alt || msg.wParam == VK_MENU || msg.wParam == VK_F10)) {
            if (pressed) {
              if (msg.wParam == VK_F4 && alt) DestroyWindow(platform_hwnd);
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

    if (sleep_is_granular) {
      Sleep(1);
    }
  }
main_loop_end:

  if (networking_supported) WSACleanup();

  ExitProcess(0);
}
