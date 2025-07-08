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
}

void opengl_init() {

}

void opengl_deinit() {

}

void opengl_resize() {

}

void opengl_present() {

}

extern(C) export immutable opengl_renderer = Platform_Renderer(
  &opengl_init,
  &opengl_deinit,
  &opengl_resize,
  &opengl_present,
);
