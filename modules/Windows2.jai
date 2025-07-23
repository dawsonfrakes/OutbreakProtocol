#import "Basic2";

Kernel32 :: #library,system "Kernel32";

HRESULT :: #type,isa s32;
HANDLE :: *void;
HINSTANCE :: *struct {};
HMODULE :: HINSTANCE;
PROC :: #type () -> ssize #c_call;

GetModuleHandleW :: (name: *u16) -> HMODULE #foreign Kernel32;
Sleep :: (milliseconds: u32) #foreign Kernel32;
ExitProcess :: (status: u32) -> noreturn #foreign Kernel32;

User32 :: #library,system "User32";

SetProcessDPIAware :: () -> s32 #foreign User32;

Ws2_32 :: #library,system "Ws2_32";

Dwmapi :: #library,system "Dwmapi";

Winmm :: #library,system "Winmm";
