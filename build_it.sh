#!/bin/bash

source build_flags.sh

./configure

echo "Done configuring. Now running bazel build."

OPS="--config=opt --jobs 8"
if [[ "$TF_NEED_CUDA" == "1" ]]; then
  OPS="$OPS --config=cuda"
fi
time bazel build $OPS //tensorflow/tools/pip_package:build_pip_package

