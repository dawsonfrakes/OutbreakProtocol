import basic;

version (Windows) {
  import basic.windows;

  __gshared HINSTANCE platform_hinstance;

  extern(Windows) noreturn WinMainCRTStartup() {
    platform_hinstance = GetModuleHandleW(null);

    SetProcessDPIAware();

    ExitProcess(0);
  }

  pragma(linkerDirective, "-subsystem:windows");
  pragma(lib, "kernel32");
  pragma(lib, "user32");
}

version (OSX) {
  import basic.macos;

  __gshared NSApplication platform_app;

  extern(C) noreturn main() {
    NSApplicationLoad();

    platform_app = NSApplication.sharedApplication();
    platform_app.setActivationPolicy(NSApplication.ActivationPolicy.REGULAR);

    _exit(0);
  }

  pragma(linkerDirective, "-framework", "AppKit");
}
