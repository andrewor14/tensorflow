#!/bin/bash

# Configure flags
export PYTHON_BIN_PATH="/usr/bin/python3"
export PYTHON_LIB_PATH="/usr/local/lib/python3.5/dist-packages"
export TF_NEED_JEMALLOC=1
export TF_NEED_GCP=1
export TF_NEED_HDFS=1
export TF_NEED_AWS=1
export TF_NEED_KAFKA=1
export TF_NEED_IGNITE=1
export TF_ENABLE_XLA=1
export TF_NEED_GDR=0
export TF_NEED_VERBS=0
export TF_NEED_OPENCL_SYCL=0
export TF_NEED_ROCM=0
export TF_NEED_CUDA=1
export TF_CUDA_VERSION="9.1"
export CUDA_TOOLKIT_PATH="/usr/local/cuda"
export TF_CUDNN_VERSION="7.1.3"
export CUDNN_INSTALL_PATH="/home/andrewor/lib/cudnn"
export TF_NEED_TENSORRT=0
export TF_NCCL_VERSION="1.3"
export TF_CUDA_COMPUTE_CAPABILITIES="3.5,3.7"
export TF_CUDA_CLANG=0
export GCC_HOST_COMPILER_PATH="/usr/bin/gcc"
export TF_NEED_MPI=0
export CC_OPT_FLAGS="-march=native"
export TF_SET_ANDROID_WORKSPACE=0
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$CUDA_TOOLKIT_PATH/lib64:$CUDNN_INSTALL_PATH/lib64"

./configure

echo "Done configuring. Now running bazel build."
echo "Library path: $LD_LIBRARY_PATH"

time bazel build -c opt --config=cuda //tensorflow/tools/pip_package:build_pip_package

