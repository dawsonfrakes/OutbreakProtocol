module basic;

alias s8 = byte;
alias s16 = short;
alias s32 = int;
alias ssize = ptrdiff_t;
alias u8 = ubyte;
alias u16 = ushort;
alias u32 = uint;
alias usize = size_t;

struct f32 {
  float data = 0.0;
  alias this = data;
}

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
