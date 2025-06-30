from c4 import dtypes, entry, foreign, G, OSs, OS, addr_of, size_of, struct

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
	WNDPROC = dtypes.Procedure[dtypes.SSize, HWND, dtypes.CUInt, dtypes.USize, dtypes.SSize]
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
		lpszMenuName: dtypes.Pointer[dtypes.CWChar]
		lpszClassName: dtypes.Pointer[dtypes.CWChar]
		hIconSm: HICON

	@foreign("user32")
	def RegisterClassExW(wndclass: dtypes.Pointer[WNDCLASSEXW]) -> dtypes.CUShort: ...

	platform_hinstance: HINSTANCE

	@entry
	def WinMainCRTStartup() -> dtypes.NoReturn:
		G.platform_hinstance = GetModuleHandleW(None)

		wndclass = WNDCLASSEXW()
		wndclass.cbSize = size_of(WNDCLASSEXW)
		RegisterClassExW(addr_of(wndclass))

		ExitProcess(0)
elif OS == OSs.DARWIN:
	@foreign("System", alt_name="_exit")
	def sys_exit(exit_code: dtypes.CInt) -> dtypes.NoReturn: ...

	@entry(alt_name="_start")
	def start() -> dtypes.NoReturn:
		sys_exit(0)
