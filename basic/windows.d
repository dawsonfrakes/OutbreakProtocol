module basic.windows;

import basic;

@foreign("Kernel32") extern(Windows) {
  noreturn ExitProcess(u32);
}
