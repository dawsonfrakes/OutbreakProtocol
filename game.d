import basic;
import basic.maths;

struct TriangleUniformObject {
  M4 world_transform;
}

struct Renderer {
  V4 clear_color0;
  float clear_depth;

  TriangleUniformObject[1024] triangles;
  uint triangles_count;
}

struct State {
  bool initted;

  float turns = 0.0;
}

extern(C) void update_and_render(ubyte[] memory, Renderer* renderer) {
  assert(memory.length >= State.sizeof);
  State* state = cast(State*) memory.ptr;
  if (!state.initted) {
    scope(exit) state.initted = true;
  }

  renderer.clear_color0 = [0.6, 0.2, 0.2, 1.0];
  renderer.clear_depth = 0.0;

  state.turns += 0.001;

  renderer.triangles[0] = TriangleUniformObject(M4.rotateZ(state.turns));
  renderer.triangles_count = 1;
}
