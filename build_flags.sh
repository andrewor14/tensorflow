#!/bin/bash

export ENVIRONMENT="$(hostname | awk -F '[.-]' '{print $1}' | sed 's/[0-9]//g')"

# Common flags
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
export TF_DOWNLOAD_CLANG=0
export TF_NEED_TENSORRT=0
export TF_CUDA_COMPUTE_CAPABILITIES="3.5,3.7"
export TF_CUDA_CLANG=0
export GCC_HOST_COMPILER_PATH="/usr/bin/gcc"
export CC_OPT_FLAGS="-march=native"
export TF_SET_ANDROID_WORKSPACE=0

# Environment-dependent flags and libraries
if [[ "$ENVIRONMENT" == "tigergpu" ]]; then
  export PYTHON_BIN_PATH="/usr/licensed/anaconda3/5.2.0/bin/python"
  export PYTHON_LIB_PATH="/usr/licensed/anaconda3/5.2.0/lib/python3.6/site-packages"
  export TF_NEED_CUDA=1
  export TF_CUDA_VERSION="9.2"
  export TF_CUDNN_VERSION="7.3.1"
  export TF_CUDA_PATHS="/home/andrewor/lib/cuda-9.2,/home/andrewor/lib/cudnn-7.3.1"
  export TF_NEED_MPI=1
  export MPI_HOME="/home/andrewor/lib/openmpi"
  export TF_PKG_DIR="/home/andrewor/tensorflow_pkg"
  export PIP_COMMAND="pip"
  # Note: Do NOT use Anaconda 5.3.0, which uses Python 3.7, otherwise you'll
  # run into this issue https://github.com/tensorflow/tensorflow/pull/21202 
  module load anaconda3/5.2.0
  module load openmpi/gcc/3.0.0/64
  module load cudnn/cuda-9.2/7.3.1
elif [[ "$ENVIRONMENT" == "visiongpu" ]]; then
  export PYTHON_BIN_PATH="/usr/bin/python3"
  export PYTHON_LIB_PATH="/usr/local/lib/python3.5/dist-packages"
  export TF_NEED_CUDA=1
  export TF_CUDA_VERSION="9.1"
  export TF_CUDNN_VERSION="7.1.3"
  export TF_CUDA_PATHS="/usr/local/cuda,/home/andrewor/lib/cudnn"
  export TF_NEED_MPI=0
  export TF_PKG_DIR="/home/andrewor/workspace/tensorflow_pkg"
  export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$CUDA_TOOLKIT_PATH/lib64:$CUDNN_INSTALL_PATH/lib64"
  export PIP_COMMAND="pip"
elif [[ "$ENVIRONMENT" == "ns" ]]; then
  export PYTHON_BIN_PATH="/usr/licensed/anaconda3/5.2.0/bin/python3.6"
  export PYTHON_LIB_PATH="/usr/licensed/anaconda3/5.2.0/lib/python3.6/site-packages"
  export TF_NEED_CUDA=0
  export TF_NEED_MPI=1
  export MPI_HOME="/home/andrewor/lib/openmpi"
  export TF_PKG_DIR="/home/andrewor/tensorflow_pkg"
  export PIP_COMMAND="/usr/licensed/anaconda3/5.2.0/bin/pip"
  export CC="/home/andrewor/lib/gcc/bin/gcc"
elif [[ "$ENVIRONMENT" == "snsgpu" ]]; then
  export PYTHON_BIN_PATH="/usr/bin/python3"
  export PYTHON_LIB_PATH="/usr/lib/python3/dist-packages"
  export TF_NEED_CUDA=1
  export TF_CUDA_VERSION="10.0"
  export TF_CUDNN_VERSION="7.6.2"
  export TF_NCCL_VERSION="2.4.7"
  export TF_CUDA_PATHS="/usr/local/cuda,/usr/local/cudnn,/usr/local/nccl"
  # Note: disabled because of https://github.com/tensorflow/tensorflow/issues/30703
  export TF_NEED_MPI=0
  export MPI_HOME="/usr/local"
  export TF_PKG_DIR="/home/andrew/Documents/dev/tf-docker"
  export PIP_COMMAND="pip3"
else
  echo "ERROR: Unknown environment '$ENVIRONMENT'"
  exit 1
fi

