struct Game_Quad_Vertex {
  v3 position;
  v2 texcoord;
};

struct Game_Quad_Instance {
  x2 transform;
};

static Game_Quad_Vertex quad_vertices[4] = {
  {{+0.5f, -0.5f, 0.0f}, {1.0f, 0.0f}},
  {{-0.5f, -0.5f, 0.0f}, {0.0f, 0.0f}},
  {{-0.5f, +0.5f, 0.0f}, {0.0f, 1.0f}},
  {{+0.5f, +0.5f, 0.0f}, {1.0f, 1.0f}},
};
static u16 quad_indices[6] = {0, 1, 2, 2, 3, 0};

struct Game_Mesh_Vertex {
  v3 position;
  // v3 normal;
  // v2 texcoord;
};

enum struct Game_Mesh : u32 {
  ERROR = 0,
  CUBE = 1,
  COUNT,
};

static Game_Mesh_Vertex cube_vertices[8] = {
  {{-1.0f, -1.0f, -1.0f}},
  {{-1.0f, -1.0f, +1.0f}},
  {{-1.0f, +1.0f, -1.0f}},
  {{-1.0f, +1.0f, +1.0f}},
  {{+1.0f, -1.0f, -1.0f}},
  {{+1.0f, -1.0f, +1.0f}},
  {{+1.0f, +1.0f, -1.0f}},
  {{+1.0f, +1.0f, +1.0f}},
};
static u16 cube_indices[12] = {
  // front
  0, 2, 6, 6, 4, 0,
  // back
  5, 7, 3, 3, 1, 5,
};

struct Game_Mesh_Instance {
  x3 transform;
  Game_Mesh mesh_index;
};

struct Game_Camera_2D {
  v2 position;
  v2 viewport_size;
};

struct Game_Camera_3D {
  v3 position;
  v3 rotation;
  f32 fov_y;
  f32 aspect_ratio;
  f32 z_near;
  f32 z_far;
};

struct Game_Renderer {
  v4 clear_color0;
  Game_Camera_2D camera2d;
  Game_Camera_3D camera;
  Bounded_Array<1024, Game_Quad_Instance> quad_instances;
  Bounded_Array<1024, Game_Mesh_Instance> mesh_instances;
};

static void game_update_and_render(Game_Renderer* renderer) {
  renderer->clear_color0 = {0.6f, 0.2f, 0.2f, 1.0f};

  renderer->camera2d.viewport_size = {1024.0f, 768.0f};

  renderer->camera.position = {0.0f, 0.0f, -5.0f};
  renderer->camera.fov_y = 0.25f;
  renderer->camera.aspect_ratio = 16.0f / 9.0f;
  renderer->camera.z_near = 0.1f;
  renderer->camera.z_far = 5000.0f;

  renderer->quad_instances += {{{-200, +0.5, 0.0f}, 0.0f, 100.0f}};
  renderer->mesh_instances += {{5.0f, q4_from_euler(0.0f), 1.0f}, Game_Mesh::CUBE};
}
