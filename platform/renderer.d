import basic;

struct PlatformRenderer {
  const(char)[] pretty_name;
  void function() init;
  void function() deinit;
  void function() resize;
  void function() present;
}
