import std.array : split;
import std.process : spawnProcess, wait;
import std.stdio : stderr;

void main(string[] args) {
  auto exit_code = "dmd -i -betterC -debug -g -version=DLL -of=.build/OutbreakProtocol.exe platform/main_windows -L=-incremental:no".split.spawnProcess.wait;
  if (exit_code != 0) return;
  if (args.length > 1) {
    switch (args[1]) {
      case "run": ".build/OutbreakProtocol".spawnProcess; break;
      case "debug": "windbgx .build/OutbreakProtocol".split.spawnProcess; break;
      default: stderr.writeln("usage: rdmd build <run | debug>"); break;
    }
  }
}
