struct Game_Input {
  f32 delta_time;
  s32 mouse_delta[2];
  bool keys[128];
};

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
  f32 pitch;
  f32 yaw;
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

struct Game_State {
  bool initted;

  v3 camera_position;
  f32 camera_pitch;
  f32 camera_yaw;

  f32 objects_rotation;
};

static void game_update_and_render(slice<u8> memory, Game_Input* input, Game_Renderer* renderer) {
  assert(memory.count >= sizeof(Game_State));
  Game_State* state = cast(Game_State*, memory.data);
  if (!state->initted) {
    state->initted = true;

    state->camera_position = {0.0f, 0.0f, -5.0f};
  }

  v3 direction = {};
  if (input->keys['W']) direction += {sin(state->camera_yaw), 0.0f, cos(state->camera_yaw)};
  if (input->keys['S']) direction += {-sin(state->camera_yaw), 0.0f, -cos(state->camera_yaw)};
  if (input->keys['D']) direction += {cos(state->camera_yaw), 0.0f, -sin(state->camera_yaw)};
  if (input->keys['A']) direction += {-cos(state->camera_yaw), 0.0f, sin(state->camera_yaw)};
  if (input->keys['E']) direction.y += 1.0f;
  if (input->keys['Q']) direction.y -= 1.0f;
  direction = normalize(direction);
  state->camera_position += direction * 10.0f * input->delta_time;

  state->camera_yaw += cast(f32, input->mouse_delta[0]) * 0.1f * input->delta_time;
  state->camera_pitch += cast(f32, input->mouse_delta[1]) * 0.1f * input->delta_time;
  state->camera_pitch = clamp(state->camera_pitch, -0.24f, 0.24f);

  renderer->clear_color0 = {0.6f, 0.2f, 0.2f, 1.0f};

  renderer->camera2d.viewport_size = {1024.0f, 768.0f};

  renderer->camera.position = state->camera_position;
  renderer->camera.pitch = state->camera_pitch;
  renderer->camera.yaw = state->camera_yaw;
  renderer->camera.fov_y = 0.25f;
  renderer->camera.aspect_ratio = 16.0f / 9.0f;
  renderer->camera.z_near = 0.1f;
  renderer->camera.z_far = 5000.0f;

  state->objects_rotation += 0.5f * input->delta_time;

  renderer->quad_instances += {{{-200, +0.5, 1.0f}, 0.0f, 100.0f}};

  u32 i = 0;
  for (f32 x = -5.0f; x <= 5.0f; x += 5.0f) {
  for (f32 y = -5.0f; y <= 5.0f; y += 5.0f) {
    renderer->mesh_instances += {{{x, y, 5.0f}, q4_from_euler({state->objects_rotation * (i % 2 == 0 ? 1 : -1), -state->objects_rotation, 0.0f}), 1.0f}, Game_Mesh::CUBE};
    i += 1;
  }
  }
}
