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

struct Game_Renderer {
  f32[4] clear_color0;
  Bounded_Array!(1024, Game_Mesh_Instance) meshes;
}

void game_update_and_render(Game_Renderer* renderer) {
  renderer.clear_color0 = [0.6, 0.2, 0.2, 1.0];

  renderer.meshes ~= Game_Mesh_Instance(m4.identity, m4.identity);

}

version (DLL) mixin DLLExport!game_update_and_render;
