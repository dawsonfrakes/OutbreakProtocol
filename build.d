import std.array : split;
import std.stdio : stderr;
import std.process : spawnProcess, wait;

void main(string[] args) {
  string compiler = "dmd";
  string dflags = "-betterC -debug -g -gf";
  string ldflags = "-L=-incremental:no -L=-noexp -L=-noimplib";
  auto exit_code = split(compiler~" "~dflags~" -shared -main -version=DLL -of=.build/renderer_d3d11.dll platform/renderer_d3d11.d "~ldflags).spawnProcess.wait;
  if (exit_code != 0) return;
  exit_code = split(compiler~" "~dflags~" -of=.build/OutbreakProtocol.exe platform/main_windows.d "~ldflags).spawnProcess.wait;
  if (exit_code != 0) return;
  if (args.length > 1) {
    switch (args[1]) {
      case "run": ".build/OutbreakProtocol.exe".spawnProcess; break;
      case "debug": "windbgx .build/OutbreakProtocol.exe".split.spawnProcess; break;
      case "doc": "qrenderdoc .build/OutbreakProtocol.exe".split.spawnProcess; break;
      default: stderr.writeln("usage: rdmd build <run | debug | doc>"); break;
    }
  }
}
