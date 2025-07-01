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
