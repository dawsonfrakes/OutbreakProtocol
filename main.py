from c4 import dtypes, entry, foreign, G, OSs, OS

if OS == OSs.WINDOWS:
  type HINSTANCE = dtypes.Pointer[dtypes.Opaque]

  @foreign("kernel32")
  def GetModuleHandleW(name: dtypes.Pointer[dtypes.CUShort]) -> HINSTANCE: ...
  @foreign("kernel32")
  def ExitProcess(status: dtypes.CUInt) -> dtypes.NoReturn: ...

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
