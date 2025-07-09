import basic;
import basic.macos;

__gshared {
  NSApplication* platform_app;
  NSWindow* platform_window;
}

extern(C) noreturn main() {
  NSApplicationLoad();
  init_objc_classes_and_selectors();

  platform_app = NSApplication.sharedApplication();
  platform_app.setActivationPolicy(NSApplication.ActivationPolicy.REGULAR);

  platform_window = NSWindow.alloc()/*.initWith(
    CGRect(CGPoint(0, 0), CGSize(640, 480)),
    NSWindow.StyleMask.TITLED |
      NSWindow.StyleMask.CLOSABLE |
      NSWindow.StyleMask.RESIZABLE |
      NSWindow.StyleMask.MINIATURIZABLE,
    NSWindow.BackingStore.BUFFERED, false)*/;
  platform_window.makeKeyAndOrderFront(null);

  _exit(0);
}

pragma(linkerDirective, "-framework", "AppKit");
