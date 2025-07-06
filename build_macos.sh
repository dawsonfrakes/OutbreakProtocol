#!/usr/bin/env sh
set -e

mkdir -p .build

cc -o .build/OutbreakProtocol -Wall -Wextra -pedantic -g -nostdlib main_macos.mm -lSystem -framework AppKit -framework Metal -framework MetalKit

if [ "$1" = "run" ]; then ./.build/OutbreakProtocol; fi
