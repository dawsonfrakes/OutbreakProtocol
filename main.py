from c4 import dtypes, entry, foreign, G, null, OSs, OS, struct

if OS == OSs.WINDOWS:
	# kernel32
	HINSTANCE = dtypes.Pointer[dtypes.Opaque["HINSTANCE"]]
	HMODULE = HINSTANCE

	@foreign("kernel32")
	def GetModuleHandleW(name: dtypes.Pointer[dtypes.CWChar]) -> HINSTANCE: ...
	@foreign("kernel32")
	def ExitProcess(exit_code: dtypes.CUInt) -> dtypes.NoReturn: ...

	# user32
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
		lpszMenuName: dtypes.Pointer[dtypes.CWChar]
		lpszClassName: dtypes.Pointer[dtypes.CWChar]
		hIconSm: HICON

	platform_hinstance: HINSTANCE

	@entry
	def WinMainCRTStartup() -> dtypes.NoReturn:
		G.platform_hinstance = GetModuleHandleW(null)
		print(G.platform_hinstance)
		ExitProcess(0)
