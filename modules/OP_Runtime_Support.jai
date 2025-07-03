#module_parameters(DEFINE_SYSTEM_ENTRY_POINT: bool, DEFINE_INITIALIZATION: bool, ENABLE_BACKTRACE_ON_CRASH: bool);
__element_duplicate :: (start: *u8, num_elements: s64, size: s64) #c_call #no_aoc {
    cursor := start + size;
    for 1..num_elements-1 {
        memcpy(cursor, start, size);
        cursor += size;
    }
}
__array_bounds_check_fail :: (index: s64, limit: s64, line_number: s64, filename: *u8) #no_context {
  debug_break();
}
__cast_bounds_check_fail :: (pre_value: s64, pre_flags: u32, post_value: s64, post_flags: u32, fatal: u8, line_number: s64, filename: *u8) #no_context {
  if fatal debug_break();
}
__null_pointer_check_fail :: (index: s64, line_number: s64, filename: *u8) #no_context {
  debug_break();
}
__arithmetic_overflow :: (left: s64, right: s64, type_code: u16, line_number: s64, filename: *u8) #no_context #no_aoc {
  fatal := (type_code & 0x8000);
  if fatal debug_break();
}
write_string :: (s: string, to_standard_error := false) #no_context #compiler;
write_strings :: (strings: ..string, to_standard_error := false) #no_context #compiler;
__panic_due_to_runtime_call_of_compile_time_procedure :: (line_number: s64, filename: *u8) #no_context {
  debug_break();
}
__instrumentation_first  :: () {}
__instrumentation_second :: () {}
compile_time_debug_break :: () #compiler #no_context;
debug_break :: () #no_context {
  if #compile_time {
    compile_time_debug_break();
  } else {
    #if OS == .PS5 {
      #asm { int 0x41; }
    } else #if CPU == .X64 {
      #asm { int3; }
    } else #if CPU == .ARM64 {
      #bytes .[0x20, 0x00, 0b001_0_0000, 0b1101_0100];
    } else #if OS == .WASM {
      wasm_debug_break :: () #foreign;
      wasm_debug_break();
    } else {
      llvm_trap :: () #intrinsic "llvm.debugtrap";
      llvm_trap();
    }
  }
}
Context_Base :: struct {
    context_info: *Type_Info_Struct;
    thread_index: u32;
    allocator := default_allocator;
    logger: (message: string, data: *void, info: Log_Info);
    logger_data:  *void;
    log_source_identifier: u64;
    log_level: Log_Level;
    temporary_storage: *Temporary_Storage;
    stack_trace: *Stack_Trace_Node;
    assertion_failed: (loc: Source_Code_Location, message: string) -> bool;
    handling_assertion_failure := false;
    default_allocator :: Allocator.{};
}
Temporary_Storage :: struct {
  data: *u8;
  size: s64;
  current_page_bytes_occupied: s64;
  total_bytes_occupied: s64;
  high_water_mark: s64;
  last_set_mark_location: Source_Code_Location;
  overflow_allocator: Allocator;
  overflow_pages: *Overflow_Page;
  original_data: *u8;
  original_size: s64;
  Overflow_Page :: struct {
    next: *Overflow_Page;
    allocator: Allocator;
    size: s64;
  }
}
