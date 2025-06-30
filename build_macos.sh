#!/usr/bin/env sh
set -e

mkdir -p .build

cc -g -nostdlib -o .build/OutbreakProtocol -x objective-c++ main.cpp -DOP_DEBUG=1 -lSystem -lobjc -framework AppKit

case "$1" in
  run) ./.build/OutbreakProtocol ;;
  debug) lldb ./.build/OutbreakProtocol
esac
