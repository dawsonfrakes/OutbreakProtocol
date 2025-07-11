import basic;
import basic.windows;

extern(Windows) noreturn WinMainCRTStartup() {
  ExitProcess(0);
}

extern(Windows) int _fltused;

pragma(linkerDirective, "-subsystem:windows");
pragma(lib, "Kernel32");
pragma(lib, "User32");
pragma(lib, "Ws2_32");
pragma(lib, "Dwmapi");
pragma(lib, "Winmm");
