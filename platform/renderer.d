struct PlatformRenderer {
  const(char)[] pretty_name;
  void function() init_;
  void function() deinit;
  void function() resize;
  void function() present;
}

__gshared immutable null_renderer = PlatformRenderer(
  "None",
  {},
  {},
  {},
  {},
);
