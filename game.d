import basic;

struct Game_Renderer {
  f32[4] clear_color0;
}

void game_update_and_render(Game_Renderer* renderer) {
  renderer.clear_color0 = [0.6, 0.2, 0.2, 1.0];
}

version (DLL) mixin DLLExport!game_update_and_render;
