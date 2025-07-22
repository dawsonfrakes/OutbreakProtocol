#if !defined(OP_DEBUG)
  #error OP_DEBUG must be defined
#endif

#if defined(__x86_64__) || defined(_M_X64)
  #define OP_CPU_X64 1
#else
  #define OP_CPU_X64 0
#endif

#if defined(__aarch64__) || defined(_M_ARM64)
  #define OP_CPU_ARM64 1
#else
  #define OP_CPU_ARM64 0
#endif

#define null nullptr
#define cast(T, V) ((T) (V))
#define size_of(T) sizeof(T)
#define offset_of(T, F) cast(u64, &cast(T*, 0)->F)
#define type_of(X) decltype(X)

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
#else
  #error sized types not defined
#endif
