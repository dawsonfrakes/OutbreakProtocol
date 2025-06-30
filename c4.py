import ast, ctypes, ctypes.util, enum, importlib, inspect, os, platform, textwrap, types, typing

class CPUs(enum.IntEnum): AMD64 = 0; ARM64 = 1; WASM32 = 2
CPU = CPUs[os.getenv("TARGET_CPU", platform.machine()).upper()]
class OSs(enum.IntEnum): WINDOWS = 0; DARWIN = 1; LINUX = 2
OS = OSs[os.getenv("TARGET_OS", platform.system()).upper()]

class _G:
	def __getattr__(self, name: str) -> typing.Any: return globals()[name]
	def __setattr__(self, name: str, value: typing.Any) -> None: globals()[name] = value
G = _G()

_T = typing.TypeVar("_T")
_P = typing.ParamSpec("_P")
_R = typing.TypeVar("_R")
class _Unused(typing.Generic[_T]): pass

class dtypes:
	NoReturn = typing.Annotated[typing.NoReturn, typing.NoReturn]
	CChar = typing.Annotated[int, ctypes.c_char]
	CWChar = typing.Annotated[int, ctypes.c_wchar]
	CSChar = typing.Annotated[int, ctypes.c_byte]
	CShort = typing.Annotated[int, ctypes.c_short]
	CInt = typing.Annotated[int, ctypes.c_int]
	CUChar = typing.Annotated[int, ctypes.c_ubyte]
	CUShort = typing.Annotated[int, ctypes.c_ushort]
	CUInt = typing.Annotated[int, ctypes.c_uint]
	SSize = typing.Annotated[int, ctypes.c_ssize_t]
	USize = typing.Annotated[int, ctypes.c_size_t]
	Pointer = typing.Annotated[int | bytes | _Unused[_T] | None, ctypes.c_void_p]
	class Struct:
		def __class_getitem__(cls, items: tuple[str, list[tuple[str, type]], bool]):
			name, fields, packed = items
			fields = [(name, _dtype_to_ctype(dtype)) for name, dtype in fields]
			class X(ctypes.Structure): _pack_ = int(packed); _fields_ = fields
			X.__qualname__, X.__name__ = name
			return typing.Annotated[X, X]
	class Procedure:
		def __class_getitem__(cls, items: tuple[type, ...]):
			X = ctypes.CFUNCTYPE(*map(_dtype_to_ctype, items))
			return typing.Annotated[X, X]

def _dtype_to_ctype(dtype: type) -> typing.Any: return dtype if isinstance(dtype, ctypes.Structure) else getattr(dtype, "__metadata__")[0]
def _ast_of(f: typing.Callable[..., typing.Any]) -> ast.FunctionDef: return typing.cast(ast.FunctionDef, ast.parse(textwrap.dedent(inspect.getsource(f))).body[0])
def _dtype_of(expr: ast.expr | None, module: types.ModuleType) -> type: assert expr is not None; return eval(compile(ast.Expression(expr), "_dtype_of", "eval"), globals=module.__dict__)
def _return_type_of(node: ast.FunctionDef, module: types.ModuleType) -> type: return _dtype_of(node.returns, module)
def _parameter_types_of(node: ast.FunctionDef, module: types.ModuleType) -> tuple[type, ...]: return tuple(_dtype_of(arg.annotation, module) for arg in node.args.args)

def size_of(dtype: type) -> dtypes.USize: return ctypes.sizeof(_dtype_to_ctype(dtype))
def addr_of(o: _T) -> dtypes.Pointer[_T]: return ctypes.addressof(typing.cast(typing.Any, o))

@typing.overload
def entry(maybe: typing.Callable[_P, _R], /) -> typing.Callable[_P, _R]: ...
@typing.overload
def entry(maybe: None = None, /, *, alt_name: str | None = None) -> typing.Callable[[typing.Callable[_P, _R]], typing.Callable[_P, _R]]: ...
def entry(maybe: typing.Callable[_P, _R] | None = None, /, *, alt_name: str | None = None) -> typing.Callable[_P, _R] | typing.Callable[[typing.Callable[_P, _R]], typing.Callable[_P, _R]]:
	def wrapper(of: typing.Callable[_P, _R]) -> typing.Callable[_P, _R]:
		setattr(of, "c4_entry", alt_name or of.__name__)
		return of
	return wrapper if maybe is None else wrapper(maybe)

def foreign(library: str, /, *, alt_name: str | None = None) -> typing.Callable[[typing.Callable[_P, _R]], typing.Callable[_P, _R]]:
	def wrapper(of: typing.Callable[_P, _R]) -> typing.Callable[_P, _R]:
		node = _ast_of(of)
		module = importlib.import_module(of.__module__)
		if OS == OSs.WINDOWS: f = getattr(getattr(getattr(ctypes, "windll"), library), alt_name or of.__name__)
		else: f = getattr(ctypes.CDLL(ctypes.util.find_library(library)), alt_name or of.__name__)
		f.restype, *f.argtypes = map(_dtype_to_ctype, (_return_type_of(node, module), *_parameter_types_of(node, module)))
		return f
	return wrapper

@typing.overload
def struct(maybe: _T, /) -> _T: ...
@typing.overload
def struct(maybe: None = None, /, *, packed: bool = False) -> typing.Callable[[_T], _T]: ...
def struct(maybe: _T | None = None, /, *, packed: bool = False) -> _T | typing.Callable[[type], type]:
	def wrapper(cls: type) -> type: return dtypes.Struct[cls.__name__, [(name, dtype) for name, dtype in cls.__annotations__.items()], packed]
	return wrapper if maybe is None else wrapper(typing.cast(type, maybe))

def find_entry(module: types.ModuleType) -> typing.Callable[..., typing.Any]:
	for export in module.__dict__:
		if callable(module.__dict__[export]) and hasattr(module.__dict__[export], "c4_entry"):
			return module.__dict__[export]
	raise ValueError("No function in module tagged with @entry decorator.")
