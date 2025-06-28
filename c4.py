import ast, ctypes, ctypes.util, enum, importlib, inspect, os, platform, textwrap, types, typing

class CPUs(enum.IntEnum): AMD64 = 0; ARM64 = 1; WASM32 = 2
CPU = CPUs[os.getenv("TARGET_CPU", platform.machine()).upper()]
class OSs(enum.IntEnum): WINDOWS = 0; DARWIN = 1; LINUX = 2
OS = OSs[os.getenv("TARGET_OS", platform.system()).upper()]

class dtypes:
  NoReturn = typing.Annotated[typing.NoReturn, typing.NoReturn]
  Void = typing.Annotated[None, None]
  CChar = typing.Annotated[int, ctypes.c_char]
  CSChar = typing.Annotated[int, ctypes.c_byte]
  CShort = typing.Annotated[int, ctypes.c_short]
  CInt = typing.Annotated[int, ctypes.c_int]
  CLong = typing.Annotated[int, ctypes.c_long]
  CLongLong = typing.Annotated[int, ctypes.c_longlong]
  CUChar = typing.Annotated[int, ctypes.c_ubyte]
  CUShort = typing.Annotated[int, ctypes.c_ushort]
  CUInt = typing.Annotated[int, ctypes.c_uint]
  CULong = typing.Annotated[int, ctypes.c_ulong]
  CULongLong = typing.Annotated[int, ctypes.c_ulonglong]

def _dtype_to_ctype(dtype: type) -> type: return getattr(dtype, "__metadata__")[0]
def _ast_of(f: typing.Callable[..., typing.Any]) -> ast.FunctionDef: return typing.cast(ast.FunctionDef, ast.parse(textwrap.dedent(inspect.getsource(f))).body[0])
def _dtype_of(expr: ast.expr | None, module: types.ModuleType) -> type: assert expr is not None; return eval(compile(ast.Expression(expr), "_dtype_of", "eval"), globals=module.__dict__)
def _return_type_of(node: ast.FunctionDef, module: types.ModuleType) -> type: return _dtype_of(node.returns, module)
def _parameter_types_of(node: ast.FunctionDef, module: types.ModuleType) -> tuple[type, ...]: return tuple(_dtype_of(arg.annotation, module) for arg in node.args.args)

@typing.overload
def entry[R, **P](maybe: typing.Callable[P, R], /) -> typing.Callable[P, R]: ...
@typing.overload
def entry[R, **P](maybe: None = None, /, *, alt_name: str | None = None) -> typing.Callable[[typing.Callable[P, R]], typing.Callable[P, R]]: ...
def entry[R, **P](maybe: typing.Callable[P, R] | None = None, /, *, alt_name: str | None = None) -> typing.Callable[P, R] | typing.Callable[[typing.Callable[P, R]], typing.Callable[P, R]]:
  def wrapper(of: typing.Callable[P, R]) -> typing.Callable[P, R]:
    setattr(of, "c4_entry", alt_name or of.__name__)
    return of
  return wrapper if maybe is None else wrapper(maybe)

def foreign[R, **P](library: str, /, *, alt_name: str | None = None) -> typing.Callable[[typing.Callable[P, R]], typing.Callable[P, R]]:
  def wrapper(of: typing.Callable[P, R]) -> typing.Callable[P, R]:
    node = _ast_of(of)
    module = importlib.import_module(of.__module__)
    if OS == OSs.WINDOWS: f = getattr(getattr(getattr(ctypes, "windll"), library), alt_name or node.name)
    else: f = getattr(ctypes.CDLL(ctypes.util.find_library(library)), alt_name or node.name)
    f.restype, *f.argtypes = map(_dtype_to_ctype, (_return_type_of(node, module), *_parameter_types_of(node, module)))
    return f
  return wrapper

def find_entry(module: types.ModuleType) -> typing.Callable[..., typing.Any]:
  for export in module.__dict__:
    if callable(module.__dict__[export]) and hasattr(module.__dict__[export], "c4_entry"):
      return module.__dict__[export]
  raise ValueError("No function were marked with @entry decorator.")

def module_to_c(module: types.ModuleType) -> str:
  class Visitor(ast.NodeVisitor):
    def generic_visit(self, node: typing.Any) -> None: raise NotImplementedError(node.__class__.__name__)
    def visit_Constant(self, node: ast.Constant) -> str: return str(node.value)
    def visit_Name(self, node: ast.Name) -> str: return node.id
    def visit_Attribute(self, node: ast.Attribute) -> str: return f"{self.visit(node.value)}.{node.attr}"
    def visit_Eq(self, node: ast.Eq) -> str: return "=="
    def visit_Compare(self, node: ast.Compare) -> str: return f"{self.visit(node.left)} {self.visit(node.ops[0])} {self.visit(node.comparators[0])}"
    def visit_If(self, node: ast.If) -> str: return f"if ({self.visit(node.test)}) {{\n{"\n".join(map(lambda x: "  " + self.visit(x), node.body))}\n}} else {{\n{"\n".join(map(self.visit, node.orelse))}\n}}"
    def visit_Expr(self, node: ast.Expr) -> str: return self.visit(node.value)
    def visit_Call(self, node: ast.Call) -> str: return f"{self.visit(node.func)}({", ".join(map(self.visit, node.args))})"
    def visit_arg(self, node: ast.arg) -> str: assert node.annotation is not None; return f"{self.visit(node.annotation)} {node.arg}"
    def visit_arguments(self, node: ast.arguments) -> str: return ", ".join(map(self.visit, node.args))
    def visit_FunctionDef(self, node: ast.FunctionDef) -> str: assert node.returns is not None; return f"{self.visit(node.returns)} {node.name}({self.visit(node.args)}){f" {{{"\n".join(map(self.visit, node.body))}}}" if not (isinstance(node.body[0], ast.Expr) and isinstance(node.body[0].value, ast.Constant) and isinstance(node.body[0].value.value, types.EllipsisType)) else ";"}"
    def visit_ImportFrom(self, node: ast.ImportFrom) -> str: assert node.module == "c4"; return ""
    def visit_Module(self, node: ast.Module) -> str: return "\n".join(map(self.visit, node.body))
  return Visitor().visit(ast.parse(textwrap.dedent(inspect.getsource(module))))
