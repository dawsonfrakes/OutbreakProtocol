module basic.maths;

import basic;

enum TAU = 6.28318530717958647692f;

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

f32 wrap(f32 turns) {
  turns %= 1.0f;
  if (turns > 0.5f) turns -= 1.0f;
  else if (turns < -0.5f) turns += 1.0f;
  return turns;
}

f32 sint(s32 terms = 6)(f32 turns) {
  f32 x = wrap(turns) * TAU;
  f32 term = x;
  f32 sum = term;
  for (s32 n = 1; n < terms; n += 1) {
    term *= -x * x / ((2 * n) * (2 * n + 1));
    sum += term;
  }
  return sum;
}

f32 cost(s32 terms = 6)(f32 turns) {
  f32 x = wrap(turns) * TAU;
  f32 term = 1.0f;
  f32 sum = term;
  for (s32 n = 1; n < terms; n += 1) {
    term *= -x * x / ((2 * n - 1) * (2 * n));
    sum += term;
  }
  return sum;
}

f32 tant(s32 terms = 6)(f32 turns) {
  return sint!terms(turns) / cost!terms(turns);
}

f32 sqrt(s32 iterations = 4)(f32 x) {
  if (x == 0.0) return 0.0;
  f32 guess = x;
  for (s32 i = 0; i < iterations; i += 1)
    guess = 0.5 * (guess + x / guess);
  return guess;
}

struct Vector(usize N_, T_) {
  T_[N_] elements;

  alias N = N_;
  alias T = T_;
  alias Self = Vector!(N, T);

  this(T arg) { elements = arg; }
  this(Ts...)(Ts args) { elements = [args]; }

  static if (N > 0) ref T x() => elements[0];
  static if (N > 1) ref T y() => elements[1];
  static if (N > 2) ref T z() => elements[2];
  static if (N > 3) ref T w() => elements[3];

  Self opUnary(string op : "-")() {
    Self result;
    static foreach (i; 0..N)
      result.elements[i] = -elements[i];
    return result;
  }
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

  this(T arg) { elements = arg; }
  this(Ts...)(Ts args) { elements = [args]; }

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

  static if (Rows == 4 && Cols == 4 && is(T == f32)) {
    static m4 translate(bool col_major = false)(v3 by) {
      static if (col_major) {
        return m4(
          1.0, 0.0, 0.0, 0.0,
          0.0, 1.0, 0.0, 0.0,
          0.0, 0.0, 1.0, 0.0,
          by.x, by.y, by.z, 1.0,
        );
      } else {
        return m4(
          1.0, 0.0, 0.0, by.x,
          0.0, 1.0, 0.0, by.y,
          0.0, 0.0, 1.0, by.z,
          0.0, 0.0, 0.0, 1.0,
        );
      }
    }

    static m4 rotate_x(bool col_major = false)(f32 turns) {
      f32 s = sint(turns);
      f32 c = cost(turns);
      static if (col_major) {
        return m4(
          1.0, 0.0, 0.0, 0.0,
          0.0, c, s, 0.0,
          0.0, -s, c, 0.0,
          0.0, 0.0, 0.0, 1.0,
        );
      } else {
        return m4(
          1.0, 0.0, 0.0, 0.0,
          0.0, c, -s, 0.0,
          0.0, s, c, 0.0,
          0.0, 0.0, 0.0, 1.0,
        );
      }
    }
  }
}
alias m4 = Matrix!(4, 4, f32);
