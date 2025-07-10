import basic;
import basic.maths;

struct Game_Mesh_Vertex {
  align(16) v3 position;
  align(16) v3 normal;
  align(16) v2 texcoord;
  align(16) u32 texture_index;
}

struct Game_Mesh_Instance {
  align(16) m4 world_transform;
  align(16) m4 model_transform;
}

struct Game_Camera_3D {
  v3 position;
  f32 pitch;
  f32 yaw;
  f32 fov_y;
  f32 aspect_ratio;
  f32 z_near;
  f32 z_far;
}

struct Game_Renderer {
  f32[4] clear_color0;
  Game_Camera_3D camera;
  Bounded_Array!(1024, Game_Mesh_Instance) meshes;
}

struct Game_State {
  bool initted;
}

void game_update_and_render(u8[] memory, Game_Renderer* renderer) {
  assert(memory.length >= Game_State.sizeof);
  auto state = cast(Game_State*) memory.ptr;
  if (!state.initted) {
    state.initted = true;
  }

  renderer.clear_color0 = [0.6, 0.2, 0.2, 1.0];

  renderer.camera.position = v3(0.0, 0.0, -5.0);
  renderer.camera.pitch = 0.0;
  renderer.camera.yaw = 0.0;
  renderer.camera.fov_y = 0.25;
  renderer.camera.aspect_ratio = 16.0 / 9.0;
  renderer.camera.z_near = 0.1;
  renderer.camera.z_far = 1000.0;

  renderer.meshes ~= Game_Mesh_Instance(m4.identity, m4.identity);
}

version (DLL) mixin DLLExport!game_update_and_render;
