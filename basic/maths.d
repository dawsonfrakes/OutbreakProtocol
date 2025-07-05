module basic.maths;

import basic;

auto min(X, Y)(X x, Y y) => x < y ? x : y;
auto max(X, Y)(X x, Y y) => x > y ? x : y;

struct Vector(usize N_, T_) {
  alias N = N_;
  alias T = T_;

  T[N] elements;

  this(T rhs) { elements = rhs; }
  this(R : Vector)(R rhs) { elements = rhs; }
  this(T[N] rhs) { elements = rhs; }
  this(Ts...)(Ts args) if (args.length == N) { T[N] args_ = [cast(T) args]; elements = args_; }
  void opAssign(T rhs) { elements = rhs; }
  void opAssign(T[N] rhs) { elements = rhs; }
  void opOpAssign(string op)(T[N] rhs) if (op == "+" || op == "-" || op == "*" || op == "/") {
    static foreach (i; 0..N)
      mixin("elements[i] "~op~"= rhs[i];");
  }
  void opOpAssign(string op, R : Vector)(R rhs) if (op == "+" || op == "-" || op == "*" || op == "/") {
    static foreach (i; 0..N)
      mixin("elements[i] "~op~"= rhs[i];");
  }

  T* ptr() => elements.ptr;

  auto opCast(NewT)() {
    Vector!(N, NewT) result;
    static foreach (i; 0..N)
      result[i] = cast(NewT) elements[i];
    return result;
  }
  ref T opIndex(Index)(Index index) => elements[index];
  auto opBinary(string op, R)(R rhs) if (op == "+" || op == "-" || op == "*" || op == "/") {
    static if (!__traits(isScalar, R)) {
      alias NewT = typeof(elements[0] + rhs[0]);
      Vector!(N, NewT) result = this.opCast!NewT;
      static foreach (i; 0..N)
        mixin("result[i] "~op~"= rhs[i];");
      return result;
    } else {
      alias NewT = typeof(elements[0] + rhs);
      Vector!(N, NewT) result = this.opCast!NewT;
      static foreach (i; 0..N)
        mixin("result[i] "~op~"= rhs;");
      return result;
    }
  }

  bool any(T value) {
    foreach (ref e; elements)
      if (e == value) return true;
    return false;
  }

  static if (N > 0) ref T x() => elements[0];
  static if (N > 1) ref T y() => elements[1];
  static if (N > 2) ref T z() => elements[2];
  static if (N > 3) ref T w() => elements[3];
  static if (N > 0) ref T r() => elements[0];
  static if (N > 1) ref T g() => elements[1];
  static if (N > 2) ref T b() => elements[2];
  static if (N > 3) ref T a() => elements[3];
  static if (N > 0) ref T s() => elements[0];
  static if (N > 1) ref T t() => elements[1];
  static if (N > 2) ref T u() => elements[2];
  static if (N > 3) ref T v() => elements[3];
}
alias V2 = Vector!(2, f32);
alias V3 = Vector!(3, f32);
alias V4 = Vector!(4, f32);

struct Matrix(usize N_, usize M_, T_) {
  alias N = N_;
  alias M = M_;
  alias T = T_;

  T[N * M] elements;

  static if (N == 4 && M == 4 && is(T == float)) {
    static M4 translate(bool row_major = false)(V3 by) => M4(row_major ? [
      1.0, 0.0, 0.0, 0.0,
      0.0, 1.0, 0.0, 0.0,
      0.0, 0.0, 1.0, 0.0,
      by.x, by.y, by.z, 1.0,
    ] : [
      1.0, 0.0, 0.0, by.x,
      0.0, 1.0, 0.0, by.y,
      0.0, 0.0, 1.0, by.z,
      0.0, 0.0, 0.0, 1.0,
    ]);
  }
}
alias M4 = Matrix!(4, 4, f32);
