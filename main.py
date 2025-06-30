from c4 import dtypes, entry, foreign, G, OSs, OS

if OS == OSs.WINDOWS:
	# kernel32
	HINSTANCE = dtypes.Pointer[...]

	@foreign("kernel32")
	def GetModuleHandleW(name: dtypes.Pointer[dtypes.CWChar]) -> HINSTANCE: ...
	@foreign("kernel32")
	def ExitProcess(exit_code: dtypes.CUInt) -> dtypes.NoReturn: ...

	# user32
	HDC = dtypes.Pointer[...]
	HWND = dtypes.Pointer[...]
	HMENU = dtypes.Pointer[...]
	HICON = dtypes.Pointer[...]
	HBRUSH = dtypes.Pointer[...]
	HCURSOR = dtypes.Pointer[...]
	HMONITOR = dtypes.Pointer[...]

	platform_hinstance: HINSTANCE

	@entry
	def WinMainCRTStartup() -> dtypes.NoReturn:
		G.platform_hinstance = GetModuleHandleW(None)
		ExitProcess(0)
elif OS == OSs.DARWIN:
	@foreign("System", alt_name="_exit")
	def sys_exit(exit_code: dtypes.CInt) -> dtypes.NoReturn: ...

	@entry(alt_name="_start")
	def start() -> dtypes.NoReturn:
		sys_exit(0)
