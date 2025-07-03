module basic.maths;

enum PI = 3.14159265358979323846;
enum TAU = 2.0 * PI;

auto min(A, B)(A a, B b) => a < b ? a : b;
auto max(A, B)(A a, B b) => a > b ? a : b;

// TODO(dfra): Implement these ourselves instead of using ChatGPT LOL
float wrap(float turns) {
  turns %= 1.0f;
  if (turns > 0.5f) turns -= 1.0f;
  else if (turns < -0.5f) turns += 1.0f;
  return turns;
}

float sin(float turns, int terms = 6) {
  float x = wrap(turns) * TAU;
  float term = x;
  float sum = term;
  foreach (n; 1..terms) {
    term *= -x * x / ((2 * n) * (2 * n + 1));
    sum += term;
  }
  return sum;
}

float cos(float turns, int terms = 6) {
  float x = wrap(turns) * TAU;
  float term = 1.0f;
  float sum = term;
  foreach (n; 1..terms) {
    term *= -x * x / ((2 * n - 1) * (2 * n));
    sum += term;
  }
  return sum;
}

struct Vector(size_t N, T) {
  T[N] elements = 0;
  alias this = elements;
  this(Ts...)(Ts args) if (args.length == N) { elements = [args]; }
  static if (N >= 1) T x() => elements[0];
  static if (N >= 2) T y() => elements[1];
  static if (N >= 3) T z() => elements[2];
  static if (N >= 4) T w() => elements[3];
  static if (N >= 1) T s() => elements[0];
  static if (N >= 2) T t() => elements[1];
  static if (N >= 3) T u() => elements[2];
  static if (N >= 4) T v() => elements[3];
  static if (N >= 1) T r() => elements[0];
  static if (N >= 2) T g() => elements[1];
  static if (N >= 3) T b() => elements[2];
  static if (N >= 4) T a() => elements[3];
}
alias V3 = Vector!(3, float);
alias V4 = Vector!(4, float);
struct Matrix(size_t N_, size_t M_, T_) {
  alias N = N_;
  alias M = M_;
  alias T = T_;
  T[N * M] elements = 0;
  alias this = elements;

  auto opBinary(string s : "*", R)(R rhs) if (is(R : Matrix) && N == R.M) {
    Matrix!(N, R.M, T) result;
    for (size_t i = 0; i < N; i += 1)
      for (size_t j = 0; j < R.M; j += 1)
        for (size_t k = 0; k < M; k += 1)
          result.ptr[i * R.M + j] += elements.ptr[i * M + k] * rhs.ptr[k * R.M + j];
    return result;
  }

  static auto identity() {
    Matrix!(N, M, T) result;
    for (size_t i = 0; i < min(N, M); i += 1)
      result.ptr[i * N + i] = 1.0;
    return result;
  }

  static if (N == 4 && M == 4 && is(T == float)) {
    static M4 translate(V3 by) {
      return M4([
        1.0, 0.0, 0.0, by.x,
        0.0, 1.0, 0.0, by.y,
        0.0, 0.0, 1.0, by.z,
        0.0, 0.0, 0.0, 1.0,
      ]);
    }
    static M4 rotateX(float turns) {
      const float c = cos(turns);
      const float s = sin(turns);
      return M4([
        1.0, 0.0, 0.0, 0.0,
        0.0, +c, -s, 0.0,
        0.0, +s, +c, 0.0,
        0.0, 0.0, 0.0, 1.0,
      ]);
    }
    static M4 rotateY(float turns) {
      const float c = cos(turns);
      const float s = sin(turns);
      return M4([
        +c, 0.0, +s, 0.0,
        0.0, 1.0, 0.0, 0.0,
        -s, 0.0, +c, 0.0,
        0.0, 0.0, 0.0, 1.0,
      ]);
    }
    static M4 rotateZ(float turns) {
      const float c = cos(turns);
      const float s = sin(turns);
      return M4([
        +c, -s, 0.0, 0.0,
        +s, +c, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 1.0,
      ]);
    }
    static M4 scale(V3 by) {
      return M4([
        by.x, 0.0, 0.0, 0.0,
        0.0, by.y, 0.0, 0.0,
        0.0, 0.0, by.z, 0.0,
        0.0, 0.0, 0.0, 1.0,
      ]);
    }
  }
}
alias M3 = Matrix!(3, 3, float);
alias M4 = Matrix!(4, 4, float);
