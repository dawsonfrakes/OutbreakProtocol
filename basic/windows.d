module basic.windows;

import basic;

alias HRESULT = s32;
struct HINSTANCE__; alias HINSTANCE = HINSTANCE__*;
alias HMODULE = HINSTANCE;
alias PROC = extern(Windows) ssize function();

@foreign("Kernel32") extern(Windows) {
  HMODULE GetModuleHandleW(const(wchar)*);
  noreturn ExitProcess(u32);
}

enum CS_OWNDC = 0x0020;
enum PM_REMOVE = 0x0001;
enum WM_CREATE = 0x0001;
enum WM_DESTROY = 0x0002;

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

@foreign("User32") extern(Windows) {
  s32 SetProcessDPIAware();
  u16 RegisterClassExW(const(WNDCLASSEXW)*);
  void PostQuitMessage(s32);
  ssize DefWindowProcW(HWND, u32, usize, ssize);
}
