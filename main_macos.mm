#include "basic.hpp"

#import "AppKit/AppKit.h"

static bool platform_running = true;
static NSApplication* platform_app;
static NSWindow* platform_window;

extern "C" int main() {
  NSApplicationLoad();

  platform_app = [NSApplication sharedApplication];
  [platform_app setActivationPolicy:NSApplicationActivationPolicyRegular];

  NSMenu* appmenubar = [NSMenu new];
  [platform_app setMainMenu:appmenubar];

  NSMenuItem* appmenuitem = [[NSMenuItem alloc] initWithTitle:@"Outbreak Protocol" action:nil keyEquivalent:@""];
  [appmenubar addItem:appmenuitem];
  NSMenu* appmenu = [NSMenu new];
  [appmenuitem setSubmenu:appmenu];

  NSMenuItem* quitbutton = [[NSMenuItem alloc] initWithTitle:@"Quit Outbreak Protocol" action:@selector(terminate:) keyEquivalent:@"q"];
  [appmenu addItem:quitbutton];

  NSMenuItem* windowmenuitem = [[NSMenuItem new] initWithTitle:@"Window" action:nil keyEquivalent:@""];
  [appmenubar addItem:windowmenuitem];
  NSMenu* windowmenu = [NSMenu new];
  [windowmenuitem setSubmenu:windowmenu];
  [platform_app setWindowsMenu:windowmenu];

  platform_window = [[NSWindow alloc]
    initWithContentRect:CGRect{CGPoint{0, 0}, CGSize{640, 480}}
    styleMask:NSWindowStyleMaskTitled|NSWindowStyleMaskClosable|NSWindowStyleMaskMiniaturizable|NSWindowStyleMaskResizable
    backing:NSBackingStoreBuffered
    defer:NO];
  [platform_window setTitle:@"Outbreak Protocol"];
  [platform_window makeKeyAndOrderFront:nil];

  while (platform_running) {
    while (NSEvent* ev = [platform_app nextEventMatchingMask:NSEventMaskAny untilDate:nil inMode:NSDefaultRunLoopMode dequeue:YES]) {
      [platform_app sendEvent:ev];
      [ev release];
    }
  }

  return 0;
}
