package main

import "core:c"
import w "core:sys/windows"
import gl "vendor:OpenGL"

@(private="file")
G: struct {
	initted: bool,
	ctx: w.HGLRC,
}

opengl_platform_init :: proc() {
	pfd: w.PIXELFORMATDESCRIPTOR
	pfd.nSize = size_of(w.PIXELFORMATDESCRIPTOR)
	pfd.nVersion = 1
	pfd.dwFlags = w.PFD_DRAW_TO_WINDOW | w.PFD_SUPPORT_OPENGL | w.PFD_DOUBLEBUFFER | w.PFD_DEPTH_DONTCARE
	pfd.cColorBits = 24
	format := w.ChoosePixelFormat(platform_hdc, &pfd)
	w.SetPixelFormat(platform_hdc, format, &pfd)

	temp_ctx := w.wglCreateContext(platform_hdc)
	w.wglMakeCurrent(platform_hdc, temp_ctx)

	wglCreateContextAttribsARB := cast(w.CreateContextAttribsARBType) w.wglGetProcAddress("wglCreateContextAttribsARB")
	attribs := []c.int{
		w.WGL_CONTEXT_MAJOR_VERSION_ARB, 4,
		w.WGL_CONTEXT_MINOR_VERSION_ARB, 6,
		w.WGL_CONTEXT_FLAGS_ARB, w.WGL_CONTEXT_DEBUG_BIT_ARB when ODIN_DEBUG else 0,
		w.WGL_CONTEXT_PROFILE_MASK_ARB, w.WGL_CONTEXT_CORE_PROFILE_BIT_ARB,
		0,
	}
	G.ctx = wglCreateContextAttribsARB(platform_hdc, nil, raw_data(attribs))
	w.wglMakeCurrent(platform_hdc, G.ctx)

	w.wglDeleteContext(temp_ctx)

	gl.load_1_0(w.gl_set_proc_address)
	gl.load_1_1(w.gl_set_proc_address)
	gl.load_2_0(w.gl_set_proc_address)
	gl.load_3_0(w.gl_set_proc_address)
	gl.load_3_1(w.gl_set_proc_address)
	gl.load_4_0(w.gl_set_proc_address)
	gl.load_4_1(w.gl_set_proc_address)
	gl.load_4_2(w.gl_set_proc_address)
	gl.load_4_3(w.gl_set_proc_address)
	gl.load_4_4(w.gl_set_proc_address)
	gl.load_4_5(w.gl_set_proc_address)
	gl.load_4_6(w.gl_set_proc_address)

	G.initted = true
}

opengl_platform_deinit :: proc() {
	if G.ctx != nil do w.wglDeleteContext(G.ctx)
	G = {}
}

opengl_platform_resize :: proc() {

}

opengl_platform_present :: proc() {
	w.SwapBuffers(platform_hdc)
}
