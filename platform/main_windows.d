import basic;
import basic.windows;

__gshared {
  HINSTANCE platform_hinstance;
  HWND platform_hwnd;
  HDC platform_hdc;
  u16 platform_width;
  u16 platform_height;
}

extern(Windows) noreturn WinMainCRTStartup() {
  platform_hinstance = GetModuleHandleW(null);

  ExitProcess(0);
}

pragma(linkerDirective, "-subsystem:windows");
pragma(lib, "Kernel32");
pragma(lib, "User32");
pragma(lib, "Ws2_32");
pragma(lib, "Dwmapi");
pragma(lib, "Winmm");
