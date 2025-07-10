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

template ReturnType(F) {
  static if (is(F R == return)) {
    alias ReturnType = R;
  } else {
    static assert(0);
  }
}

template ParameterTypes(F) {
  static if (is(F P == function)) {
    alias ParameterTypes = P;
  } else {
    static assert(0);
  }
}

template DefineOrExportIfDLL(string code) {
  version (DLL) {
    extern(C) export:
    mixin(code);
  } else {
    mixin(code);
  }
}
