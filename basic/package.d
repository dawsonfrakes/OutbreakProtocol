module basic;

alias s8 = byte;
alias s16 = short;
alias s32 = int;
alias s64 = long;
alias ssize = ptrdiff_t;
alias u8 = ubyte;
alias u16 = ushort;
alias u32 = uint;
alias u64 = ulong;
alias usize = size_t;
alias f32 = float;
alias f64 = double;

struct String {
  char[] items;
  this(string x) { items = (cast(char*) x.ptr)[0..x.length]; }
}

struct uda {}

@uda struct foreign {
  string library;
}

template COMClass() {
  VTable* vtable;
  auto opDispatch(string s, Ts...)(Ts args) => mixin("vtable."~s)(&this, args);
}

struct Bounded_Array(usize N_, T_) {
  alias T = T_;
  alias N = N_;

  T[N] buffer;
  usize length;

  T* ptr() => buffer.ptr;
  void opOpAssign(string s : "~")(T rhs) { buffer[length++] = rhs; }
  ref T opIndex(Index)(Index index) => buffer[index];
  int opApply(int delegate(ref T) dg) {
    foreach (i; 0..length) if (dg(buffer.ptr[i])) return 1;
    return 0;
  }
}

extern(C) void* memcpy(void* a, const(void)* b, usize c) {
  u8* a8 = cast(u8*) a, b8 = cast(u8*) b;
  foreach (i; 0..c) a8[i] = b8[i];
  return a;
}

extern(C) ssize strlen(const(char)* s) {
  const(char)* start = s;
  while (*s) s += 1;
  return s - start;
}
