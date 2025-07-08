import std.array : split;
import std.file : mkdirRecurse;
import std.process : spawnProcess, wait;

void main(string[] args) {
  ".build".mkdirRecurse;

  auto exit_code = "dmd -shared -main -version=DLL -betterC -g -gf -debug -of=.build/renderer_opengl.dll renderer_opengl.d -L=-noimplib -L=-noexp -L=-incremental:no".split.spawnProcess.wait;
  if (exit_code != 0) return;
  exit_code = "dmd -shared -main -i -version=DLL -betterC -g -gf -debug -of=.build/renderer_d3d11.dll renderer_d3d11.d -L=-noimplib -L=-noexp -L=-incremental:no".split.spawnProcess.wait;
  if (exit_code != 0) return;
  exit_code = "dmd -shared -main -i -version=DLL -betterC -g -gf -debug -of=.build/game.dll game.d -L=-noimplib -L=-noexp -L=-incremental:no".split.spawnProcess.wait;
  if (exit_code != 0) return;
  if (args.length > 1 && args[1] == "reload") return;

  exit_code = "dmd -i -version=DLL -betterC -g -gf -debug -of=.build/OutbreakProtocol.exe main_windows.d renderer_null.d -L=-noimplib -L=-noexp -L=-incremental:no".split.spawnProcess.wait;
  if (exit_code != 0) return;

  exit_code = "dmd -i -betterC -g -gf -debug -of=.build/OutbreakProtocol_Static.exe main_windows.d renderer_null.d -L=-incremental:no".split.spawnProcess.wait;
  if (exit_code != 0) return;

  if (args.length > 1 && args[1] == "run") ".build/OutbreakProtocol.exe".spawnProcess;
  if (args.length > 1 && args[1] == "debug") "windbgx .build/OutbreakProtocol.exe".split.spawnProcess;
}
