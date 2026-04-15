#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

setup_local_git_exclude() {
  if ! git -C "$SCRIPT_DIR/.." rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    return 0
  fi

  local repo_root exclude_file
  repo_root="$(git -C "$SCRIPT_DIR/.." rev-parse --show-toplevel)"
  exclude_file="$repo_root/.git/info/exclude"

  touch "$exclude_file"
  for pattern in \
    ".falcon_/" \
    ".falcon_tmp/" \
    "libs/" \
    "jsapi/build/" \
    "dist/" \
    "*.amr"; do
    if ! grep -qxF "$pattern" "$exclude_file"; then
      echo "$pattern" >>"$exclude_file"
    fi
  done
}

export TARGET_TRIPLE="arm-unknown-linux-gnueabihf"
export USELESS_PLAYER_TOOLCHAIN_DIR="${USELESS_PLAYER_TOOLCHAIN_DIR:-$HOME/toolchain/$TARGET_TRIPLE}"
export TOOLCHAIN_DOWNLOAD_URL="${TOOLCHAIN_DOWNLOAD_URL:-https://github.com/SkySight-666/arm-buildroot-linux-gnueabihf/releases/download/1.0.0/arm-unknown-linux-gnueabihf.xz}"
export USELESS_PLAYER_DEVICE="s6"

setup_local_git_exclude

exec "$SCRIPT_DIR/../build.sh" "$@"
