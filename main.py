from c4.c4 import dtypes, entry, foreign, G, OSs, OS

if OS == OSs.WINDOWS:
	HINSTANCE = dtypes.Pointer[dtypes.Opaque[...]]

	@foreign("kernel32")
	def GetModuleHandleW(name: dtypes.Optional[dtypes.Pointer[dtypes.CWChar]]) -> dtypes.Optional[HINSTANCE]: ...
	@foreign("kernel32")
	def ExitProcess(exit_code: dtypes.CUInt) -> dtypes.NoReturn: ...

	@foreign("user32")
	def SetProcessDPIAware() -> dtypes.CInt: ...

	platform_hinstance: HINSTANCE

	@entry
	def WinMainCRTStartup() -> dtypes.NoReturn:
		G.platform_hinstance = GetModuleHandleW(None)

		SetProcessDPIAware()

		ExitProcess(0)
elif OS == OSs.DARWIN:
	@foreign("System", alt_name="_exit")
	def sys_exit(status: dtypes.CInt) -> dtypes.NoReturn: ...

	@entry(alt_name="_start")
	def start() -> dtypes.NoReturn:
		sys_exit(0)
