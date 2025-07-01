RELEASE :: false;

#import "Basic";
#import "Compiler";
#import "Process";
#import "String";

#run {
  set_build_options_dc(.{do_output=false});

  options := get_build_options();
  if RELEASE options.emit_debug_info = .NONE;
  options.runtime_support_definitions = .OMIT;
  options.output_path = ".build";
  options.output_type = .EXECUTABLE;
  options.output_executable_name = "OutbreakProtocol";

  if options.os_target == .WINDOWS {
    options.use_custom_link_command = true;
  }

  w := compiler_create_workspace();
  if options.emit_debug_info == .NONE {
    remap_import(w, "", "Runtime_Support", "OP_Runtime_Support");
  }
  set_build_options(options, w);
  compiler_begin_intercept(w);
  add_build_file("main.jai", w);

  while true {
    msg := compiler_wait_for_message();
    if !msg || msg.kind == .COMPLETE break;
    if msg.workspace != w continue;

    if msg.kind == .PHASE {
      phase := cast(*Message_Phase) msg;
      if phase.phase == .READY_FOR_CUSTOM_LINK_COMMAND {
        Windows_Resources :: #import "Windows_Resources";
        library_path, linker_path := Windows_Resources.find_visual_studio_in_a_ridiculous_garbage_way();
        root := Windows_Resources.find_windows_kit_root();

        cmd: [..]string;
        array_add(*cmd, sprint("%\\link.exe", linker_path));
        array_add(*cmd, "-nologo");
        array_add(*cmd, sprint("-libpath:%", library_path));
        array_add(*cmd, sprint("-libpath:%\\ucrt\\x64", root));
        array_add(*cmd, sprint("-libpath:%\\um\\x64", root));
        array_add(*cmd, sprint("-out:%\\%", options.output_path, phase.executable_name));
        array_add(*cmd, "-nodefaultlib", "-subsystem:windows", "-incremental:no");
        array_add(*cmd, "-ignore:4216", "-noimplib", "-noexp");
        if options.emit_debug_info & (.CODEVIEW | .DEFAULT) array_add(*cmd, "-debug");
        array_add(*cmd, ..phase.compiler_generated_object_files);
        array_add(*cmd, ..phase.support_object_files);
        system_libraries: [..]string;
        for phase.system_libraries {
          if it == "libcmt.lib" continue;
          if it == "vcruntime.lib" continue;
          if it == "ucrt.lib" continue;
          array_add(*system_libraries, it);
        }
        array_add(*cmd, ..system_libraries);
        array_add(*cmd, ..phase.user_libraries);
        if options.text_output_flags & .OUTPUT_LINK_LINE print("%\n", join(..cmd, " "));
        status := run_command(..cmd);
        phase.linker_exit_code = status.exit_code;
        compiler_custom_link_command_is_complete(w);
      }
    }
  }

  compiler_end_intercept(w);
}
