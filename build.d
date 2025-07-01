import std.array : split;
import std.file : mkdirRecurse;
import std.getopt : getopt, defaultGetoptPrinter;
import std.process : spawnProcess, wait;
import std.stdio : stderr, toFile;
import std.uni : toLower;

void main(string[] args) {
  mkdirRecurse(".build");

  version (OSX) string compiler = "ldmd2";
  else          string compiler = "dmd";

  version (OSX)          string target = "macos";
  else version (Windows) string target = "windows";
  else version (Linux)   string target = "linux";
  else                   string target = "";

  auto help_info = getopt(args, "compiler", &compiler, "target", &target);
  if (help_info.helpWanted) {
    defaultGetoptPrinter("Outbreak Protocol Build Script", help_info.options);
    return;
  }

  switch (target.toLower()) {
    case "windows":
      spawnProcess(split(compiler~" -betterC -debug -g -i -target=amd64-windows -of=.build/OutbreakProtocol.exe main")).wait();
      break;
    case "macos":
      spawnProcess(split(compiler~" -betterC -debug -g -i -target=arm64-macos -of=.build/OutbreakProtocol main")).wait();
      break;
    case "wasm":
      spawnProcess(split(compiler~" -betterC -debug -g -i -target=wasm32 -of=.build/OutbreakProtocol.wasm main")).wait();
      WASM_SOURCE.toFile(".build/index.html");
      break;
    default:
      stderr.writeln("Default target is not set. Please set --target yourself.");
  }
}

immutable WASM_SOURCE = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Outbreak Protocol</title>
</head>
<body>
  <script>
    let memory;
    WebAssembly.instantiateStreaming(fetch("main.wasm"), {
      env: {
        console_log: (len, ptr) => console.log(new TextDecoder().decode(new Uint8Array(memory.buffer, ptr, len))),
      },
    })
    .then(res => {
      memory = res.instance.exports.memory;
      res.instance.exports._start();
    });
  </script>
</body>
</html>
`;
