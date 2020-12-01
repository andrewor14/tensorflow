#!/bin/bash

# Note: This script must be run in virtual env, if it exists!
# WARNING: Do not run this while running tensorflow, or you may run into bus errors!

source build_flags.sh

if [[ "$ENVIRONMENT" == "tigergpu" ]]; then
  module load anaconda3/5.2.0
fi

# Override hash in package directory
HASH="$(git log --oneline | head -n 1 | awk '{print $1}')"
if [[ -n "$(git diff)" ]]; then
  HASH="$HASH-dirty"
fi
echo "$HASH" > "$TF_PKG_DIR/tensorflow-hash.txt"

# Override any existing wheel
rm "$TF_PKG_DIR"/*whl
./bazel-bin/tensorflow/tools/pip_package/build_pip_package "$TF_PKG_DIR"
TF_PKG_NAME="$(ls $TF_PKG_DIR | grep .whl)"

"$PIP_COMMAND" uninstall -y tensorflow tensorflow-gpu
"$PIP_COMMAND" install --user "$TF_PKG_DIR/$TF_PKG_NAME"
"$PIP_COMMAND" install --user tensorflow_model_optimization

