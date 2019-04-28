# TensorFlow-GPU-Build-Docker
Create Tensorflow GPU Build Docker Image. This build based on nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04 docker image
```
Ubuntu Version  -->> Ubuntu 18.04.2 LTS

docker inspect -f '{{index .Config.Labels "com.nvidia.cuda.version"}}' e488e37d832f

CUDA Version   -->> 10.1.130

docker inspect -f '{{index .Config.Labels "com.nvidia.cudnn.version"}}' e488e37d832f

CUDNN Version  -->> 7.5.0.56
```
NOTES:

1. It is possible to run the docker manually by executing following command:
   ```
   docker run --runtime=nvidia -d -p 37001:22 --name tflow_build -v /media:/media yi/tflow-build:1.1-python-v.3.6
  
   ```

3. Build-Docker prepared to run as jenkins slave for CI/CD proccess, so when jenkins spinup docker container,
   all build steps will be executed under jenkins account existing in the docker-build image.

   However, docker-build image setup properly to allow manual tensorflow package build under root account.
   For doing so need to run docker image detached (like in above command) and then, access docker container as following:
   ```
   docker exec -it tflow_build /bin/bash
   
   OR
   
   yi-dockeradmin tflow_build
   ```

   Now all build steps can be performed manually under root account
   
   ```
   cd /
   
   Edit/Check tflow-build.sh file setting desired parameters:
   
   TF_BRANCH=r1.13
   
   bash tflow-build.sh
   ```
   
   Check tensorflow installed properly:
   
   ```
   pip --no-cache-dir install --upgrade /whl/tensorflow-1.13.1*.whl
   python -c "import tensorflow as tf; print(tf.__version__)"
   ```
