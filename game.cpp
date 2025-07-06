struct Game_Quad_Vertex {
  v3 position;
  v2 texcoord;
};

#define GAME_QUAD_INSTANCES_MAX 1024
struct Game_Quad_Instance {
  v3 position;
};

static Game_Quad_Vertex quad_vertices[4] = {
  {{+0.5f, -0.5f, 0.0f}, {1.0f, 0.0f}},
  {{-0.5f, -0.5f, 0.0f}, {0.0f, 0.0f}},
  {{-0.5f, +0.5f, 0.0f}, {0.0f, 1.0f}},
  {{+0.5f, +0.5f, 0.0f}, {1.0f, 1.0f}},
};
static u16 quad_indices[6] = {0, 1, 2, 2, 3, 0};
static Game_Quad_Instance game_quad_instances[2] = {
  {{+0.5f, 0.0f, 0.0f}},
  {{-0.5f, 0.0f, 0.0f}},
};

struct Game_Renderer {
  v4 clear_color0;
};

static void game_update_and_render(Game_Renderer* renderer) {
  renderer->clear_color0 = {0.6f, 0.2f, 0.2f, 1.0f};
}
