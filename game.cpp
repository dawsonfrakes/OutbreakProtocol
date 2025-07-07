struct Game_Quad_Vertex {
  v3 position;
  v2 texcoord;
};

struct Game_Quad_Instance {
  x2 transform;
};

struct Game_Mesh_Vertex {
  v3 position;
  v3 normal;
  v2 texcoord;
};

namespace Game_Mesh {
  typedef u32 Type;
  constexpr Type ERROR = 0;
  constexpr Type CUBE = 1;
  constexpr Type COUNT = 2;
}

struct Game_Mesh_Instance {
  x3 transform;
  Game_Mesh::Type mesh_index;
};

#include "static_mesh_data.cpp"

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

static f32 rr;

static void game_update_and_render(Game_Renderer* renderer) {
  rr += 0.001f;

  renderer->clear_color0 = {0.6f, 0.2f, 0.2f, 1.0f};

  renderer->camera2d.viewport_size = {1024.0f, 768.0f};

  renderer->camera.position = {0.0f, 0.0f, -5.0f};
  renderer->camera.fov_y = 0.25f;
  renderer->camera.aspect_ratio = 16.0f / 9.0f;
  renderer->camera.z_near = 0.1f;
  renderer->camera.z_far = 5000.0f;

  renderer->quad_instances += {{{-200, +0.5, 1.0f}, 0.0f, 100.0f}};
  u32 i = 0;
  for (f32 x = -5.0f; x <= 5.0f; x += 5.0f) {
  for (f32 y = -5.0f; y <= 5.0f; y += 5.0f) {
    renderer->mesh_instances += {{{x, y, 5.0f}, q4_from_euler({rr * (i % 2 == 0 ? 1 : -1), -rr, 0.0f}), 1.0f}, Game_Mesh::CUBE};
    i += 1;
  }
  }
}
