import basic;
import renderer : Platform_Renderer;

void null_renderer_init(Platform_Renderer.Init_Data*) {}
void null_renderer_proc() {}

__gshared immutable null_renderer = Platform_Renderer(
  &null_renderer_init,
  &null_renderer_proc,
  &null_renderer_proc,
  &null_renderer_proc,
);
