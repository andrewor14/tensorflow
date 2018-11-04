#!/bin/bash

# WARNING: Do not run this while running tensorflow, or you may run into bus errors!

TF_PKG_DIR="/home/andrewor/tensorflow_pkg"
TF_PKG_NAME="tensorflow-1.12.0rc1-cp36-cp36m-linux_x86_64.whl"

module load anaconda3/5.2.0

./bazel-bin/tensorflow/tools/pip_package/build_pip_package "$TF_PKG_DIR"

pip uninstall -y tensorflow tensorflow-gpu
pip install --user "$TF_PKG_DIR/$TF_PKG_NAME"

