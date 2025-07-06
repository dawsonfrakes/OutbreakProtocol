struct Game_Quad_Vertex {
  v3 position;
  v2 texcoord;
};

struct Game_Quad_Instance {
  xform transform;
};

static Game_Quad_Vertex quad_vertices[4] = {
  {{+0.5f, -0.5f, 0.0f}, {1.0f, 0.0f}},
  {{-0.5f, -0.5f, 0.0f}, {0.0f, 0.0f}},
  {{-0.5f, +0.5f, 0.0f}, {0.0f, 1.0f}},
  {{+0.5f, +0.5f, 0.0f}, {1.0f, 1.0f}},
};
static u16 quad_indices[6] = {0, 1, 2, 2, 3, 0};

struct Game_Renderer {
  v4 clear_color0;
  Bounded_Array<1024, Game_Quad_Instance> quad_instances;
};

static void game_update_and_render(Game_Renderer* renderer) {
  renderer->clear_color0 = {0.6f, 0.2f, 0.2f, 1.0f};

  renderer->quad_instances += {{{-0.5, -0.5, 0.0f}}};
  renderer->quad_instances += {{{+0.5, -0.5, 0.0f}}};
  renderer->quad_instances += {{{+0.5, +0.5, 0.0f}}};
  renderer->quad_instances += {{{-0.5, +0.5, 0.0f}}};
}
