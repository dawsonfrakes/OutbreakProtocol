import basic;
import platform.renderer;

void opengl_init() {

}

void opengl_deinit() {

}

void opengl_resize() {

}

void opengl_present() {

}

package template Exports() {
  __gshared immutable opengl_renderer = PlatformRenderer(
    "OpenGL",
    &opengl_init,
    &opengl_deinit,
    &opengl_resize,
    &opengl_present,
  );
}

mixin ExportIfVersionDLLElseDefine!Exports;
