module basic.maths;

import basic;

struct Vector(usize N_, T_) {
  T_[N_] elements;

  alias N = N_;
  alias T = T_;
  alias Self = Vector!(N, T);

  this(Ts...)(Ts args) { elements = [args]; }

  static if (N > 0) ref T x() => elements[0];
  static if (N > 1) ref T y() => elements[1];
  static if (N > 2) ref T z() => elements[2];
  static if (N > 3) ref T w() => elements[3];
}
alias v2 = Vector!(2, f32);
alias v3 = Vector!(3, f32);
alias v4 = Vector!(4, f32);

struct Matrix(usize Rows_, usize Cols_, T_) {
  T_[Rows_ * Cols_] elements;

  alias Rows = Rows_;
  alias Cols = Cols_;
  alias T = T_;
  alias Self = Matrix!(Rows, Cols, T);

  static Self identity() {
    static assert(Rows == Cols);
    auto result = Self(0);
    static foreach (i; 0..Rows)
      result.elements[i * Rows + i] = 1;
    return result;
  }

  auto opBinary(string op : "*", R)(R rhs) if (Cols == rhs.Rows) {
    auto result = Matrix!(Rows, rhs.Cols, T)(0);
    static foreach (i; 0..Rows)
    static foreach (j; 0..rhs.Cols)
    static foreach (k; 0..Cols)
      result.elements[i * result.Cols + j] +=
        elements[i * Cols + k] * rhs.elements[k * rhs.Cols + j];
    return result;
  }
}
alias m4 = Matrix!(4, 4, f32);
