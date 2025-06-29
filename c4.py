import ast, ctypes, ctypes.util, enum, importlib, inspect, os, platform, textwrap, types, typing

class CPUs(enum.IntEnum): AMD64 = 0; ARM64 = 1; WASM32 = 2
CPU = CPUs[os.getenv("TARGET_CPU", platform.machine()).upper()]
class OSs(enum.IntEnum): WINDOWS = 0; DARWIN = 1; LINUX = 2
OS = OSs[os.getenv("TARGET_OS", platform.system()).upper()]

class _G:
	def __getattr__(self, name: str) -> typing.Any: return globals()[name]
	def __setattr__(self, name: str, value: typing.Any) -> None: globals()[name] = value
G = _G()

class _Struct:
	def __class_getitem__(cls, items: tuple[str, list[tuple[str, types.GenericAlias]], bool]):
		name, fields, packed = items
		fields = [(name, _dtype_to_ctype(dtype)) for name, dtype in fields]
		class X(ctypes.Structure): _pack_ = int(packed); _fields_ = fields
		X.__qualname__, X.__name__ = name, name
		return typing.Annotated[X, X]

class _Opaque:
	def __class_getitem__(cls, name: str):
		class X(ctypes.Structure): pass
		X.__qualname__, X.__name__ = name, name
		return typing.Annotated[X, X]

class _Procedure:
	def __class_getitem__(cls, items: tuple[types.GenericAlias, list[types.GenericAlias]]):
		return typing.Annotated[typing.Callable[..., typing.Any], ctypes.CFUNCTYPE(*map(_dtype_to_ctype, (items[0], *items[1])))]

class dtypes:
	type NoReturn = typing.Annotated[typing.NoReturn, typing.NoReturn]
	type Void = typing.Annotated[None, None]
	type CWChar = typing.Annotated[int, ctypes.c_wchar]
	type CInt = typing.Annotated[int, ctypes.c_int]
	type CUInt = typing.Annotated[int, ctypes.c_uint]
	type SSize = typing.Annotated[int, ctypes.c_ssize_t]
	type USize = typing.Annotated[int, ctypes.c_size_t]
	type Pointer[_T] = typing.Annotated[int | bytes | None, ctypes.c_void_p]
	type Opaque[name] = _Opaque[name]
	type Struct[name, fields, packed] = _Struct[name, fields, packed]
	type Procedure[returns, *params] = _Procedure[returns, params]

def _dtype_to_ctype(dtype: types.GenericAlias) -> typing.Any: return dtype.__value__.__metadata__[0]
def _ast_of(f: typing.Callable[..., typing.Any]) -> ast.FunctionDef: return typing.cast(ast.FunctionDef, ast.parse(textwrap.dedent(inspect.getsource(f))).body[0])
def _dtype_of(expr: ast.expr | None, module: types.ModuleType) -> types.GenericAlias: assert expr is not None; return eval(compile(ast.Expression(expr), "_dtype_of", "eval"), globals=module.__dict__)
def _return_type_of(node: ast.FunctionDef, module: types.ModuleType) -> types.GenericAlias: return _dtype_of(node.returns, module)
def _parameter_types_of(node: ast.FunctionDef, module: types.ModuleType) -> tuple[types.GenericAlias, ...]: return tuple(_dtype_of(arg.annotation, module) for arg in node.args.args)

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
		if OS == OSs.WINDOWS: f = getattr(getattr(getattr(ctypes, "windll"), library), alt_name or of.__name__)
		else: f = getattr(ctypes.CDLL(ctypes.util.find_library(library)), alt_name or of.__name__)
		f.restype, *f.argtypes = map(_dtype_to_ctype, (_return_type_of(node, module), *_parameter_types_of(node, module)))
		return f
	return wrapper

@typing.overload
def struct(maybe: type, /) -> types.GenericAlias: ...
@typing.overload
def struct(maybe: None = None, /, *, packed: bool = False) -> typing.Callable[[type], types.GenericAlias]: ...

def struct(maybe: type | None = None, /, *, packed: bool = False) -> types.GenericAlias | typing.Callable[[type], types.GenericAlias]:
	def wrapper(cls: type) -> types.GenericAlias: return dtypes.Struct[cls.__name__, [(name, dtype) for name, dtype in cls.__annotations__.items()], packed]
	return wrapper if maybe is None else wrapper(maybe)

def find_entry(module: types.ModuleType) -> typing.Callable[..., typing.Any]:
	for export in module.__dict__:
		if callable(module.__dict__[export]) and hasattr(module.__dict__[export], "c4_entry"):
			return module.__dict__[export]
	raise ValueError("Module did not contain function marked with @entry decorator.")
