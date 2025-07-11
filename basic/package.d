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

template ParameterType(F, usize N) {
  static if (is(F P == __parameters)) {
    alias ParameterType = P[N];
  } else {
    static assert(0);
  }
}

template ExportIfVersionDLLElseDefine(alias Exports) {
  version (DLL) {
    extern(C) export:
    mixin Exports;
  } else {
    mixin Exports;
  }
}

template COMClass(alias Parent = void) {
  static if (!is(Parent == void)) {
    VTable* vtable;
  } else {
    VTable* vtable;
  }

  auto opDispatch(string op, Ts...)(Ts args) {
    auto self = cast(ParameterType!(typeof(mixin("vtable."~op)), 0)) &this;
    return mixin("vtable."~op)(self, args);
  }
}

struct EnumFlags(alias T) {
  T value;
  alias this = value;

  alias Self = typeof(this);

  static Self opDispatch(string op)() => Self(__traits(getMember, T, op));
  Self opBinary(string op : "|")(string rhs) {
    return Self(value | __traits(getMember, T, rhs));
  }
}
