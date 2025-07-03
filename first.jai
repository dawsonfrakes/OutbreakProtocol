RELEASE :: false;

#import "Basic";
#import "Compiler";
#import "File";
#import "Process";
#import "String";

#run {
  set_build_options_dc(.{do_output=false});

  options := get_build_options();
  options.output_path = ".build";
  options.runtime_support_definitions = .OMIT;
  options.use_custom_link_command = true;
  options.output_type = .EXECUTABLE;
  options.output_executable_name = "OutbreakProtocol";

  w := compiler_create_workspace();
  set_build_options(options, w);
  compiler_begin_intercept(w);
  if RELEASE remap_import(w, "", "Runtime_Support", "OP_Runtime_Support");
  add_build_string(sprint("DEBUG :: %;", !RELEASE), w);
  add_build_file("main.jai", w);

  while true {
    message := compiler_wait_for_message();
    if !message break;
    if message.workspace != w continue;

    if message.kind == {
      case .COMPLETE; break;
      case .PHASE;
        phase := cast(*Message_Phase) message;
        if phase.phase == .READY_FOR_CUSTOM_LINK_COMMAND {
          #if OS == .WINDOWS {
            #import "Windows_Resources";
            library_path, linker_path := find_visual_studio_in_a_ridiculous_garbage_way();
            root := find_windows_kit_root();

            system_libraries: [..]string;
            for phase.system_libraries {
              if it == "libcmt.lib" continue;
              if it == "vcruntime.lib" continue;
              if it == "ucrt.lib" continue;
              array_add(*system_libraries, it);
            }

            cmd: [..]string;
            array_add(*cmd, sprint("%\\link.exe", linker_path));
            array_add(*cmd, "-nologo", "-incremental:no", "-noexp", "-noimplib");
            array_add(*cmd, "-debug", "-subsystem:windows");
            array_add(*cmd, sprint("-libpath:%", library_path));
            array_add(*cmd, sprint("-libpath:%\\um\\x64", root));
            array_add(*cmd, sprint("-libpath:%\\ucrt\\x64", root));
            array_add(*cmd, sprint("-out:%\\%.exe", options.output_path, options.output_executable_name));
            array_add(*cmd, ..phase.compiler_generated_object_files);
            array_add(*cmd, ..phase.support_object_files);
            array_add(*cmd, ..system_libraries);
            array_add(*cmd, ..phase.user_libraries);

            if options.text_output_flags & .OUTPUT_LINK_LINE print("%\n", join(..cmd, " "));

            status := run_command(..cmd);
            if status.exit_code compiler_report("link failed");
          }
          compiler_custom_link_command_is_complete(w);
        }
    }
  }

  compiler_end_intercept(w);
}
