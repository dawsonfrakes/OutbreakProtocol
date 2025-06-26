#if defined(__wasm32__)
#define OP_CPU_WASM32 1
#else
#define OP_CPU_WASM32 0
#endif

typedef unsigned int USize;
#define size_of(T) sizeof(T)
#define cast(T, V) ((T) (V))

struct String {
  USize count;
  char *data;

  String(USize count, char const *data) : count(count), data(cast(char *, data)) {}
  template<USize N> String(char const (&x)[N]) : count(N - 1), data(cast(char *, x)) {}
};

#if OP_CPU_WASM32
__attribute__((import_name("console_log"))) void console_log(USize count, char const *data);

extern "C" void _start() {
  auto hw = String("Hello, world!");
  console_log(hw.count, hw.data);
}
#endif
