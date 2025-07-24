import basic;
import basic.windows;

__gshared {
  HINSTANCE platform_hinstance;
}

extern(Windows) noreturn WinMainCRTStartup() {
  platform_hinstance = GetModuleHandleW(null);

  SetProcessDPIAware();
  WNDCLASSEXW wndclass;
  wndclass.cbSize = WNDCLASSEXW.sizeof;
  wndclass.style = CS_OWNDC;
  wndclass.lpfnWndProc = (hwnd, message, wParam, lParam) {
    switch (message) {
      case WM_DESTROY:
        PostQuitMessage(0);
        return 0;
      default:
        return DefWindowProcW(hwnd, message, wParam, lParam);
    }
  };
  wndclass.lpszClassName = "A";
  RegisterClassExW(&wndclass);

  ExitProcess(0);
}

pragma(linkerDirective, "-subsystem:windows");
pragma(lib, "Kernel32");
pragma(lib, "User32");
