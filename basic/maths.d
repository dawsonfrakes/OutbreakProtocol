module basic.maths;

import basic;

auto min(X, Y)(X x, Y y) => x < y ? x : y;
auto max(X, Y)(X x, Y y) => x > y ? x : y;

struct Vector(usize N_, T_) {
  alias N = N_;
  alias T = T_;

  T[N] elements;

  this(T rhs) { elements = rhs; }
  // this(T[N] rhs) { elements = rhs; }
  this(Ts...)(Ts args) { elements = [args]; }

  T* ptr() => elements.ptr;

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
