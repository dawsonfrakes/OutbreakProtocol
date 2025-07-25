module basic.windows;

import basic;

struct HINSTANCE__;
alias HINSTANCE = HINSTANCE__*;
alias HMODULE = HINSTANCE;
alias PROC = extern(Windows) ssize function();

@foreign("Kernel32") extern(Windows) {
  HMODULE GetModuleHandleW(const(wchar)*);
  HMODULE LoadLibraryW(const(wchar)*);
  PROC GetProcAddress(HMODULE, const(char)*);
  noreturn ExitProcess(u32);
}

@foreign("User32") extern(Windows) {
  s32 SetProcessDPIAware();
}
