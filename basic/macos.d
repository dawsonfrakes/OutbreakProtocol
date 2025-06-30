module basic.macos;

import basic;

@uda struct selector {
  string selector;
}

enum STDOUT_FILENO = 1;

@foreign("System") extern(C) ptrdiff_t write(int, const(void)*, size_t);
@foreign("System") extern(C) noreturn _exit(uint);

@foreign("objc") extern(C) void objc_msgSend();
@foreign("objc") extern(C) void* objc_getClass(const(char)*);
@foreign("objc") extern(C) void* sel_getUid(const(char)*);

@foreign("AppKit") extern(C) bool NSApplicationLoad();

extern(Objective-C) extern class NSApplication {
  enum ActivationPolicy : int {
    REGULAR = 0,
    ACCESSORY = 1,
    PROHIBITED = 2,
  }

  static NSApplication sharedApplication() @selector("sharedApplication");
  bool setActivationPolicy(ActivationPolicy) @selector("setActivationPolicy:");
}
