import basic;

struct PlatformRenderer {
  struct Init {
    version (Windows) {
      import basic.windows : HWND, HDC;
      HWND hwnd;
      HDC hdc;
    }
  }
  struct Resize {
    u16 width;
    u16 height;
  }

  const(char)[] pretty_name;
  void function(Init) init_;
  void function() deinit;
  void function(Resize) resize;
  void function() present;
}

__gshared immutable null_renderer = PlatformRenderer(
  "None",
  (init_data) {},
  {},
  (resize_data) {},
  {},
);
