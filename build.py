import sys
from c4 import find_entry, module_to_c
import main

match sys.argv[1:]:
  case ("run",): find_entry(main)()
  case ("compile",): print(module_to_c(main))
  case _: print(f"usage: {sys.argv[0]} <run | compile>")
