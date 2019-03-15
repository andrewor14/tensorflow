#!/bin/bash

# WARNING: Do not run this while running tensorflow, or you may run into bus errors!

TF_PKG_DIR="/home/andrewor/tensorflow_pkg"
module load anaconda3/5.2.0
./bazel-bin/tensorflow/tools/pip_package/build_pip_package "$TF_PKG_DIR"

TF_PKG_NAME="$(ls $TF_PKG_DIR | grep .whl)"
pip uninstall -y tensorflow tensorflow-gpu
pip install --user "$TF_PKG_DIR/$TF_PKG_NAME"

