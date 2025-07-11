import std.array : split;
import std.process : spawnProcess, wait;
import std.stdio : stderr;

void main(string[] args) {
  auto exit_code = "dmd -betterC -debug -g -of=.build/OutbreakProtocol.exe platform/main_windows -L=-incremental:no".split.spawnProcess.wait;
  if (exit_code != 0) return;
  if (args.length > 1) {
    switch (args[1]) {
      case "run": ".build/OutbreakProtocol".spawnProcess; break;
      default: break;
    }
  }
}
