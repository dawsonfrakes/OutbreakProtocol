from c4 import *

if OS == OSs.DARWIN:
  @foreign("System", alt_name="_exit")
  def sys_exit(exit_code: dtypes.CInt) -> dtypes.NoReturn: ...

  @entry(alt_name="_start")
  def start() -> dtypes.NoReturn:
    sys_exit(0)
