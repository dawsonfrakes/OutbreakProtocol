#import "Basic2";

Renderer :: struct {
  clear_color0: [4]f32;
}

update_and_render :: (renderer: *Renderer) #no_context {
  renderer.clear_color0 = .[0.6, 0.2, 0.2, 1.0];
}
