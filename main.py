from c4.c4 import dtypes, entry, foreign, G, OSs, OS, struct

if OS == OSs.WINDOWS:
	HINSTANCE = dtypes.Pointer[dtypes.Opaque["HINSTANCE"]]

	@foreign("kernel32")
	def GetModuleHandleW(name: dtypes.CWString) -> HINSTANCE: ...
	@foreign("kernel32")
	def ExitProcess(status: dtypes.CUInt) -> dtypes.NoReturn: ...

	HDC = dtypes.Pointer[dtypes.Opaque["HDC"]]
	HWND = dtypes.Pointer[dtypes.Opaque["HWND"]]
	HMENU = dtypes.Pointer[dtypes.Opaque["HMENU"]]
	HICON = dtypes.Pointer[dtypes.Opaque["HICON"]]
	HBRUSH = dtypes.Pointer[dtypes.Opaque["HBRUSH"]]
	HCURSOR = dtypes.Pointer[dtypes.Opaque["HCURSOR"]]
	HMONITOR = dtypes.Pointer[dtypes.Opaque["HMONITOR"]]
	WNDPROC = dtypes.Procedure[dtypes.SSize, [HWND, dtypes.CUInt, dtypes.USize, dtypes.SSize]]
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
		lpszMenuName: dtypes.CWString
		lpszClassName: dtypes.CWString
		hIconSm: HICON

	@foreign("user32")
	def SetProcessDPIAware() -> dtypes.CInt: ...

	platform_hinstance: HINSTANCE

	@entry
	def WinMainCRTStartup() -> dtypes.NoReturn:
		G.platform_hinstance = GetModuleHandleW(None)

		SetProcessDPIAware()

		ExitProcess(0)
elif OS == OSs.DARWIN:
	STDOUT_FILENO = 1

	@foreign("System")
	def write(fd: dtypes.CInt, data: dtypes.CVoidPointer, size: dtypes.USize) -> dtypes.SSize: ...
	@foreign("System", alt_name="_exit")
	def sys_exit(status: dtypes.CInt) -> dtypes.NoReturn: ...

	@entry(alt_name="_start")
	def start() -> dtypes.NoReturn:
		hw = b"Hello, world!\n"
		write(STDOUT_FILENO, hw, len(hw))
		sys_exit(0)
