#define OP_DEBUG 1

#if defined(__x86_64__) || defined(_M_AMD64)
  #define OP_CPU_X64 1
#else
  #define OP_CPU_X64 0
#endif

#if defined(_WIN32) || defined(__WIN32__)
  #define OP_OS_WINDOWS 1
#else
  #define OP_OS_WINDOWS 0
#endif

#define cast(T, V) ((T) (V))

#if OP_CPU_X64
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

template <typename T, usize N> usize len(T (&x)[N]) { (void) x; return N; }
template <typename T, usize N> usize size_of(T (&x)[N]) { (void) x; return sizeof(T) * N; }
