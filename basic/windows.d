module basic.windows;

import basic;

// kernel32
alias HRESULT = int;
struct HINSTANCE__; alias HINSTANCE = HINSTANCE__*;
alias HMODULE = HINSTANCE;

@foreign("kernel32") extern(Windows) HMODULE GetModuleHandleW(const(wchar)*);
@foreign("kernel32") extern(Windows) noreturn ExitProcess(uint);

// user32
@foreign("user32") extern(Windows) int SetProcessDPIAware();

// ole32
align(1) struct GUID {
  uint Data1;
  ushort Data2;
  ushort Data3;
  ubyte[8] Data4;
}
alias IID = const(GUID);

extern(Windows) interface IUnknown {
  immutable uuidof = IID(0x00000000, 0x0000, 0x0000, [0xC0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x46]);

  HRESULT QueryInterface(IID*, void**);
  uint AddRef();
  uint Release();
}
