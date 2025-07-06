#include "basic.hpp"

#import "AppKit/AppKit.h"
#import <MetalKit/MetalKit.h>

@interface MetalView : MTKView <MTKViewDelegate>
@end

@implementation MetalView {
  id<MTLDevice> _device;
  id<MTLCommandQueue> _commandQueue;
}
- (instancetype)initWithFrame:(NSRect)frameRect device:(id<MTLDevice>)device {
  self = [super initWithFrame:frameRect device:device];
  if (self) {
    _device = device;
    self.device = _device;
    self.colorPixelFormat = MTLPixelFormatBGRA8Unorm;
    self.delegate = self;

    _commandQueue = [_device newCommandQueue];
  }
  return self;
}
- (void)drawInMTKView:(MTKView *)view {
  view.currentRenderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.6f, 0.2f, 0.2f, 1.0f);

  id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
  id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:view.currentRenderPassDescriptor];
  [encoder endEncoding];

  [commandBuffer presentDrawable:view.currentDrawable];
  [commandBuffer commit];
}
- (void)mtkView:(MTKView*)view drawableSizeWillChange:(CGSize)size {

}
@end

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
    initWithContentRect:NSMakeRect(0, 0, 640, 480)
    styleMask:NSWindowStyleMaskTitled|NSWindowStyleMaskClosable|NSWindowStyleMaskMiniaturizable|NSWindowStyleMaskResizable
    backing:NSBackingStoreBuffered
    defer:NO];
  [platform_window setTitle:@"Outbreak Protocol"];
  id<MTLDevice> device = MTLCreateSystemDefaultDevice();
  MetalView* metal_view = [[MetalView alloc] initWithFrame:NSMakeRect(0, 0, 640, 480) device:device];
  metal_view.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
  [platform_window.contentView addSubview:metal_view];
  [platform_window makeKeyAndOrderFront:nil];

  while (platform_running) {
    while (NSEvent* ev = [platform_app nextEventMatchingMask:NSEventMaskAny untilDate:[NSDate distantPast] inMode:NSDefaultRunLoopMode dequeue:YES]) {
      [platform_app sendEvent:ev];
      [ev release];
    }
  }

  return 0;
}
