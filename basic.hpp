#define OP_DEBUG 1

#if defined(_MSC_VER)
  #define OP_COMPILER_MSVC 1
#else
  #define OP_COMPILER_MSVC 0
#endif

#if defined(__clang__)
  #define OP_COMPILER_CLANG 1
#else
  #define OP_COMPILER_CLANG 0
#endif

#if !OP_COMPILER_CLANG && defined(__GNUC__)
  #define OP_COMPILER_GCC 1
#else
  #define OP_COMPILER_GCC 0
#endif

#if defined(__x86_64__) || defined(_M_AMD64)
  #define OP_CPU_X64 1
#else
  #define OP_CPU_X64 0
#endif

#if defined(__aarch64__) || defined(_M_ARM64)
  #define OP_CPU_ARM64 1
#else
  #define OP_CPU_ARM64 0
#endif

#if defined(_WIN32) || defined(__WIN32__)
  #define OP_OS_WINDOWS 1
#else
  #define OP_OS_WINDOWS 0
#endif

#if defined(__APPLE__) && defined(__MACH__)
  #define OP_OS_MACOS 1
#else
  #define OP_OS_MACOS 0
#endif

#define cast(T, V) ((T) (V))
#define type_of(X) decltype(X)
#define type_of_field(T, F) type_of(declval<T>().F)
#define offset_of(T, F) cast(usize, &(cast(T*, 0))->F)
#define assert(...) platform_assert(__VA_ARGS__, #__VA_ARGS__);

#if OP_COMPILER_MSVC
  #define debug_break() __debugbreak()
#elif OP_COMPILER_CLANG || OP_COMPILER_GCC
  #if OP_CPU_X64
    #define debug_break() __asm__("int3");
  #elif OP_CPU_ARM64
    #define debug_break() __asm__(".inst 0xE7F001F0");
  #endif
#endif

#if OP_CPU_X64 || OP_CPU_ARM64
  typedef signed char s8;
  typedef short s16;
  typedef int s32;
  typedef long long s64;
  typedef long long ssize;

  typedef unsigned char u8;
  typedef unsigned short u16;
  typedef unsigned int u32;
  typedef unsigned long long u64;
  typedef unsigned long long usize;
#endif

typedef float f32;
typedef double f64;

template <typename T, usize N> constexpr static usize len(T (&x)[N]) { (void) x; return N; }
template <typename T, usize N> constexpr static usize size_of(T (&x)[N]) { (void) x; return sizeof(T) * N; }
template <typename T> constexpr static T&& declval();

#if OP_OS_WINDOWS
extern "C" usize strlen(const char*);
#elif OP_OS_MACOS
extern "C" unsigned long strlen(const char*);
#endif

struct string {
  usize count;
  char* data;

  string(usize count, const char* data) : count(count), data(cast(char*, data)) {}
  string(const char* s) : count(strlen(s)), data(cast(char*, s)) {}
  template<usize N> string(const char (&s)[N]) : count(N - 1), data(cast(char*, s)) {}
};

static void platform_assert(bool cond, string message, string _expr, string file = __FILE__, int line = __LINE__);
static void platform_assert(bool cond, string expr, string file = __FILE__, int line = __LINE__);

template<usize N, typename T>
struct Bounded_Array {
  T data[N];
  usize count;
  static constexpr usize capacity = N;

  T& operator[](usize index) { assert(index < N); return data[index]; }
  void operator+=(T rhs) { assert(count < N); data[count++] = rhs; }
};

template <typename T, typename U> auto min(T x, U y) { return x < y ? x : y; }
template <typename T, typename U> auto max(T x, U y) { return x > y ? x : y; }

static constexpr f32 TAU = 6.28318530717958647692f;

static f32 fmod(f32 x, f32 y) {
  assert(y != 0.0f);
  s32 n = cast(s32, x / y);
  return x - n * y;
}

static f32 wrap(f32 turns) {
  turns = fmod(turns, 1.0f);
  if (turns > 0.5f) turns -= 1.0f;
  else if (turns < -0.5f) turns += 1.0f;
  return turns;
}

static f32 sin(f32 turns, s32 terms = 6) {
  f32 x = wrap(turns) * TAU;
  f32 term = x;
  f32 sum = term;
  for (s32 n = 1; n < terms; ++n) {
    term *= -x * x / ((2 * n) * (2 * n + 1));
    sum += term;
  }
  return sum;
}

static f32 cos(f32 turns, s32 terms = 6) {
  f32 x = wrap(turns) * TAU;
  f32 term = 1.0f;
  f32 sum = term;
  for (s32 n = 1; n < terms; ++n) {
    term *= -x * x / ((2 * n - 1) * (2 * n));
    sum += term;
  }
  return sum;
}

static f32 tan(f32 turns, s32 terms = 6) {
  return sin(turns, terms) / cos(turns, terms);
}

struct v2 {
  alignas(16) f32 x;
  f32 y;

  constexpr v2(f32 x = 0.0f) : x(x), y(x) {}
  constexpr v2(f32 x, f32 y) : x(x), y(y) {}
  operator const f32*() const { return &x; }

  v2 operator-() {
    v2 result;
    result.x = -x;
    result.y = -y;
    return result;
  }

  v2 operator+(v2 rhs) {
    v2 result;
    result.x = x + rhs.x;
    result.y = y + rhs.y;
    return result;
  }

  v2 operator-(v2 rhs) {
    v2 result;
    result.x = x - rhs.x;
    result.y = y - rhs.y;
    return result;
  }

  v2 operator*(v2 rhs) {
    v2 result;
    result.x = x * rhs.x;
    result.y = y * rhs.y;
    return result;
  }

  v2 operator/(v2 rhs) {
    v2 result;
    result.x = x / rhs.x;
    result.y = y / rhs.y;
    return result;
  }
};

static v2 operator/(f32 lhs, v2 rhs) {
  v2 result;
  result.x = lhs / rhs.x;
  result.y = lhs / rhs.y;
  return result;
}

struct v3 {
  alignas(16) f32 x;
  f32 y;
  f32 z;

  constexpr v3(f32 x = 0.0f) : x(x), y(x), z(x) {}
  constexpr v3(f32 x, f32 y, f32 z) : x(x), y(y), z(z) {}
  constexpr v3(v2 xy, f32 z = 0.0f) : x(xy.x), y(xy.y), z(z) {}
  operator const f32*() const { return &x; }

  v3 operator-() {
    v3 result;
    result.x = -x;
    result.y = -y;
    result.z = -z;
    return result;
  }

  v3 operator+(v3 rhs) {
    v3 result;
    result.x = x + rhs.x;
    result.y = y + rhs.y;
    result.z = z + rhs.z;
    return result;
  }

  v3 operator-(v3 rhs) {
    v3 result;
    result.x = x - rhs.x;
    result.y = y - rhs.y;
    result.z = z - rhs.z;
    return result;
  }

  v3 operator*(v3 rhs) {
    v3 result;
    result.x = x * rhs.x;
    result.y = y * rhs.y;
    result.z = z * rhs.z;
    return result;
  }

  v3 operator/(v3 rhs) {
    v3 result;
    result.x = x / rhs.x;
    result.y = y / rhs.y;
    result.z = z / rhs.z;
    return result;
  }
};

// static v3 operator/(f32 lhs, v3 rhs) {
//   v3 result;
//   result.x = lhs / rhs.x;
//   result.y = lhs / rhs.y;
//   result.z = lhs / rhs.z;
//   return result;
// }

struct v4 {
  alignas(16) f32 x;
  f32 y;
  f32 z;
  f32 w;

  constexpr v4(f32 x = 0.0f) : x(x), y(x), z(x), w(x) {}
  constexpr v4(f32 x, f32 y, f32 z, f32 w) : x(x), y(y), z(z), w(w) {}
  operator const f32*() const { return &x; }
};

struct q4 {
  alignas(16) f32 w;
  f32 x;
  f32 y;
  f32 z;

  operator const f32*() const { return &w; }
};

static q4 q4_from_euler(v3 euler) {
  f32 cy = cos(euler.y * 0.5f);
  f32 sy = sin(euler.y * 0.5f);
  f32 cp = cos(euler.x * 0.5f);
  f32 sp = sin(euler.x * 0.5f);
  f32 cr = cos(euler.z * 0.5f);
  f32 sr = sin(euler.z * 0.5f);

  q4 q;
  q.w = cy * cp * cr + sy * sp * sr;
  q.x = cy * sp * cr + sy * cp * sr;
  q.y = sy * cp * cr - cy * sp * sr;
  q.z = cy * cp * sr - sy * sp * cr;
  return q;
}

struct x2 {
  v3 position;
  f32 rotation;
  v2 scale = 1.0f;
};

struct x3 {
  v3 position;
  q4 rotation;
  v3 scale = 1.0f;
};

struct m4 {
  alignas(16) f32 elements[16] = {};

  m4 operator*(m4 b) {
    m4 result = {};
    for (s32 i = 0; i < 4; i += 1)
    for (s32 j = 0; j < 4; j += 1)
    for (s32 k = 0; k < 4; k += 1)
      result.elements[i * 4 + j] += b.elements[i * 4 + k] * elements[k * 4 + j];
    return result;
  }
};

template<bool row_major = false>
static m4 m4_translate(v3 by) {
  if (row_major) {
    return m4{{
      1.0f, 0.0f, 0.0f, 0.0f,
      0.0f, 1.0f, 0.0f, 0.0f,
      0.0f, 0.0f, 1.0f, 0.0f,
      by.x, by.y, by.z, 1.0f,
    }};
  } else {
    return m4{{
      1.0f, 0.0f, 0.0f, by.x,
      0.0f, 1.0f, 0.0f, by.y,
      0.0f, 0.0f, 1.0f, by.z,
      0.0f, 0.0f, 0.0f, 1.0f,
    }};
  }
}

template<bool row_major = false>
static m4 m4_rotate_z(f32 turns) {
  f32 c = cos(turns);
  f32 s = sin(turns);
  if (row_major) {
    return m4{{
      +c,     +s, 0.0f, 0.0f,
      -s,     +c, 0.0f, 0.0f,
      0.0f, 0.0f, 1.0f, 0.0f,
      0.0f, 0.0f, 0.0f, 1.0f,
    }};
  } else {
    return m4{{
      +c,     -s, 0.0f, 0.0f,
      +s,     +c, 0.0f, 0.0f,
      0.0f, 0.0f, 1.0f, 0.0f,
      0.0f, 0.0f, 0.0f, 1.0f,
    }};
  }
}

static m4 m4_scale(v3 by) {
  return m4{{
    by.x, 0.0f, 0.0f, 0.0f,
    0.0f, by.y, 0.0f, 0.0f,
    0.0f, 0.0f, by.z, 0.0f,
    0.0f, 0.0f, 0.0f, 1.0f,
  }};
}

template<bool row_major = false>
static m4 m4_perspective(f32 fov_y, f32 aspect_ratio, f32 z_near, f32 z_far) {
  f32 f = 1.0f / tan(fov_y * 0.5f);
  f32 a = f / aspect_ratio;
  f32 b = f;
  f32 c = z_far / (z_far - z_near);
  f32 d = -(z_far * z_near) / (z_far - z_near);
  if (row_major) {
    return m4{{
      a, 0.0f, 0.0f, 0.0f,
      0.0f, b, 0.0f, 0.0f,
      0.0f, 0.0f, c, 1.0f,
      0.0f, 0.0f, d, 0.0f,
    }};
  } else {
    return m4{{
      a, 0.0f, 0.0f, 0.0f,
      0.0f, b, 0.0f, 0.0f,
      0.0f, 0.0f, c, d,
      0.0f, 0.0f, 1.0f, 0.0f,
    }};
  }
}

template<bool row_major = false>
static m4 m4_from_q4(q4 q) {
  f32 xx = q.x * q.x;
  f32 yy = q.y * q.y;
  f32 zz = q.z * q.z;
  f32 xy = q.x * q.y;
  f32 xz = q.x * q.z;
  f32 yz = q.y * q.z;
  f32 wx = q.w * q.x;
  f32 wy = q.w * q.y;
  f32 wz = q.w * q.z;

  if (row_major) {
    return m4{{
      1.0f - 2.0f * (yy + zz), 2.0f * (xy - wz),        2.0f * (xz + wy),        0.0f,
      2.0f * (xy + wz),        1.0f - 2.0f * (xx + zz), 2.0f * (yz - wx),        0.0f,
      2.0f * (xz - wy),        2.0f * (yz + wx),        1.0f - 2.0f * (xx + yy), 0.0f,
      0.0f,                    0.0f,                    0.0f,                    1.0f,
    }};
  } else {
    return m4{{
      1.0f - 2.0f * (yy + zz), 2.0f * (xy + wz),        2.0f * (xz - wy),        0.0f,
      2.0f * (xy - wz),        1.0f - 2.0f * (xx + zz), 2.0f * (yz + wx),        0.0f,
      2.0f * (xz + wy),        2.0f * (yz - wx),        1.0f - 2.0f * (xx + yy), 0.0f,
      0.0f,                    0.0f,                    0.0f,                    1.0f,
    }};
  }
}
