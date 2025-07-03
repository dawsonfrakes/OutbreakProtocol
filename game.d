import basic;
import basic.maths;

struct Renderer {
  V4 clear_color0;
  float clear_depth;
}

struct State {
  bool initted;
}

extern(C) void update_and_render(ubyte[] memory, Renderer* renderer) {
  assert(memory.length >= State.sizeof);
  State* state = cast(State*) memory.ptr;
  if (!state.initted) {
    scope(exit) state.initted = true;
  }

  renderer.clear_color0 = [0.6, 0.2, 0.2, 1.0];
  renderer.clear_depth = 0.0;
}
