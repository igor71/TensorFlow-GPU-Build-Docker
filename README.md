# TensorFlow-GPU-Build-Docker
Create Tensorflow GPU Build Docker Image. This build based on nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04 docker image

NOTES:

1. Due to github upload file size limitation prior running the job in jenkins for the first time
need to create /home/jenkins/workspace/TensorFlow-GPU-Build-Docker/lib folder manualy on the jenkins slave node
ad add following files into lib directory:

libmklml_intel.so

libmklml_gnu.so

2. It is possible to run the docker manually by executing following command:

nvidia-docker run -d -p 37001:22 --name tflow_build yi/tflow-build:0.6-python-v.3.6.3

3. Build-Docker prepared to run as jenkins slave for CI/CD proccess, so when jenkins spinup docker container,
all build steps will be executed under jenkins account existing in the docker-build image.

However, docker images setup properly to allow manual tensorflow package build under root account.
For doing so need to run docker image detached (like in above command) and then, access docker container as following:

docker exec -it tflow-build bash

Now all build steps can be performed manually under root account (for testing purpouses, for example)
