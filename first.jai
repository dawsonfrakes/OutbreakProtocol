RELEASE :: false;

#import "Basic";
#import "Compiler";
#import "File";
#import "Process";
#import "String";

build :: () {
  set_build_options_dc(.{do_output=false});

  options := get_build_options();
  options.output_type = .EXECUTABLE;
  options.output_path = ".build";
  options.output_executable_name = "OutbreakProtocol";
  options.runtime_support_definitions = .OMIT;
  options.use_custom_link_command = true;

  w := compiler_create_workspace();
  set_build_options(options, w);
  remap_import(w, "", "Runtime_Support", "Runtime_Support2");
  compiler_begin_intercept(w);
  add_build_string(sprint("DEBUG :: %;", !RELEASE), w);
  if options.os_target == {
    case .WINDOWS; add_build_file("platform/main_windows.jai", w);
  }
  while true {
    message := compiler_wait_for_message();
    if message.workspace != w continue;
    if message.kind == {
      case .COMPLETE; break;
      case .PHASE;
        phase := message.(*Message_Phase);
        if phase.phase == {
          case .READY_FOR_CUSTOM_LINK_COMMAND;
            #if OS == .WINDOWS {
              #import "Windows_Resources";
              library_path, linker_path := find_visual_studio_in_a_ridiculous_garbage_way();
              root := find_windows_kit_root();

              system_libraries: [..]string;
              for phase.system_libraries {
                if it == "kernel32.lib" continue;
                if it == "libcmt.lib" continue;
                // if it == "vcruntime.lib" continue;
                if it == "ucrt.lib" continue;
                array_add(*system_libraries, it);
              }

              entry_suffix := "";
              for phase.compiler_generated_object_files {
                status, output := run_command(sprint("%\\dumpbin.exe", linker_path), "/symbols", it, capture_and_return_output=true);
                found, remainder := contains(output, "WinMainCRTStartup");
                if !found continue;
                entry_suffix = slice(remainder, 0, find_index_of_any_from_left(remainder, " \t\n\r"));
                break;
              }
              assert(entry_suffix.count != 0);

              cmd: [..]string;
              array_add(*cmd, sprint("%\\link.exe", linker_path));
              array_add(*cmd, sprint("-out:%\\%", options.output_path, phase.executable_name));
              array_add(*cmd, sprint("-libpath:%", library_path));
              array_add(*cmd, sprint("-libpath:%\\ucrt\\x64", root));
              array_add(*cmd, sprint("-libpath:%\\um\\x64", root));
              array_add(*cmd, "-nologo", "-incremental:no", "-nodefaultlib");
              array_add(*cmd, "-subsystem:windows", sprint("-entry:WinMainCRTStartup%", entry_suffix));
              array_add(*cmd, ..phase.compiler_generated_object_files);
              array_add(*cmd, ..phase.support_object_files);
              array_add(*cmd, ..system_libraries);
              array_add(*cmd, ..phase.user_libraries);
              if options.text_output_flags & .OUTPUT_LINK_LINE print("%\n", join(..cmd, " "));
              status := run_command(..cmd);
              phase.linker_exit_code = status.exit_code;
            }
            compiler_custom_link_command_is_complete(w);
        }
    }
  }
  compiler_end_intercept(w);
}

#run build();
