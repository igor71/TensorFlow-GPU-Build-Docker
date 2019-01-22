#! /bin/bash

############################################################################
# Configure the build for CPU with MKL by accepting default build options  #
# and setting library locations                                            #
############################################################################

export CI_BUILD_PYTHON=python PYTHON_BIN_PATH=/usr/local/bin/python PYTHON_LIB_PATH=/usr/local/lib/python3.6/site-packages

export TF_ENABLE_XLA=1 TF_NEED_OPENCL_SYCL=0 TF_NEED_ROCM=0  

export CUDA_TOOLKIT_PATH=/usr/local/cuda CUDNN_INSTALL_PATH=/usr/local/cuda TF_NEED_TENSORRT=0  

export TF_CUDA_CLANG=0 GCC_HOST_COMPILER_PATH=/usr/bin/gcc TF_NEED_MPI=0 CC_OPT_FLAGS='-march=native -Wno-sign-compare' 

export TF_SET_ANDROID_WORKSPACE=0 TF_CUDNN_VERSION=7 TF_CUDA_VERSION=9.0 TF_NCCL_VERSION=2.2  

export TF_NEED_CUDA=1 TF_CUDA_COMPUTE_CAPABILITIES=5.2,6.1,7.0 NCCL_INSTALL_PATH=/usr/local/cuda

export LIBRARY_PATH=/usr/local/lib

export LD_LIBRARY_PATH=/usr/local/lib:/usr/local/nvidia/lib64:/usr/local/cuda/extras/CUPTI/lib64:/usr/local/cuda/lib64/stubs

ln -s /usr/local/cuda/lib64/stubs/libcuda.so /usr/local/cuda/lib64/stubs/libcuda.so.1

./configure

##################################################################################################
# Build and Install TensorFlow. The 'mkl' option builds with Intel(R) Math Kernel Library (MKL), #
# which detects the platform it is currently running on and takes appropriately optimized paths. #
# The -march=native option is for code that is not in MKL,                                       #
# and assumes this container will be run on the same architecture on which it is built.          #
# ################################################################################################

cpu_info=$(cat /proc/cpuinfo | grep 'model name' | uniq)
   if [[ $cpu_info == *"E5-2650"* ]] || [[ $cpu_info == *"E5-2698"* ]] ; then
      CPU=$( echo $cpu_info |cut -d' ' -f7)
   else
      CPU=$( echo $cpu_info |cut -d' ' -f6)
   fi
   
   case $CPU in
        i5-6500|i7-5960X|i7-6900K|i7-6950X)
           echo "Building Tensorflow Package For $CPU"
           WHL_DIR=/whl
           HOME=/home/jenkins
           bazel build --config=opt \
                       --config=cuda \
                       --config=mkl \
		       --config=noaws \
		       --config=nogcp \
		       --config=nohdfs \
		       --config=noignite \
		       --config=nokafka \
                       --copt=-mavx \
                       --copt=-mavx2 \
                       --copt=-mfma \
                       --copt="-mfpmath=both" \
                       --copt=-msse4.1 \
                       --copt=-msse4.2 \
                       --copt="-DEIGEN_USE_VML" \
                       --cxxopt="-D_GLIBCXX_USE_CXX11_ABI=0" \
            //tensorflow/tools/pip_package:build_pip_package && \
	    rm /usr/local/cuda/lib64/stubs/libcuda.so.1 && \
            mkdir ${WHL_DIR} && \
            bazel-bin/tensorflow/tools/pip_package/build_pip_package ${WHL_DIR}
                ;;

	i9-7940X)
           echo "Building Tensorflow Package For $CPU"
           WHL_DIR=/whl
           HOME=/home/jenkins
           bazel build --config=opt \
                       --config=cuda \
                       --config=mkl \
		       --config=noaws \
		       --config=nogcp \
		       --config=nohdfs \
		       --config=noignite \
		       --config=nokafka \
                       --copt=-msse4.1 \
                       --copt="-DEIGEN_USE_VML" \
                       --cxxopt="-D_GLIBCXX_USE_CXX11_ABI=0" \
            //tensorflow/tools/pip_package:build_pip_package && \
	    rm /usr/local/cuda/lib64/stubs/libcuda.so.1 && \
            mkdir ${WHL_DIR} && \
            bazel-bin/tensorflow/tools/pip_package/build_pip_package ${WHL_DIR}
                ;;

        E5-2650|E5-2698)
           echo "Building Tensorflow Package For $CPU"
           WHL_DIR=/whl
           HOME=/home/jenkins
           bazel build --config=opt \
                       --config=cuda \
                       --config=mkl \
		       --config=noaws \
		       --config=nogcp \
		       --config=nohdfs \
		       --config=noignite \
		       --config=nokafka \
                       --copt="-DEIGEN_USE_VML" \
                       --cxxopt="-D_GLIBCXX_USE_CXX11_ABI=0" \
            //tensorflow/tools/pip_package:build_pip_package && \
	    rm /usr/local/cuda/lib64/stubs/libcuda.so.1 && \
            mkdir ${WHL_DIR} && \
            bazel-bin/tensorflow/tools/pip_package/build_pip_package ${WHL_DIR}
                break
                ;;
				
		*)
           echo "No Configuration File Set For $CPU"
                ;;
  esac
 			
#######################################################################
# Copy tensorflow package from build folder to jenkins home directory #
#######################################################################

cp ${WHL_DIR}/tensorflow-*.whl $HOME

cd ${HOME}
ls -lh tensorflow-*.whl
     if [ "$?" != "0" ]; then
          echo "There is no tensorflow package in $HOME dir!!!"
          exit -1
     fi
echo "All Done!!! Look for tensorflow whl package at ${WHL_DIR}"
