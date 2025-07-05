import basic;
import basic.maths;

struct Transform {
  align(16) V3 position = 0.0;
  align(16) V4 rotation = 0.0;
  align(16) V3 scale = 1.0;
}

struct Triangle_Instance {
  Transform world_transform;
}

struct Renderer {
  V4 clear_color0;
  f32 clear_depth;
  Bounded_Array!(1024, Triangle_Instance) triangle_instances;
}

extern(C) void game_update_and_render(Renderer* renderer) {
  renderer.clear_color0 = V4(0.6, 0.2, 0.2, 1.0);
  renderer.clear_depth = 0.0;

  renderer.triangle_instances ~= Triangle_Instance(Transform(V3(+0.5, 0, 0)));
  renderer.triangle_instances ~= Triangle_Instance(Transform(V3(-0.5, 0, 0)));
}
