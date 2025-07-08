import basic;
static import game;
import renderer : Platform_Renderer;

void null_renderer_init(Platform_Renderer.Init_Data*) {}
void null_renderer_deinit() {}
void null_renderer_resize(u16[2]) {}
void null_renderer_present(game.Game_Renderer*) {}

immutable null_renderer = Platform_Renderer(
  &null_renderer_init,
  &null_renderer_deinit,
  &null_renderer_resize,
  &null_renderer_present,
);
