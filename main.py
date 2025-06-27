from c4.c4 import dtypes, entry, foreign, G, OSs, OS, struct

if OS == OSs.WINDOWS:
	# kernel32
	HINSTANCE = dtypes.Pointer[dtypes.Opaque["HINSTANCE"]]

	@foreign("kernel32")
	def GetModuleHandleW(name: dtypes.CWString) -> HINSTANCE: ...
	@foreign("kernel32")
	def ExitProcess(status: dtypes.CUInt) -> dtypes.NoReturn: ...

	# user32
	CS_OWNDC = 0x0020
	WM_CREATE = 0x0001
	WM_DESTROY = 0x0002

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
	@foreign("user32")
	def RegisterClassExW(wndclass: dtypes.Pointer[WNDCLASSEXW]) -> dtypes.CUShort: ...
	@foreign("user32")
	def DefWindowProcW(hwnd: HWND, message: dtypes.CUInt, wParam: dtypes.USize, lParam: dtypes.SSize) -> dtypes.SSize: ...
	@foreign("user32")
	def PostQuitMessage(status: dtypes.CInt) -> dtypes.Void: ...

	platform_hinstance: HINSTANCE

	@entry
	def WinMainCRTStartup() -> dtypes.NoReturn:
		G.platform_hinstance = GetModuleHandleW(None)

		SetProcessDPIAware()
		wndclass = WNDCLASSEXW()
		wndclass.cbSize = dtypes.size_of(WNDCLASSEXW)
		wndclass.style = CS_OWNDC
		def wndproc(hwnd: HWND, message: dtypes.CUInt, wParam: dtypes.USize, lParam: dtypes.SSize) -> dtypes.SSize:
			if message == WM_DESTROY:
				PostQuitMessage(0)
				return 0
			else:
				return DefWindowProcW(hwnd, message, wParam, lParam)
		wndclass.lpfnWndProc = wndproc
		wndclass.hInstance = platform_hinstance
		wndclass.lpszClassName = b"A"
		RegisterClassExW(wndclass)

		ExitProcess(0)
elif OS == OSs.DARWIN:
	STDOUT_FILENO = 1

	@foreign("System")
	def write(fd: dtypes.CInt, data: dtypes.CVoidPointer, size: dtypes.USize) -> dtypes.SSize: ...
	@foreign("System", alt_name="_exit")
	def sys_exit(status: dtypes.CInt) -> dtypes.NoReturn: ...

	# @objc_class
	# class NSApplication:
	# 	@staticmethod
	# 	def sharedApplication() -> dtypes.Pointer["NSApplication"]: ...

	# platform_app: dtypes.Pointer[NSApplication]

	@entry(alt_name="_start")
	def start() -> dtypes.NoReturn:
		# G.app = NSApplication.sharedApplication()
		hw = b"Hello, world!\n"
		write(STDOUT_FILENO, hw, len(hw))
		sys_exit(0)
