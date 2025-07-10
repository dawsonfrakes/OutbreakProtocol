#import "Basic2";

#if OS == .WINDOWS {
  #import "Windows2";
}

opengl_init :: () #no_context {

}

opengl_deinit :: () #no_context {

}

opengl_resize :: () #no_context {

}

opengl_present :: () #no_context {

}

opengl_renderer := Platform_Renderer.{
  "OpenGL",
  opengl_init,
  opengl_deinit,
  opengl_resize,
  opengl_present,
};
