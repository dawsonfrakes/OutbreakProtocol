#import "Basic2";
#import "Windows2";

platform_hinstance: HINSTANCE;

WinMainCRTStartup :: () -> noreturn #c_call {
  platform_hinstance = GetModuleHandleW(null);

  SetProcessDPIAware();

  ExitProcess(0);
}
