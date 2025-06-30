package main

import gl "vendor:OpenGL"

opengl_init :: proc() {
	opengl_platform_init()
}

opengl_deinit :: proc() {
	opengl_platform_deinit()
}

opengl_resize :: proc() {
	opengl_platform_resize()
}

opengl_present :: proc() {
	gl.ClearColor(0.6, 0.2, 0.2, 1.0)
	gl.Clear(gl.COLOR_BUFFER_BIT)
	opengl_platform_present()
}

opengl_renderer :: Platform_Renderer{
	opengl_init,
	opengl_deinit,
	opengl_resize,
	opengl_present,
}
