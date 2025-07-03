module basic;

struct uda {}

@uda struct foreign {
  string library;
}

/+
  usage: `struct MyComClass { struct VTable { ... } mixin COMClass; }`
  reason: dmd (2.111.0) crashes when using COM classes with -betterC. Here's the workaround.
+/
template COMClass() {
  VTable* _vtable;
  auto opDispatch(string s, T...)(T args) => mixin("_vtable.", s)(&this, args);
}

extern(C) void* memcpy(void* a, const(void)* b, size_t size) {
  ubyte* a8 = cast(ubyte*) a;
  ubyte* b8 = cast(ubyte*) b;
  foreach (i; 0..size) a8[i] = b8[i];
  return a;
}

extern(C) ptrdiff_t strlen(const(char)* s) {
  const(char)* start = s;
  while (*s) s += 1;
  return s - start;
}
