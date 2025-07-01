module basic.macos;

import basic : foreign;

// libSystem
@foreign("libSystem") extern(C) noreturn _exit(int);

// libobjc
struct objc_class; alias objc_Class = objc_class*;
struct objc_selector; alias objc_SEL = objc_selector*;

@foreign("libobjc") extern(C) void objc_msgSend();
@foreign("libobjc") extern(C) objc_Class objc_getClass(const(char)*);
@foreign("libobjc") extern(C) objc_SEL sel_getUid(const(char)*);

// AppKit
struct NSApplication {
  enum ActivationPolicy : int {
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

@foreign("AppKit") extern(C) bool NSApplicationLoad();

// objc stuff
struct _Objc_Classes {
  objc_Class NSApplication;
}
struct _Objc_Selectors {
  objc_SEL sharedApplication;
  objc_SEL setActivationPolicy_;
}

__gshared _Objc_Classes _objc_classes;
__gshared _Objc_Selectors _objc_selectors;

// TODO(dfra): automate this if it gets too hairy.
void init_objc_classes_and_selectors() {
  _objc_classes.NSApplication = objc_getClass("NSApplication");

  _objc_selectors.sharedApplication = sel_getUid("sharedApplication");
  _objc_selectors.setActivationPolicy_ = sel_getUid("setActivationPolicy:");
}
