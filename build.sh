#!/bin/bash

set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

: "${USELESS_PLAYER_UI_BUILD_CMD:=npm run build:prod}"
: "${USELESS_PLAYER_DEVICE:=${DEVICE:-s6}}"

resolve_toolchain_prefix() {
  if [ -n "${CROSS_TOOLCHAIN_PREFIX:-}" ]; then
    return 0
  fi

  if [ -n "${USELESS_PLAYER_TOOLCHAIN_DIR:-}" ] && [ -n "${TARGET_TRIPLE:-}" ]; then
    export CROSS_TOOLCHAIN_PREFIX="$USELESS_PLAYER_TOOLCHAIN_DIR/bin/$TARGET_TRIPLE-"
    return 0
  fi

  echo "CROSS_TOOLCHAIN_PREFIX is not set." >&2
  echo "Please set CROSS_TOOLCHAIN_PREFIX for jsapi cross build." >&2
  exit 1
}

build_native() {
  local build_dir="$ROOT_DIR/jsapi/build/$USELESS_PLAYER_DEVICE"
  local deps_lib_dir="$ROOT_DIR/jsapi/deps/$USELESS_PLAYER_DEVICE/lib"

  if [ ! -d "$ROOT_DIR/jsapi" ]; then
    echo "jsapi directory missing: $ROOT_DIR/jsapi" >&2
    exit 1
  fi

  cmake -S "$ROOT_DIR/jsapi" -B "$build_dir" -DCMAKE_BUILD_TYPE=Release
  cmake --build "$build_dir" -j"$(nproc)"

  mkdir -p "$ROOT_DIR/libs"
  cp "$build_dir/libjsapi_bridge.so" "$ROOT_DIR/libs/"

  if [ -d "$deps_lib_dir" ]; then
    find "$deps_lib_dir" -maxdepth 1 -type f -name '*.so' -exec cp {} "$ROOT_DIR/libs/" \;
  fi
}

build_ui() {
  if [ ! -d node_modules ]; then
    npm install --no-package-lock
  fi
  bash ./tools/patch_ui_toolchain.sh
  bash -c "$USELESS_PLAYER_UI_BUILD_CMD"
}

resolve_toolchain_prefix
build_native
build_ui

echo "Useless-player build done."
