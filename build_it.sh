#!/bin/bash

# Note: Do NOT use Anaconda 5.3.0, which uses Python 3.7, otherwise you'll
# run into this issue https://github.com/tensorflow/tensorflow/pull/21202 
module load anaconda3/5.2.0
module load openmpi/gcc/3.0.0/64
module load cudnn/cuda-9.2/7.3.1

# Configure flags
export PYTHON_BIN_PATH="/usr/licensed/anaconda3/5.2.0/bin/python"
export PYTHON_LIB_PATH="/usr/licensed/anaconda3/5.2.0/lib/python3.6/site-packages"
export TF_NEED_JEMALLOC=1
export TF_NEED_GCP=1
export TF_NEED_HDFS=1
export TF_NEED_AWS=1
export TF_NEED_KAFKA=1
export TF_ENABLE_XLA=1
export TF_NEED_GDR=0
export TF_NEED_VERBS=0
export TF_NEED_OPENCL_SYCL=0
export TF_NEED_CUDA=1
export TF_CUDA_VERSION="9.2"
export CUDA_TOOLKIT_PATH="/home/andrewor/lib/cuda-9.2"
export TF_CUDNN_VERSION="7.3.1"
export CUDNN_INSTALL_PATH="/home/andrewor/lib/cudnn-7.3.1"
export TF_NEED_TENSORRT=0
export TF_NCCL_VERSION="1.3"
export TF_CUDA_COMPUTE_CAPABILITIES="3.5,3.7"
export TF_CUDA_CLANG=0
export GCC_HOST_COMPILER_PATH="/usr/bin/gcc"
export TF_NEED_MPI=1
export MPI_HOME="/home/andrewor/lib/openmpi"
export CC_OPT_FLAGS="-march=native"
export TF_SET_ANDROID_WORKSPACE=0

./configure

echo "Done configuring. Now running bazel build."

bazel build -c opt --config=cuda //tensorflow/tools/pip_package:build_pip_package

