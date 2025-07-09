import basic;
import basic.maths;
static import game;

__gshared game.Game_Mesh_Vertex[4] mesh_vertices = [
  game.Game_Mesh_Vertex(position: v3(-0.5, -0.5, 0.0), texcoord: v2(0.0, 0.0)),
  game.Game_Mesh_Vertex(position: v3(-0.5, +0.5, 0.0), texcoord: v2(0.0, 1.0)),
  game.Game_Mesh_Vertex(position: v3(+0.5, +0.5, 0.0), texcoord: v2(1.0, 1.0)),
  game.Game_Mesh_Vertex(position: v3(+0.5, -0.5, 0.0), texcoord: v2(1.0, 0.0)),
];
__gshared u16[6] mesh_indices = [0, 1, 2, 2, 3, 0];
