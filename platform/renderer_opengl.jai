opengl_init :: () #no_context {

}

opengl_deinit :: () #no_context {

}

opengl_resize :: () #no_context {

}

opengl_present :: () #no_context {

}

opengl_renderer := PlatformRenderer.{
  "OpenGL",
  opengl_init,
  opengl_deinit,
  opengl_resize,
  opengl_present,
};
