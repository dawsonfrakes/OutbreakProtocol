module basic.macos;

import basic;

// libSystem
@foreign("libSystem") extern(C) noreturn _exit(u32);

// libobjc
struct objc_class; alias objc_Class = objc_class*;
struct objc_selector; alias objc_SEL = objc_selector*;

@foreign("libobjc") extern(C) void objc_msgSend();
@foreign("libobjc") extern(C) objc_Class objc_getClass(const(char)*);
@foreign("libobjc") extern(C) objc_SEL sel_getUid(const(char)*);

// Foundation
struct NSString {
  static NSString* alloc() {
    alias F = extern(C) NSString* function(objc_Class, objc_SEL);
    return (cast(F) &objc_msgSend)(_objc_classes.NSString, _objc_selectors.alloc);
  }
  NSString* initWithUTF8String(const(char)* s) {
    alias F = extern(C) NSString* function(NSString*, objc_SEL, const(char)*);
    return (cast(F) &objc_msgSend)(&this, _objc_selectors.initWithUTF8String_, s);
  }
}
struct NSDate {

}

// CoreGraphics
struct CGPoint {
  f64 x;
  f64 y;
}
struct CGSize {
  f64 width;
  f64 height;
}
struct CGRect {
  CGPoint origin;
  CGSize size;
}

// AppKit
struct NSEvent {
  enum Mask : u64 { // @EnumFlags
    ANY = -1,
  }

  void release() {
    alias F = extern(C) void function(NSEvent*, objc_SEL);
    (cast(F) &objc_msgSend)(&this, _objc_selectors.release);
  }
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
  NSEvent* nextEvent(NSEvent.Mask mask, NSDate* until, NSString* mode, bool dequeue) {
    alias F = extern(C) NSEvent* function(NSApplication*, objc_SEL, NSEvent.Mask, NSDate*, NSString*, bool);
    return (cast(F) &objc_msgSend)(&this, _objc_selectors.nextEventMatchingMask_untilDate_inMode_dequeue_, mask, until, mode, dequeue);
  }
  void sendEvent(NSEvent* ev) {
    alias F = extern(C) void function(NSApplication*, objc_SEL, NSEvent*);
    (cast(F) &objc_msgSend)(&this, _objc_selectors.sendEvent_, ev);
  }
}
struct NSWindow {
  enum BackingStore : u32 {
    RETAINED = 0,
    NONRETAINED = 1,
    BUFFERED = 2,
  }
  enum StyleMask : u32 { // @EnumFlags
    BORDERLESS = 0,
    TITLED = 1 << 0,
    CLOSABLE = 1 << 1,
    MINIATURIZABLE = 1 << 2,
    RESIZABLE = 1 << 3,
    FULLSCREEN = 1 << 14,
  }

  static NSWindow* alloc() {
    alias F = extern(C) NSWindow* function(objc_Class, objc_SEL);
    return (cast(F) &objc_msgSend)(_objc_classes.NSWindow, _objc_selectors.alloc);
  }
  NSWindow* initWithContentRect(CGRect rect, StyleMask style, BackingStore backing, bool deferred) {
    alias F = extern(C) NSWindow* function(NSWindow*, objc_SEL, CGRect, StyleMask, BackingStore, bool);
    return (cast(F) &objc_msgSend)(&this, _objc_selectors.initWithContentRect_styleMask_backing_defer_, rect, style, backing, deferred);
  }
  NSString* setTitle(NSString* s) {
    alias F = extern(C) NSString* function(NSWindow*, objc_SEL, NSString*);
    return (cast(F) &objc_msgSend)(&this, _objc_selectors.setTitle_, s);
  }
  void makeKeyAndOrderFront(void* sender) {
    alias F = extern(C) void function(NSWindow*, objc_SEL, void*);
    (cast(F) &objc_msgSend)(&this, _objc_selectors.makeKeyAndOrderFront_, sender);
  }
}

@foreign("Foundation") extern(C) __gshared extern NSString* NSDefaultRunLoopMode;

@foreign("AppKit") extern(C) bool NSApplicationLoad();

struct _Objc_Classes {
  objc_Class NSString;
  objc_Class NSApplication;
  objc_Class NSWindow;
}
struct _Objc_Selectors {
  objc_SEL alloc;
  objc_SEL release;
  objc_SEL run;
  objc_SEL sharedApplication;
  objc_SEL setActivationPolicy_;
  objc_SEL initWithContentRect_styleMask_backing_defer_;
  objc_SEL makeKeyAndOrderFront_;
  objc_SEL initWithUTF8String_;
  objc_SEL setTitle_;
  objc_SEL nextEventMatchingMask_untilDate_inMode_dequeue_;
  objc_SEL sendEvent_;
}

__gshared _Objc_Classes _objc_classes;
__gshared _Objc_Selectors _objc_selectors;

void init_objc_classes_and_selectors() {
  _objc_classes.NSString = objc_getClass("NSString");
  _objc_classes.NSApplication = objc_getClass("NSApplication");
  _objc_classes.NSWindow = objc_getClass("NSWindow");

  _objc_selectors.alloc = sel_getUid("alloc");
  _objc_selectors.release = sel_getUid("release");
  _objc_selectors.run = sel_getUid("run");
  _objc_selectors.sharedApplication = sel_getUid("sharedApplication");
  _objc_selectors.setActivationPolicy_ = sel_getUid("setActivationPolicy:");
  _objc_selectors.initWithContentRect_styleMask_backing_defer_ = sel_getUid("initWithContentRect:styleMask:backing:defer:");
  _objc_selectors.makeKeyAndOrderFront_ = sel_getUid("makeKeyAndOrderFront:");
  _objc_selectors.initWithUTF8String_ = sel_getUid("initWithUTF8String:");
  _objc_selectors.setTitle_ = sel_getUid("setTitle:");
  _objc_selectors.nextEventMatchingMask_untilDate_inMode_dequeue_ = sel_getUid("nextEventMatchingMask:untilDate:inMode:dequeue:");
  _objc_selectors.sendEvent_ = sel_getUid("sendEvent:");
}

