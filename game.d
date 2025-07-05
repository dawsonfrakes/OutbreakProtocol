import basic;
import basic.maths;

struct Transform {
  align(16) V3 position = 0.0;
  align(16) V4 rotation = 0.0;
  align(16) V3 scale = 1.0;
}

struct Quad_Instance {
  Transform transform;
}

struct Quad_Vertex {
  align(16) V3 position;
  align(16) V4 color;
}

__gshared immutable quad_vertices = [
  Quad_Vertex(V3(+0.5, -0.5, 0.0), V4(1.0, 0.0, 0.0, 1.0)),
  Quad_Vertex(V3(-0.5, -0.5, 0.0), V4(0.0, 1.0, 0.0, 1.0)),
  Quad_Vertex(V3(-0.5, +0.5, 0.0), V4(0.0, 0.0, 1.0, 1.0)),
  Quad_Vertex(V3(+0.5, +0.5, 0.0), V4(1.0, 0.0, 1.0, 1.0)),
];
__gshared immutable u16[6] quad_elements = [0, 1, 2, 2, 3, 0];

struct Input {
  Vector!(2, u16) resolution;
  Vector!(2, u16) mouse;
  Vector!(2, s32) mouse_delta;
}

struct Renderer {
  V4 clear_color0;
  f32 clear_depth;
  Bounded_Array!(1024, Quad_Instance) quads;
}

__gshared Vector!(2, s32) g_mouse_position;

extern(C) void game_update_and_render(Input* input, Renderer* renderer) {
  renderer.clear_color0 = V4(0.6, 0.2, 0.2, 1.0);
  renderer.clear_depth = 0.0;

  g_mouse_position += input.mouse_delta;

  if (!input.resolution.any(0)) {
    V2 mouse = (g_mouse_position + 0.5f) / input.resolution;
    renderer.quads ~= Quad_Instance(Transform(V3((mouse.x - 0.5) * 2.0, (mouse.y - 0.5) * 2.0, 0.0)));
  }

  renderer.quads ~= Quad_Instance(Transform(V3(+0.5, 0, 0)));
  renderer.quads ~= Quad_Instance(Transform(V3(-0.5, 0, 0)));
}
