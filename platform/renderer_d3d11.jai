d3d11_init :: () #no_context {

}

d3d11_deinit :: () #no_context {

}

d3d11_resize :: () #no_context {

}

d3d11_present :: () #no_context {

}

d3d11_renderer := PlatformRenderer.{
  "Direct3D 11",
  d3d11_init,
  d3d11_deinit,
  d3d11_resize,
  d3d11_present,
};
