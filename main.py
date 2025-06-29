from c4.c4 import dtypes, entry, foreign, G, OSs, OS, struct

if OS == OSs.WINDOWS:
	HINSTANCE = dtypes.Pointer[dtypes.Void]

	@foreign("kernel32")
	def GetModuleHandleW(name: dtypes.Optional[dtypes.Pointer[dtypes.CWChar]]) -> dtypes.Optional[HINSTANCE]: ...
	@foreign("kernel32")
	def ExitProcess(exit_code: dtypes.CUInt) -> dtypes.NoReturn: ...

	HDC = dtypes.Pointer[dtypes.Void]
	HWND = dtypes.Pointer[dtypes.Void]
	HMENU = dtypes.Pointer[dtypes.Void]
	HICON = dtypes.Pointer[dtypes.Void]
	HBRUSH = dtypes.Pointer[dtypes.Void]
	HCURSOR = dtypes.Pointer[dtypes.Void]
	HMONITOR = dtypes.Pointer[dtypes.Void]
	WNDPROC = dtypes.Procedure[[HWND, dtypes.CUInt, dtypes.USize, dtypes.SSize], dtypes.SSize]
	@struct
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
		lpszMenuName: dtypes.Optional[dtypes.Pointer[dtypes.CWChar]]
		lpszClassName: dtypes.Optional[dtypes.Pointer[dtypes.CWChar]]
		hIconSm: HICON

	@foreign("user32")
	def SetProcessDPIAware() -> dtypes.CInt: ...
	@foreign("user32")
	def RegisterClassExW(wndclass: dtypes.Optional[dtypes.Pointer[WNDCLASSEXW]]) -> dtypes.CUShort: ...

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
