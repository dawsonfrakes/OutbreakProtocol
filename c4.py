import ast, ctypes, ctypes.util, enum, importlib, inspect, os, platform, textwrap, types, typing

class CPUs(enum.IntEnum): AMD64 = 0; ARM64 = 1; WASM32 = 2
CPU = CPUs[os.getenv("TARGET_CPU", platform.machine()).upper()]
class OSs(enum.IntEnum): WINDOWS = 0; DARWIN = 1; LINUX = 2
OS = OSs[os.getenv("TARGET_OS", platform.system()).upper()]

class _G:
  def __getattr__(self, name: str) -> typing.Any: return globals()[name]
  def __setattr__(self, name: str, value: typing.Any) -> None: globals()[name] = value
G = _G()

class dtypes:
  type NoReturn = typing.Annotated[typing.NoReturn, typing.NoReturn]
  type CInt = typing.Annotated[int, ctypes.c_int]
  type SSize = typing.Annotated[int, ctypes.c_ssize_t]
  type CUChar = typing.Annotated[int, ctypes.c_ubyte]
  type CUShort = typing.Annotated[int, ctypes.c_ushort]
  type CUInt = typing.Annotated[int, ctypes.c_uint]
  type USize = typing.Annotated[int, ctypes.c_size_t]
  type Opaque = typing.Annotated[ctypes.Structure, ctypes.Structure]
  type Pointer[T] = typing.Annotated[int | bytes | None, ctypes.c_void_p, T]
def dtype_to_ctype(dtype: type | types.GenericAlias) -> type: return getattr(dtype.__value__ if isinstance(dtype, types.GenericAlias) else dtype, "__metadata__")[0]

def ast_of(f: typing.Callable[..., typing.Any]) -> ast.FunctionDef: return typing.cast(ast.FunctionDef, ast.parse(textwrap.dedent(inspect.getsource(f))).body[0])
def dtype_of(expr: ast.expr | None, module: types.ModuleType) -> type: assert expr is not None; return eval(compile(ast.Expression(expr), "dtype_of", "eval"), globals=module.__dict__).__value__
def return_type_of(node: ast.FunctionDef, module: types.ModuleType) -> type: return dtype_of(node.returns, module)
def parameter_types_of(node: ast.FunctionDef, module: types.ModuleType) -> tuple[type, ...]: return tuple(dtype_of(arg.annotation, module) for arg in node.args.args)

def entry[R, **P](alt_name: str | None = None) -> typing.Callable[[typing.Callable[P, R]], typing.Callable[P, R]]:
  def wrapper(of: typing.Callable[P, R]) -> typing.Callable[P, R]:
    setattr(of, "c4_entry", of.__name__ or alt_name)
    return of
  return wrapper

def foreign[R, **P](library: str, /, *, alt_name: str | None = None) -> typing.Callable[[typing.Callable[P, R]], typing.Callable[P, R]]:
  def wrapper(of: typing.Callable[P, R]) -> typing.Callable[P, R]:
    module = importlib.import_module(of.__module__)
    node = ast_of(of)
    if OS == OSs.WINDOWS: f = getattr(getattr(getattr(ctypes, "windll"), library), alt_name or node.name)
    else: f = getattr(ctypes.CDLL(ctypes.util.find_library(library)), alt_name or node.name)
    f.restype, *f.argtypes = map(dtype_to_ctype, (return_type_of(node, module), *parameter_types_of(node, module)))
    return f
  return wrapper

def find_entry(module: types.ModuleType) -> typing.Callable[..., typing.Any]:
  for export in module.__dict__:
    if callable(module.__dict__[export]) and hasattr(module.__dict__[export], "c4_entry"):
      return module.__dict__[export]
  raise NameError("No function was marked with @entry() decorator.")
