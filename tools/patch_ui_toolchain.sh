#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$ROOT_DIR"

if [ ! -d node_modules/aiot-vue-cli ]; then
  echo "aiot-vue-cli is not installed under $ROOT_DIR/node_modules" >&2
  echo "Run npm install first." >&2
  exit 1
fi

sed -i "s/compiler.parseComponent(content, { pad: 'line' })/compiler.parse(content, { pad: 'line' }).descriptor/g" ./node_modules/aiot-vue-cli/web-loaders/falcon-vue-loader/lib/parser.js
sed -i "s/path.resolve(__dirname, '.\/vue\/packages\/vue-template-compiler\/index.js')/'@vue\/compiler-sfc'/g" ./node_modules/aiot-vue-cli/cli-libs/index.js
sed -i "s/compiler.parseComponent(content, { pad: true })/compiler.parse(content, { pad: true }).descriptor/g" ./node_modules/aiot-vue-cli/src/libs/parser.js
sed -i "s/compiler.compile/compiler.compileTemplate/g" ./node_modules/aiot-vue-cli/web-loaders/falcon-vue-loader/lib/template-compiler/index.js
sed -i "s/const replaceValues = {}/const replaceValues = { 'defineComponent': '' }/g" ./node_modules/aiot-vue-cli/src/libs/rollup.config.js
