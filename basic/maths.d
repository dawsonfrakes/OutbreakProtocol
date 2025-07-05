module basic.maths;

auto min(X, Y)(X x, Y y) => x < y ? x : y;
auto max(X, Y)(X x, Y y) => x > y ? x : y;

float[16] transpose(float[16] m) {
  float[16] t;
  foreach (row; 0..4) {
    foreach (col; 0..4) {
      t.ptr[row * 4 + col] = m.ptr[col * 4 + row];
    }
  }
  return t;
}
