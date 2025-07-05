struct Game_Renderer {
  f32 clear_color0[4];
};

static void game_update_and_render(Game_Renderer* renderer) {
  renderer->clear_color0[0] = 0.6f;
  renderer->clear_color0[1] = 0.2f;
  renderer->clear_color0[2] = 0.2f;
  renderer->clear_color0[3] = 1.0f;
}
