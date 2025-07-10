noreturn :: void;
ssize :: s64;
usize :: u64;

Arena :: struct {
  base: *void;
  used: usize;
  capacity: usize;
}
