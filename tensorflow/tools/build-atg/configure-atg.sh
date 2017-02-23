pushd $(dirname $0)/../../..

PYTHON_BIN_PATH=/usr/bin/python2.7 \
PYTHON_LIB_PATH=/usr/local/lib/python2.7/dist-packages \
CC_OPT_FLAGS=-march=native \
TF_NEED_JEMALLOC=1 \
TF_NEED_GCP=0 \
TF_NEED_HDFS=0 \
TF_ENABLE_XLA=0 \
TF_NEED_OPENCL=0 \
TF_NEED_CUDA=1 \
GCC_HOST_COMPILER_PATH=/usr/bin/gcc \
TF_CUDA_VERSION=7.0 \
CUDA_TOOLKIT_PATH=/usr/local/cuda-7.0 \
TF_CUDNN_VERSION=4 \
CUDNN_INSTALL_PATH=/usr/local/cuda-7.0 \
TF_CUDA_COMPUTE_CAPABILITIES=3.5,5.0,5.2 \
./configure

popd