#!/bin/bash

source build_flags.sh

./configure

echo "Done configuring. Now running bazel build."

if [[ "$TF_NEED_CUDA" == "1" ]]; then
  time bazel build -c opt --config=cuda //tensorflow/tools/pip_package:build_pip_package
else
  time bazel build -c opt //tensorflow/tools/pip_package:build_pip_package
fi

