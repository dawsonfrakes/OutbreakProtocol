import basic;
import basic.maths;

struct Renderer {
  f32[4] clear_color0;
  f32 clear_depth;
}

extern(C) void game_update_and_render(Renderer* renderer) {
  renderer.clear_color0 = [0.6, 0.2, 0.2, 1.0];
  renderer.clear_depth = 0.0;
}
