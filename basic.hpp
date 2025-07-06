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

template <typename T, usize N> static usize len(T (&x)[N]) { (void) x; return N; }
template <typename T, usize N> static usize size_of(T (&x)[N]) { (void) x; return sizeof(T) * N; }
template <typename T> static T&& declval();

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

struct v2 {
  alignas(16) f32 x;
  f32 y;

  constexpr v2(f32 x = 0.0f) : x(x), y(x) {}
  constexpr v2(f32 x, f32 y) : x(x), y(y) {}
  operator const f32*() const { return &x; }
};

struct v3 {
  alignas(16) f32 x;
  f32 y;
  f32 z;

  constexpr v3(f32 x = 0.0f) : x(x), y(x), z(x) {}
  constexpr v3(f32 x, f32 y, f32 z) : x(x), y(y), z(z) {}
  operator const f32*() const { return &x; }
};

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

struct x2 {
  v3 position;
  v2 scale = 1.0f;
  f32 rotation;
};

struct x3 {
  v3 position;
  q4 rotation;
  v4 scale = 1.0f;
};

struct m4 {
  alignas(16) f32 elements[16];
};

template<bool row_major = false>
static inline m4 m4_translate(v3 by) {
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
