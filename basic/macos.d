module basic.macos;

import basic;

// libSystem
@foreign("libSystem") extern(C) {
  noreturn _exit(int);
}

// libobjc
struct objc_class; alias objc_Class = objc_class*;
struct objc_selector; alias objc_SEL = objc_selector*;

@foreign("libobjc") extern(C) {
  void objc_msgSend();
  objc_Class objc_getClass(const(char)*);
  objc_SEL sel_getUid(const(char)*);
}

// AppKit
@foreign("AppKit") extern(C) {
  bool NSApplicationLoad();
}

struct NSApplication {
  enum ActivationPolicy : s32 {
    REGULAR = 0,
    ACCESSORY = 1,
    PROHIBITED = 2,
  }

  static NSApplication* sharedApplication() {
    alias F = extern(C) NSApplication* function(objc_Class, objc_SEL);
    return (cast(F) &objc_msgSend)(_objc_classes.NSApplication, _objc_selectors.sharedApplication);
  }
  bool setActivationPolicy(ActivationPolicy policy) {
    alias F = extern(C) bool function(NSApplication*, objc_SEL, ActivationPolicy);
    return (cast(F) &objc_msgSend)(&this, _objc_selectors.setActivationPolicy_, policy);
  }
}
struct NSWindow {
  static NSWindow* alloc() {
    alias F = extern(C) NSWindow* function(objc_Class, objc_SEL);
    return (cast(F) &objc_msgSend)(_objc_classes.NSWindow, _objc_selectors.alloc);
  }
  void makeKeyAndOrderFront(void* sender) {
    alias F = extern(C) void function(NSWindow*, objc_SEL, void*);
    (cast(F) &objc_msgSend)(&this, _objc_selectors.initWithContentRect_styleMask_backing_defer_, sender);
  }
}

// internal stuff
struct _Objc_Classes {
  objc_Class NSApplication;
  objc_Class NSWindow;
}
struct _Objc_Selectors {
  objc_SEL sharedApplication;
  objc_SEL setActivationPolicy_;
  objc_SEL alloc;
  objc_SEL initWithContentRect_styleMask_backing_defer_;
  objc_SEL makeKeyAndOrderFront_;
}

__gshared _Objc_Classes _objc_classes;
__gshared _Objc_Selectors _objc_selectors;

void init_objc_classes_and_selectors() {
  _objc_classes.NSApplication = objc_getClass("NSApplication");
  _objc_classes.NSWindow = objc_getClass("NSWindow");

  _objc_selectors.sharedApplication = sel_getUid("sharedApplication");
  _objc_selectors.setActivationPolicy_ = sel_getUid("setActivationPolicy:");
  _objc_selectors.alloc = sel_getUid("alloc");
  _objc_selectors.initWithContentRect_styleMask_backing_defer_ = sel_getUid("initWithContentRect:styleMask:backing:defer:");
  _objc_selectors.makeKeyAndOrderFront_ = sel_getUid("makeKeyAndOrderFront:");
}
