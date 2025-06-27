from c4.c4 import dtypes, entry, foreign, G, OSs, OS

if OS == OSs.WINDOWS:
	HINSTANCE = dtypes.Pointer[dtypes.Opaque()]

	@foreign("kernel32")
	def GetModuleHandleW(name: dtypes.CWString) -> HINSTANCE: ...
	@foreign("kernel32")
	def ExitProcess(status: dtypes.CUInt) -> dtypes.NoReturn: ...

	platform_hinstance: HINSTANCE

	@entry
	def WinMainCRTStartup() -> dtypes.NoReturn:
		G.platform_hinstance = GetModuleHandleW(None)

		ExitProcess(0)
elif OS == OSs.DARWIN:
	@foreign("System", alt_name="write")
	def sys_write(fd: dtypes.CInt, data: dtypes.Pointer[dtypes.CUChar], size: dtypes.USize) -> dtypes.SSize: ...
	@foreign("System", alt_name="_exit")
	def sys_exit(status: dtypes.CInt) -> dtypes.NoReturn: ...

	@entry(alt_name="_start")
	def start() -> dtypes.NoReturn:
		sys_exit(0)
