from c4 import dtypes, entry, foreign, G, OSs, OS

if OS == OSs.WINDOWS:
  @opaque()
  class HINSTANCE: pass

  @foreign("kernel32")
  def GetModuleHandleW(name: dtypes.Pointer[dtypes.CUShort]) -> HINSTANCE: ...
  @foreign("kernel32")
  def ExitProcess(status: dtypes.CUInt) -> dtypes.NoReturn: ...

  @opaque()
  class HDC: pass
  @opaque()
  class HWND: pass
  @opaque()
  class HMENU: pass
  @opaque()
  class HICON: pass
  @opaque()
  class HBRUSH: pass
  @opaque()
  class HCURSOR: pass
  @opaque()
  class HMONITOR: pass
  type WNDPROC = dtypes.Procedure[[HWND, dtypes.CUInt, dtypes.USize, dtypes.SSize], dtypes.SSize]

  @struct()
  class WNDCLASSEXW:
    cbSize: dtypes.CUInt
    style: dtypes.CUInt
    lpfnWndProc: WNDPROC
    cbClsExtra: dtypes.CInt
    cbWndExtra: dtypes.CInt
    hInstance: HINSTANCE
    hIcon: HICON
    hCursor: HCURSOR
    hbrBackground: HBRUSH
    lpszMenuName: dtypes.Pointer[dtypes.CUShort]
    lpszClassName: dtypes.Pointer[dtypes.CUShort]
    hIconSm: HICON

  @foreign("user32")
  def SetProcessDPIAware() -> dtypes.CInt: ...

  platform_hinstance: HINSTANCE

  @entry()
  def WinMainCRTStartup() -> dtypes.NoReturn:
    G.platform_hinstance = GetModuleHandleW(None)

    SetProcessDPIAware()

    ExitProcess(0)
elif OS == OSs.DARWIN:
  STDOUT_FILENO = 1

  @foreign("System", alt_name="write")
  def sys_write(fd: dtypes.CInt, data: dtypes.Pointer[dtypes.CUChar], size: dtypes.USize) -> dtypes.SSize: ...
  @foreign("System", alt_name="_exit")
  def sys_exit(status: dtypes.CInt) -> dtypes.NoReturn: ...

  @entry(alt_name="Hello")
  def start() -> dtypes.NoReturn:
    hw = b"Hello, world!\n"
    sys_write(STDOUT_FILENO, hw, len(hw))
    sys_exit(0)
