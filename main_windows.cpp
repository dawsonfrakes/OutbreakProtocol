#include "basic.hpp"
#include "game.cpp"

#define WIN32_LEAN_AND_MEAN
#define UNICODE
#include <Windows.h>
#include <Winsock2.h>
#include <Dwmapi.h>
#include <mmsystem.h>
#include <hidusage.h>

static HINSTANCE platform_hinstance;
static HWND platform_hwnd;
static HDC platform_hdc;
static u16 platform_size[2];
static u16 platform_mouse[2];
static s32 platform_mouse_delta[2];

#include "renderer.cpp"

static Platform_Renderer* platform_renderer = &d3d11_renderer;

static void platform_toggle_fullscreen() {
  static WINDOWPLACEMENT save_placement = {sizeof(WINDOWPLACEMENT)};
  ssize style = GetWindowLongPtrW(platform_hwnd, GWL_STYLE);
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
    SetWindowPos(platform_hwnd, nullptr, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE |
      SWP_NOZORDER | SWP_FRAMECHANGED);
  }
}

static void platform_update_cursor_clip() {
  ClipCursor(nullptr);
}

static void platform_clear_held_keys() {

}

static void platform_debug_set_window_title_to_platform_renderer() {
  #if OP_DEBUG
    const wchar_t* title = L"Outbreak Protocol [Unknown]";
    if (platform_renderer == &d3d11_renderer) title = L"Outbreak Protocol [D3D11]";
    else if (platform_renderer == &opengl_renderer) title = L"Outbreak Protocol [OpenGL]";
    SetWindowTextW(platform_hwnd, title);
  #endif
}

static void platform_switch_renderer(Platform_Renderer* renderer) {
  platform_renderer->deinit();
  platform_renderer = renderer;
  platform_renderer->init();
  platform_renderer->resize();

  platform_debug_set_window_title_to_platform_renderer();
}

extern "C" [[noreturn]] void WINAPI WinMainCRTStartup() {
  platform_hinstance = GetModuleHandleW(nullptr);

  WSADATA wsadata;
  bool networking_supported = WSAStartup(0x202, &wsadata) == 0;

  bool sleep_is_granular = timeBeginPeriod(1) == TIMERR_NOERROR;

  SetProcessDPIAware();
  WNDCLASSEXW wndclass = {};
  wndclass.cbSize = sizeof(WNDCLASSEXW);
  wndclass.style = CS_OWNDC;
  wndclass.lpfnWndProc = [](HWND hwnd, u32 message, usize wParam, ssize lParam) -> ssize {
    switch (message) {
      case WM_INPUT: {
        RAWINPUT raw_input;
        u32 raw_input_size = sizeof(RAWINPUT);
        GetRawInputData(cast(HRAWINPUT, lParam), RID_INPUT, &raw_input, &raw_input_size, sizeof(RAWINPUTHEADER));

        if (raw_input.header.dwType == RIM_TYPEMOUSE) {
          if (raw_input.data.mouse.usFlags & MOUSE_MOVE_RELATIVE) {
            platform_mouse_delta[0] += raw_input.data.mouse.lLastX;
            platform_mouse_delta[1] += raw_input.data.mouse.lLastY;
          }
        }
        return 0;
      }
      case WM_PAINT:
        ValidateRect(hwnd, nullptr);
        return 0;
      case WM_ERASEBKGND:
        return 1;
      case WM_ACTIVATEAPP: {
        bool tabbing_in = wParam != 0;
        if (tabbing_in) platform_update_cursor_clip();
        else platform_clear_held_keys();
        return 0;
      }
      case WM_SIZE:
        platform_size[0] = cast(u16, lParam);
        platform_size[1] = cast(u16, lParam >> 16);

        platform_renderer->resize();
        return 0;
      case WM_CREATE: {
        platform_hwnd = hwnd;
        platform_hdc = GetDC(hwnd);

        RAWINPUTDEVICE raw_inputs[1] = {};
        raw_inputs[0].usUsagePage = HID_USAGE_PAGE_GENERIC;
        raw_inputs[0].usUsage = HID_USAGE_GENERIC_MOUSE;
        raw_inputs[0].hwndTarget = hwnd;
        RegisterRawInputDevices(raw_inputs, cast(u32, len(raw_inputs)), sizeof(RAWINPUTDEVICE));

        s32 dark_mode = true;
        DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &dark_mode, 4);
        s32 round_mode = DWMWCP_DONOTROUND;
        DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE, &round_mode, 4);

        platform_debug_set_window_title_to_platform_renderer();
        platform_renderer->init();
        return 0;
      }
      case WM_DESTROY:
        platform_renderer->deinit();

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
  wndclass.hIcon = LoadIconW(nullptr, IDI_WARNING);
  wndclass.hCursor = LoadCursorW(nullptr, IDC_CROSS);
  wndclass.lpszClassName = L"A";
  RegisterClassExW(&wndclass);
  CreateWindowExW(0, wndclass.lpszClassName, L"Outbreak Protocol",
    WS_OVERLAPPEDWINDOW | WS_VISIBLE,
    CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
    nullptr, nullptr, platform_hinstance, nullptr);

  for (;;) {
    memset(platform_mouse_delta, 0, size_of(platform_mouse_delta));

    MSG msg;
    while (PeekMessageW(&msg, nullptr, 0, 0, PM_REMOVE)) {
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
              if (OP_DEBUG && msg.wParam == VK_ESCAPE) DestroyWindow(platform_hwnd);
              if (msg.wParam == VK_F11) platform_toggle_fullscreen();
              if (msg.wParam == VK_RETURN && alt) platform_toggle_fullscreen();
              if (OP_DEBUG && msg.wParam == VK_F6) platform_switch_renderer(platform_renderer == &d3d11_renderer ? &opengl_renderer : &d3d11_renderer);
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

    Game_Renderer game_renderer = {};
    game_update_and_render(&game_renderer);
    platform_renderer->present(&game_renderer);

    if (sleep_is_granular) {
      Sleep(1);
    }
  }
main_loop_end:

  if (networking_supported) WSACleanup();

  ExitProcess(0);
}

extern "C" int _fltused = 0;
