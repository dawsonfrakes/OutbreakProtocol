noreturn :: void;
f32 :: float32;
f64 :: float64;

#if CPU == .X64 || CPU == .ARM64 {
  ssize :: s64;
  usize :: u64;
}
