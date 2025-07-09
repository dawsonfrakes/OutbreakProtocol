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

struct uda {}

@uda struct foreign {
  string library;
}

template COMClass() {
  VTable* vtable;
  auto opDispatch(string s, Ts...)(Ts args) => mixin("vtable.", s)(&this, args);
}

template ReturnType(F) {
  static if (is(F R == return))
    alias ReturnType = R;
  else static assert(false);
}

template Parameters(F) {
  static if (is(F P == function))
    alias Parameters = P;
  else static assert(false);
}

template DLLExport(alias data) {
  static if (is(typeof(data) == function))
    mixin("extern(C) export ReturnType!(typeof(data)) "~__traits(identifier, data)~"_"~Parameters!(typeof(data)).stringof~" { return "~__traits(identifier, data)~"(__traits(parameters)); }");
  else {
    mixin("extern(C) export auto "~__traits(identifier, data)~"_ = "~__traits(identifier, data)~";");
  }
}

struct Bounded_Array(usize N_, T_) {
  T_[N_] buffer;
  usize length;

  alias N = N_;
  alias T = T_;

  T_* ptr() => buffer.ptr;
  T_[] opSlice() => buffer.ptr[0..length];

  void opOpAssign(string op : "~")(T rhs) {
    assert(length < buffer.length);
    buffer.ptr[length++] = rhs;
  }
}

auto min(Ts...)(Ts args) {
  auto smallest = args[0];
  static foreach (arg; args[1..$]) smallest = smallest < arg ? smallest : arg;
  return smallest;
}

auto max(Ts...)(Ts args) {
  auto largest = args[0];
  static foreach (arg; args[1..$]) largest = largest > arg ? largest : arg;
  return largest;
}

version (D_BetterC) {
  extern(C) f32* _memsetFloat(f32* p, f32 value, usize count) {
    f32* pstart = p;
    for (f32* ptop = &p[count]; p < ptop; p += 1) *p = value;
    return pstart;
  }

  extern(C) usize strlen(const(char)* s) {
    const(char)* start = s;
    while (*s) s += 1;
    return cast(usize) (start - s);
  }
}
