libSystem :: #library,system "libSystem";

_exit :: (status: s32) #foreign libSystem;

libobjc :: #library,system "libobjc";

objc_id :: *void;
objc_Class :: *struct {};
objc_SEL :: *struct {};

objc_msgSend :: () #foreign libobjc;
objc_getClass :: (name: *u8) -> objc_Class #foreign libobjc;
sel_getUid :: (name: *u8) -> objc_SEL #foreign libobjc;

AppKit :: #library,system "AppKit";

NSApplicationLoad :: () -> bool #foreign AppKit;

CGPoint :: struct {
  x: float64;
  y: float64;
}

CGSize :: struct {
  width: float64;
  height: float64;
}

CGRect :: struct {
  origin: CGPoint;
  size: CGSize;
}

NSApplication :: struct {
  ActivationPolicy :: enum s32 {
    REGULAR :: 0;
    ACCESSORY :: 1;
    PROHIBITED :: 2;
  }

  sharedApplication :: () -> *NSApplication #no_context {
    F := cast(#type (objc_Class, objc_SEL) -> *NSApplication #c_call) objc_msgSend;
    return F(_objc_classes.NSApplication, _objc_selectors.sharedApplication);
  }

  setActivationPolicy :: (obj: *NSApplication, policy: ActivationPolicy) -> bool #no_context {
    F := cast(#type (*NSApplication, objc_SEL, ActivationPolicy) -> bool #c_call) objc_msgSend;
    return F(obj, _objc_selectors.setActivationPolicy_, policy);
  }

  run :: (obj: *NSApplication) #no_context {
    F := cast(#type (*NSApplication, objc_SEL) #c_call) objc_msgSend;
    F(obj, _objc_selectors.run);
  }
}

NSWindow :: struct {
  StyleMask :: enum_flags u32 {
    BORDERLESS :: 0 << 0;
    TITLED :: 1 << 0;
    CLOSABLE :: 1 << 1;
    MINIATURIZABLE :: 1 << 2;
    RESIZABLE :: 1 << 3;
  }

  BackingStoreType :: enum u32 {
    RETAINED :: 0;
    NONRETAINED :: 1;
    BUFFERED :: 2;
  }

  alloc :: () -> *NSWindow #no_context {
    F := cast(#type (objc_Class, objc_SEL) -> *NSWindow #c_call) objc_msgSend;
    return F(_objc_classes.NSWindow, _objc_selectors.alloc);
  }

  init :: (obj: *NSWindow, rect: CGRect, style: StyleMask, backing: BackingStoreType, deferred: bool) -> *NSWindow #no_context {
    F := cast(#type (*NSWindow, objc_SEL, CGRect, StyleMask, BackingStoreType, bool) -> *NSWindow #c_call) objc_msgSend;
    return F(obj, _objc_selectors.initWithContentRect_styleMask_backing_defer_, rect, style, backing, deferred);
  }

  makeKeyAndOrderFront :: (obj: *NSWindow, sender: objc_id) #no_context {
    F := cast(#type (*NSWindow, objc_SEL, objc_id) #c_call) objc_msgSend;
    F(obj, _objc_selectors.makeKeyAndOrderFront_, sender);
  }
}

_objc_classes: struct {
  NSApplication: objc_Class;
  NSWindow: objc_Class;
}

_objc_selectors: struct {
  sharedApplication: objc_SEL;
  setActivationPolicy_: objc_SEL;
  alloc: objc_SEL;
  initWithContentRect_styleMask_backing_defer_: objc_SEL;
  makeKeyAndOrderFront_: objc_SEL;
  run: objc_SEL;
}

init_objc_classes_and_selectors :: () #no_context {
  _objc_classes.NSApplication = objc_getClass("NSApplication");
  _objc_classes.NSWindow = objc_getClass("NSWindow");

  _objc_selectors.sharedApplication = sel_getUid("sharedApplication");
  _objc_selectors.setActivationPolicy_ = sel_getUid("setActivationPolicy:");
  _objc_selectors.alloc = sel_getUid("alloc");
  _objc_selectors.initWithContentRect_styleMask_backing_defer_ = sel_getUid("initWithContentRect:styleMask:backing:defer:");
  _objc_selectors.makeKeyAndOrderFront_ = sel_getUid("makeKeyAndOrderFront:");
  _objc_selectors.run = sel_getUid("run");
}
