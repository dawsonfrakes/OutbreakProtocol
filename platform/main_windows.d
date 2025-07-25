import basic;
mixin(import_dynamic("basic.windows", attributes: ["__gshared"], except: ["Kernel32"]));

__gshared {
  HINSTANCE platform_hinstance;
}

extern(Windows) noreturn WinMainCRTStartup() {
  auto User32_dll = LoadLibraryW("USER32.DLL");
  static foreach (member; __traits(allMembers, basic.windows)) {
    static if (has_uda!(foreign, __traits(getMember, basic.windows, member)) &&
     !string_equal!(get_uda!(foreign, __traits(getMember, basic.windows, member)).library, "Kernel32"))
    {
      mixin(member~` = cast(typeof(`~member~`)) GetProcAddress(`~get_uda!(foreign, __traits(getMember, basic.windows, member)).library~`_dll, "`~member~`");`);
    }
  }

  platform_hinstance = GetModuleHandleW(null);

  SetProcessDPIAware();

  ExitProcess(0);
}

extern(Windows) s32 _fltused;

pragma(linkerDirective, "-subsystem:windows");
pragma(lib, "Kernel32");
