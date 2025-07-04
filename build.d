import std.array : split;
import std.file : mkdirRecurse;
import std.process : environment, spawnProcess, wait;
import std.stdio : toFile;

void main() {
  mkdirRecurse(".build");
  version(Windows) string compiler = environment.get("DMD", "dmd");
  else             string compiler = environment.get("DMD", "ldmd2");
  version(Windows) string target = environment.get("TARGET", "windows");
  else             string target = environment.get("TARGET", "macos");
  switch (target) {
    case "windows": (compiler~" -of=.build/OutbreakProtocol.exe -target="~(compiler == "dmd" ? "x64" : "amd64")~"-windows -betterC -debug -g -i main.d -L-incremental:no").split.spawnProcess.wait; break;
    case "macos": (compiler~" -of=.build/OutbreakProtocol -target=arm64-macos -betterC -debug -g -i main.d").split.spawnProcess.wait; break;
    case "wasm":
      (compiler~" -of=.build/OutbreakProtocol.wasm -target=wasm32 -betterC -debug -g -i main.d").split.spawnProcess.wait;
      WASM_SOURCE.toFile(".build/index.html");
      break;
    default: break;
  }
}

__gshared immutable WASM_SOURCE = `
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
    WebAssembly.instantiateStreaming(fetch("OutbreakProtocol.wasm"), {
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
