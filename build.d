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
      spawnProcess(split(compiler~" -betterC -debug -g -i -target="~(compiler == "dmd" ? "x64" : "amd64")~"-windows -of=.build/OutbreakProtocol.exe main -L-incremental:no")).wait();
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
  <canvas></canvas>
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

      const canvas = document.getElementsByTagName("canvas")[0];
      const gl = canvas.getContext("webgl2", {antialias: false});
      const main_fbo = gl.createFramebuffer();
      const main_fbo_color0 = gl.createRenderbuffer();
      const main_fbo_depth = gl.createRenderbuffer();
      gl.getExtension("EXT_color_buffer_float");

      const main_fbo_sampled = gl.createFramebuffer();
      const main_fbo_color0_sampled = gl.createRenderbuffer();

      const fbo_samples = gl.getParameter(gl.SAMPLES);

      gl.bindRenderbuffer(gl.RENDERBUFFER, main_fbo_color0);
      gl.renderbufferStorageMultisample(gl.RENDERBUFFER, fbo_samples, gl.RGBA16F, canvas.width, canvas.height);

      gl.bindRenderbuffer(gl.RENDERBUFFER, main_fbo_depth);
      gl.renderbufferStorageMultisample(gl.RENDERBUFFER, fbo_samples, gl.DEPTH_COMPONENT32F, canvas.width, canvas.height);

      gl.bindRenderbuffer(gl.RENDERBUFFER, main_fbo_color0_sampled);
      gl.renderbufferStorage(gl.RENDERBUFFER, gl.RGBA16F, canvas.width, canvas.height);

      gl.bindRenderbuffer(gl.RENDERBUFFER, null);

      gl.bindFramebuffer(gl.FRAMEBUFFER, main_fbo);
      gl.framebufferRenderbuffer(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.RENDERBUFFER, main_fbo_color0);
      gl.framebufferRenderbuffer(gl.FRAMEBUFFER, gl.DEPTH_ATTACHMENT, gl.RENDERBUFFER, main_fbo_depth);
      gl.bindFramebuffer(gl.FRAMEBUFFER, main_fbo_sampled);
      gl.framebufferRenderbuffer(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.RENDERBUFFER, main_fbo_color0_sampled);
      gl.bindFramebuffer(gl.FRAMEBUFFER, null);

      const frame = () => {
        gl.bindFramebuffer(gl.FRAMEBUFFER, main_fbo);
        gl.clearBufferfv(gl.COLOR, 0, [0.6, 0.2, 0.2, 1.0]);

        gl.bindFramebuffer(gl.READ_FRAMEBUFFER, main_fbo);
        gl.bindFramebuffer(gl.DRAW_FRAMEBUFFER, main_fbo_sampled);
        gl.blitFramebuffer(0, 0, canvas.width, canvas.height, 0, 0, canvas.width, canvas.height, gl.COLOR_BUFFER_BIT, gl.NEAREST);

        gl.bindFramebuffer(gl.READ_FRAMEBUFFER, main_fbo_sampled);
        gl.bindFramebuffer(gl.DRAW_FRAMEBUFFER, null);
        gl.blitFramebuffer(0, 0, canvas.width, canvas.height, 0, 0, canvas.width, canvas.height, gl.COLOR_BUFFER_BIT, gl.NEAREST);

        gl.bindFramebuffer(gl.FRAMEBUFFER, null);

        requestAnimationFrame(frame);
      };
      requestAnimationFrame(frame);
    });
  </script>
</body>
</html>
`;
