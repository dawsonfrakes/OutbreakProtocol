module basic;

alias s8 = byte;
alias s16 = short;
alias s32 = int;
alias s64 = long;
alias ssize = ptrdiff_t;

alias u8 = ubyte;
alias u16 = ushort;
alias u32 = uint;
alias u64 = ulong;
alias usize = size_t;

alias f32 = float;
alias f64 = double;

struct uda {}

@uda struct foreign {
  string library;
}

alias AliasSeq(Ts...) = Ts;

enum has_uda(alias UDA, alias Object) = {
  static foreach (attribute; __traits(getAttributes, Object))
    static if (is(typeof(attribute) == UDA)) return true;
  return false;
}();

enum get_uda(alias UDA, alias Object) = {
  static foreach (attribute; __traits(getAttributes, Object))
    static if (is(typeof(attribute) == UDA)) return attribute;
}();

enum string_equal(string a, string b) = {
  static if (a.length != b.length) return false;
  static foreach (i; 0..a.length)
    static if (a[i] != b[i]) return false;
  return true;
}();

enum string_equal_any(string a, string[] bs) = {
  static foreach (b; bs)
    static if (string_equal!(a, b)) return true;
  return false;
}();

string import_dynamic(string module_path, string[] attributes, string[] except) {
  string result = `
    static import `~module_path~`;`~`
    static foreach (member; __traits(allMembers, `~module_path~`)) {
      static if (!is(__traits(getMember, `~module_path~`, member) == module)) {
        static if (has_uda!(foreign, __traits(getMember, `~module_path~`, member)) &&
                   !string_equal_any!(get_uda!(foreign, __traits(getMember, `~module_path~`, member)).library, [`;
  foreach (e; except) result ~= `"`~e~`"`;
  result ~= `])) {
          mixin("`;
  foreach (a; attributes) result ~= a~" ";
  result ~= `typeof(`~module_path~`."~member~")* "~member~";");
        } else {
          mixin("alias "~member~" = `~module_path~`."~member~";");
        }
      }
    }
  `;
  return result;
}
