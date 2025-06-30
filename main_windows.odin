package main

RENDERER :: #config(RENDERER, "OPENGL")
renderer :: opengl_renderer when RENDERER == "OPENGL" else d3d11_renderer when RENDERER == "D3D11" else nil

import "base:intrinsics"
import w "core:sys/windows"

platform_hinstance: w.HINSTANCE
platform_hwnd: w.HWND
platform_hdc: w.HDC
platform_size: [2]u16

toggle_fullscreen :: proc() {
	@static save_placement := w.WINDOWPLACEMENT{length=size_of(w.WINDOWPLACEMENT)}
	style := w.GetWindowLongPtrW(platform_hwnd, w.GWL_STYLE)
	if style & int(w.WS_OVERLAPPEDWINDOW) != 0 {
		mi := w.MONITORINFO{cbSize=size_of(w.MONITORINFO)}
		w.GetMonitorInfoW(w.MonitorFromWindow(platform_hwnd, .MONITOR_DEFAULTTOPRIMARY), &mi)

		w.GetWindowPlacement(platform_hwnd, &save_placement)
		w.SetWindowLongPtrW(platform_hwnd, w.GWL_STYLE, style & ~int(w.WS_OVERLAPPEDWINDOW))
		w.SetWindowPos(platform_hwnd, w.HWND_TOP, mi.rcMonitor.left, mi.rcMonitor.top,
			mi.rcMonitor.right - mi.rcMonitor.left,
			mi.rcMonitor.bottom - mi.rcMonitor.top,
			w.SWP_FRAMECHANGED)
	} else {
		w.SetWindowLongPtrW(platform_hwnd, w.GWL_STYLE, style | int(w.WS_OVERLAPPEDWINDOW))
		w.SetWindowPlacement(platform_hwnd, &save_placement)
		w.SetWindowPos(platform_hwnd, nil, 0, 0, 0, 0, w.SWP_NOMOVE | w.SWP_NOSIZE |
			w.SWP_NOZORDER | w.SWP_FRAMECHANGED)
	}
}

update_cursor_clip :: proc() {
	w.ClipCursor(nil)
}

clear_held_keys :: proc() {

}

main :: proc() {
	platform_hinstance = w.HINSTANCE(w.GetModuleHandleW(nil))

	sleep_is_granular := w.timeBeginPeriod(1) == w.TIMERR_NOERROR

	w.SetProcessDPIAware()
	wndclass: w.WNDCLASSEXW
	wndclass.cbSize = size_of(w.WNDCLASSEXW)
	wndclass.style = w.CS_OWNDC
	wndclass.lpfnWndProc = proc "std" (hwnd: w.HWND, message: u32, wParam: uintptr, lParam: int) -> int {
		context = {}
		switch message {
			case w.WM_PAINT: w.ValidateRect(hwnd, nil)
			case w.WM_ERASEBKGND: return 1
			case w.WM_ACTIVATEAPP:
				tabbing_in := wParam != 0
				if tabbing_in do update_cursor_clip()
				else do clear_held_keys()
			case w.WM_SIZE:
				platform_size = {u16(lParam), u16(lParam >> 16)}

				renderer.resize()
			case w.WM_CREATE:
				platform_hwnd = hwnd
				platform_hdc = w.GetDC(hwnd)

				dark_mode: b32 = true
				w.DwmSetWindowAttribute(hwnd, u32(w.DWMWINDOWATTRIBUTE.DWMWA_USE_IMMERSIVE_DARK_MODE), &dark_mode, size_of(type_of(dark_mode)))
				round_mode := w.DWM_WINDOW_CORNER_PREFERENCE.DONOTROUND
				w.DwmSetWindowAttribute(hwnd, u32(w.DWMWINDOWATTRIBUTE.DWMWA_WINDOW_CORNER_PREFERENCE), &round_mode, size_of(type_of(round_mode)))

				renderer.init()
			case w.WM_DESTROY:
				renderer.deinit()

				w.PostQuitMessage(0)
			case w.WM_SYSCOMMAND: if wParam == w.SC_KEYMENU do return 0; fallthrough
			case: return w.DefWindowProcW(hwnd, message, wParam, lParam)
		}
		return 0
	}
	wndclass.hInstance = platform_hinstance
	wndclass.hIcon = w.LoadIconW(nil, transmute([^]u16) w.IDI_WARNING)
	wndclass.hCursor = w.LoadCursorW(nil, transmute([^]u16) w.IDC_CROSS)
	wndclass.lpszClassName = intrinsics.constant_utf16_cstring("A")
	w.RegisterClassExW(&wndclass)
	w.CreateWindowExW(0, wndclass.lpszClassName, intrinsics.constant_utf16_cstring("Outbreak Protocol"),
		w.WS_OVERLAPPEDWINDOW | w.WS_VISIBLE,
		w.CW_USEDEFAULT, w.CW_USEDEFAULT, w.CW_USEDEFAULT, w.CW_USEDEFAULT,
		nil, nil, platform_hinstance, nil)

	main_loop: for {
		msg: w.MSG = ---
		for w.PeekMessageW(&msg, nil, 0, 0, w.PM_REMOVE) {
			w.TranslateMessage(&msg)
			switch msg.message {
				case w.WM_KEYDOWN: fallthrough
				case w.WM_KEYUP: fallthrough
				case w.WM_SYSKEYDOWN: fallthrough
				case w.WM_SYSKEYUP:
					pressed := msg.lParam & (1 << 31) == 0
					repeat := pressed && msg.lParam & (1 << 30) != 0
					sys := msg.message == w.WM_SYSKEYDOWN || msg.message == w.WM_SYSKEYUP
					alt := sys && msg.lParam & (1 << 29) != 0

					if !repeat && (!sys || alt || msg.wParam == w.VK_MENU || msg.wParam == w.VK_F10) {
						if pressed {
							if msg.wParam == w.VK_F4 && alt do w.DestroyWindow(platform_hwnd)
							if ODIN_DEBUG && msg.wParam == w.VK_ESCAPE do w.DestroyWindow(platform_hwnd)
							if msg.wParam == w.VK_F11 do toggle_fullscreen()
							if msg.wParam == w.VK_RETURN && alt do toggle_fullscreen()
						}
					}
				case w.WM_QUIT: break main_loop
				case: w.DispatchMessageW(&msg)
			}
		}

		renderer.present()
	}
}
