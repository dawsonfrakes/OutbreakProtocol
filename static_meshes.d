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

__gshared Game_Mesh_Vertex[4] mesh_vertices = [
  Game_Mesh_Vertex(position: v3(-0.5, -0.5, 0.0), texcoord: v2(0.0, 0.0)),
  Game_Mesh_Vertex(position: v3(-0.5, +0.5, 0.0), texcoord: v2(0.0, 1.0)),
  Game_Mesh_Vertex(position: v3(+0.5, +0.5, 0.0), texcoord: v2(1.0, 1.0)),
  Game_Mesh_Vertex(position: v3(+0.5, -0.5, 0.0), texcoord: v2(1.0, 0.0)),
];
__gshared u16[6] mesh_indices = [0, 1, 2, 2, 3, 0];
__gshared Game_Mesh_Instance[1] mesh_instances = [
  Game_Mesh_Instance(world_transform: m4.identity, model_transform: m4.identity),
];
