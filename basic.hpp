#define OP_DEBUG 1

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

#define cast(T, V) ((T) (V))
#define offset_of(T, F) cast(usize, &(cast(T*, 0))->F)

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

template <typename T, usize N> inline usize len(T (&x)[N]) { (void) x; return N; }
template <typename T, usize N> inline usize size_of(T (&x)[N]) { (void) x; return sizeof(T) * N; }

template <typename T, typename U> inline auto min(T x, U y) { return x < y ? x : y; }
template <typename T, typename U> inline auto max(T x, U y) { return x > y ? x : y; }

extern "C" usize strlen(const char*);

struct string {
  usize count;
  char* data;

  string(usize count, const char* data) : count(count), data(cast(char*, data)) {}
  string(const char* s) : count(strlen(s)), data(cast(char*, s)) {}
  template<usize N> string(const char (&s)[N]) : count(N - 1), data(cast(char*, s)) {}
};

struct v2 {
  alignas(16) f32 x;
  f32 y;

  operator const f32*() const { return &x; }
};

struct v3 {
  alignas(16) f32 x;
  f32 y;
  f32 z;

  operator const f32*() const { return &x; }
};

struct v4 {
  alignas(16) f32 x;
  f32 y;
  f32 z;
  f32 w;

  operator const f32*() const { return &x; }
};
