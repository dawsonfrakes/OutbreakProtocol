Platform_Renderer :: struct {
  pretty_name: string;
  init: () #no_context;
  deinit: () #no_context;
  resize: () #no_context;
  present: () #no_context;
}

null_renderer := Platform_Renderer.{
  "NULL",
  () #no_context {},
  () #no_context {},
  () #no_context {},
  () #no_context {},
};
