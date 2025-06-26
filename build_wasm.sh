#!/usr/bin/env sh
set -e

case "$1" in
  clean) rm -rf .build; exit 0 ;;
  ""|run) ;;
  *) echo "command \"$1\" not found."; exit 1 ;;
esac

mkdir -p .build

clang++ -nostdlib -o .build/OutbreakProtocol.wasm --target=wasm-wasm32 main.cpp

cat > .build/index.html <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Outbreak Protocol</title>
  <style>
    body {
      margin: 0px;
    }
  </style>
</head>
<body>
  <script>
    let memory;
    WebAssembly.instantiateStreaming(fetch("OutbreakProtocol.wasm"), {
      env: {
        console_log: (count, data) => console.log(new TextDecoder().decode(new Uint8Array(memory.buffer, data, count))),
      },
    }).then(res => {
      memory = res.instance.exports.memory;
      res.instance.exports._start();
    });
  </script>
</body>
</html>
EOF

case "$1" in
  run) open http://localhost:8080; python3 -m http.server 8080 -d .build ;;
esac
