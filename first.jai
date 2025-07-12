#import "Basic";
#import "Compiler";
#import "File";
#import "Process";
#import "String";

get_jai_mangle_suffix_of_identifier :: (s: string, linker_path: string, object_files: []string) -> string {
  result := "";
  for object_files {
    status, output := run_command(sprint("%\\dumpbin.exe", linker_path), "/symbols", it, capture_and_return_output=true);
    found, remainder := contains(output, s);
    if !found continue;
    result = slice(remainder, 0, find_index_of_any_from_left(remainder, " \t\n\r"));
    break;
  }
  assert(result.count != 0);
  return result;
}

build_game_dll :: () {
  options := get_build_options();
  options.output_type = .DYNAMIC_LIBRARY;
  options.output_path = ".build";
  options.output_executable_name = "game";
  options.runtime_support_definitions = .OMIT;
  options.use_custom_link_command = true;

  w := compiler_create_workspace("Game DLL");
  set_build_options(options, w);
  remap_import(w, "", "Runtime_Support", "Runtime_Support2");
  compiler_begin_intercept(w);
  add_build_string("DEBUG :: true;", w);
  add_build_string(#string END
  #import "Windows2";
  _DllMainCRTStartup :: (handle: HANDLE, reason: u32, reserved: *void) -> s32 #c_call {
    return 1;
  }
  END, w);
  add_build_file("game/main.jai", w);
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

              entry_suffix := get_jai_mangle_suffix_of_identifier("_DllMainCRTStartup", linker_path, phase.compiler_generated_object_files);
              export_suffix := get_jai_mangle_suffix_of_identifier("update_and_render", linker_path, phase.compiler_generated_object_files);

              cmd: [..]string;
              array_add(*cmd, sprint("%\\link.exe", linker_path));
              array_add(*cmd, sprint("-out:%\\%", options.output_path, phase.executable_name));
              array_add(*cmd, sprint("-libpath:%", library_path));
              array_add(*cmd, sprint("-libpath:%\\ucrt\\x64", root));
              array_add(*cmd, sprint("-libpath:%\\um\\x64", root));
              array_add(*cmd, "-nologo", "-incremental:no", "-nodefaultlib", "-noexp", "-noimplib");
              array_add(*cmd, "-dll", sprint("-export:update_and_render=update_and_render%", export_suffix));
              array_add(*cmd, "-debug", "-subsystem:windows", sprint("-entry:_DllMainCRTStartup%", entry_suffix));
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

build_windows_platform_layer :: (dynamic := false) {
  options := get_build_options();
  options.output_type = .EXECUTABLE;
  options.output_path = ".build";
  options.output_executable_name = sprint("OutbreakProtocol%", ifx !dynamic "_Static");
  options.runtime_support_definitions = .OMIT;
  options.use_custom_link_command = true;

  w := compiler_create_workspace(sprint("Windows Platform Layer [%]", ifx dynamic "DYNAMIC" else "STATIC"));
  set_build_options(options, w);
  remap_import(w, "", "Runtime_Support", "Runtime_Support2");
  compiler_begin_intercept(w);
  add_build_string("DEBUG :: true;", w);
  add_build_string(sprint("DYNAMIC :: %;", dynamic), w);
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

              entry_suffix := get_jai_mangle_suffix_of_identifier("WinMainCRTStartup", linker_path, phase.compiler_generated_object_files);

              cmd: [..]string;
              array_add(*cmd, sprint("%\\link.exe", linker_path));
              array_add(*cmd, sprint("-out:%\\%", options.output_path, phase.executable_name));
              array_add(*cmd, sprint("-libpath:%", library_path));
              array_add(*cmd, sprint("-libpath:%\\ucrt\\x64", root));
              array_add(*cmd, sprint("-libpath:%\\um\\x64", root));
              array_add(*cmd, "-nologo", "-incremental:no", "-nodefaultlib");
              array_add(*cmd, "-debug", "-subsystem:windows", sprint("-entry:WinMainCRTStartup%", entry_suffix));
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

build :: () {
  set_build_options_dc(.{do_output=false});
  build_game_dll();
  build_windows_platform_layer(dynamic=true);
  build_windows_platform_layer(dynamic=false);
}

#run build();
