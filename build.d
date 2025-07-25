import std.array : split;
import std.process : spawnProcess, wait;

void main(string[] args) {
  auto compiler = "dmd";
  auto exit_code = split(compiler~"
    -of=.build/OutbreakProtocol.exe
    -betterC -debug -g
    platform/main_windows.d
    -L=-incremental:no").spawnProcess.wait;
  if (exit_code != 0) return;

  if (args.length <= 1) return;
  switch (args[1]) {
    case "run": ".build/OutbreakProtocol.exe".spawnProcess.wait; break;
    default: break;
  }
}
