import basic;
import renderer : Platform_Renderer;

version (Windows) {
  import basic.windows;

  void opengl_platform_init() {

  }

  void opengl_platform_deinit() {

  }

  void opengl_platform_present() {

  }

  pragma(lib, "gdi32");
  pragma(lib, "opengl32");
}

void opengl_init(Platform_Renderer.Init_Data* init_data) {

}

void opengl_deinit() {

}

void opengl_resize(ushort[2] size) {

}

void opengl_present() {

}

extern(C) export immutable opengl_renderer = Platform_Renderer(
  &opengl_init,
  &opengl_deinit,
  &opengl_resize,
  &opengl_present,
);
