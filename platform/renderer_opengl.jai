opengl_init :: (init_data: PlatformRenderer.Init) #no_context {

}

opengl_deinit :: () #no_context {

}

opengl_resize :: (resize_data: PlatformRenderer.Resize) #no_context {

}

opengl_present :: (present_data: PlatformRenderer.Present) #no_context {

}

opengl_renderer := PlatformRenderer.{
  "OpenGL",
  opengl_init,
  opengl_deinit,
  opengl_resize,
  opengl_present,
};
