PlatformRenderer :: struct {
  Init :: struct {
    #if OS == .WINDOWS {
      hwnd: HWND;
      hdc: HDC;
    }
    width: u16;
    height: u16;
  }
  Resize :: struct {
    width: u16;
    height: u16;
  }
  Present :: struct {
    // NOTE(dfra): the renderer could just cache width/height from the latest resize but we resend for simplicity.
    width: u16;
    height: u16;
    renderer: *game.Renderer;
  }

  pretty_name: string;
  init: (Init) #no_context;
  deinit: () #no_context;
  resize: (Resize) #no_context;
  present: (Present) #no_context;
}
