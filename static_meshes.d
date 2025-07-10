import basic;
import basic.maths;
static import game;

__gshared game.Game_Mesh_Vertex[24] mesh_vertices = [
  // +Z (Front face)
  game.Game_Mesh_Vertex(position: v3(-0.5, -0.5, +0.5), normal: v3(0, 0, 1), texcoord: v2(0, 0)),
  game.Game_Mesh_Vertex(position: v3(-0.5, +0.5, +0.5), normal: v3(0, 0, 1), texcoord: v2(0, 1)),
  game.Game_Mesh_Vertex(position: v3(+0.5, +0.5, +0.5), normal: v3(0, 0, 1), texcoord: v2(1, 1)),
  game.Game_Mesh_Vertex(position: v3(+0.5, -0.5, +0.5), normal: v3(0, 0, 1), texcoord: v2(1, 0)),

  // -Z (Back face)
  game.Game_Mesh_Vertex(position: v3(+0.5, -0.5, -0.5), normal: v3(0, 0, -1), texcoord: v2(0, 0)),
  game.Game_Mesh_Vertex(position: v3(+0.5, +0.5, -0.5), normal: v3(0, 0, -1), texcoord: v2(0, 1)),
  game.Game_Mesh_Vertex(position: v3(-0.5, +0.5, -0.5), normal: v3(0, 0, -1), texcoord: v2(1, 1)),
  game.Game_Mesh_Vertex(position: v3(-0.5, -0.5, -0.5), normal: v3(0, 0, -1), texcoord: v2(1, 0)),

  // +X (Right face)
  game.Game_Mesh_Vertex(position: v3(+0.5, -0.5, +0.5), normal: v3(1, 0, 0), texcoord: v2(0, 0)),
  game.Game_Mesh_Vertex(position: v3(+0.5, +0.5, +0.5), normal: v3(1, 0, 0), texcoord: v2(0, 1)),
  game.Game_Mesh_Vertex(position: v3(+0.5, +0.5, -0.5), normal: v3(1, 0, 0), texcoord: v2(1, 1)),
  game.Game_Mesh_Vertex(position: v3(+0.5, -0.5, -0.5), normal: v3(1, 0, 0), texcoord: v2(1, 0)),

  // -X (Left face)
  game.Game_Mesh_Vertex(position: v3(-0.5, -0.5, -0.5), normal: v3(-1, 0, 0), texcoord: v2(0, 0)),
  game.Game_Mesh_Vertex(position: v3(-0.5, +0.5, -0.5), normal: v3(-1, 0, 0), texcoord: v2(0, 1)),
  game.Game_Mesh_Vertex(position: v3(-0.5, +0.5, +0.5), normal: v3(-1, 0, 0), texcoord: v2(1, 1)),
  game.Game_Mesh_Vertex(position: v3(-0.5, -0.5, +0.5), normal: v3(-1, 0, 0), texcoord: v2(1, 0)),

  // +Y (Top face)
  game.Game_Mesh_Vertex(position: v3(-0.5, +0.5, +0.5), normal: v3(0, 1, 0), texcoord: v2(0, 0)),
  game.Game_Mesh_Vertex(position: v3(-0.5, +0.5, -0.5), normal: v3(0, 1, 0), texcoord: v2(0, 1)),
  game.Game_Mesh_Vertex(position: v3(+0.5, +0.5, -0.5), normal: v3(0, 1, 0), texcoord: v2(1, 1)),
  game.Game_Mesh_Vertex(position: v3(+0.5, +0.5, +0.5), normal: v3(0, 1, 0), texcoord: v2(1, 0)),

  // -Y (Bottom face)
  game.Game_Mesh_Vertex(position: v3(-0.5, -0.5, -0.5), normal: v3(0, -1, 0), texcoord: v2(0, 0)),
  game.Game_Mesh_Vertex(position: v3(-0.5, -0.5, +0.5), normal: v3(0, -1, 0), texcoord: v2(0, 1)),
  game.Game_Mesh_Vertex(position: v3(+0.5, -0.5, +0.5), normal: v3(0, -1, 0), texcoord: v2(1, 1)),
  game.Game_Mesh_Vertex(position: v3(+0.5, -0.5, -0.5), normal: v3(0, -1, 0), texcoord: v2(1, 0)),
];

__gshared u16[36] mesh_indices = [
  // Front
  0, 1, 2, 2, 3, 0,
  // Back
  4, 5, 6, 6, 7, 4,
  // Right
  8, 9,10,10,11, 8,
  // Left
 12,13,14,14,15,12,
  // Top
 16,17,18,18,19,16,
  // Bottom
 20,21,22,22,23,20
];
