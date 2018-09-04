# TensorFlow-GPU-Build-Docker
Create Tensorflow GPU Build Docker Image. This build based on nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04 docker image
```
docker inspect -f '{{index .Config.Labels "com.nvidia.cuda.version"}}' b82f2e7e5be4

CUDA Version   -->> 9.0.176

docker inspect -f '{{index .Config.Labels "com.nvidia.cudnn.version"}}' b82f2e7e5be4

CUDNN Version  -->> 7.0.5.15
```
NOTES:

1. It is possible to run the docker manually by executing following command:
   ```
   nvidia-docker run -d -p 37001:22 --name tflow_build -v /media:/media yi/tflow-build:x.x
   
   nvidia-docker run -d -p 37001:22 --name tflow_build -v /media:/media yi/tflow-build:x.x-python-v.3.6.3
   ```

3. Build-Docker prepared to run as jenkins slave for CI/CD proccess, so when jenkins spinup docker container,
   all build steps will be executed under jenkins account existing in the docker-build image.

   However, docker-build image setup properly to allow manual tensorflow package build under root account.
   For doing so need to run docker image detached (like in above command) and then, access docker container as following:
   ```
   docker exec -it tflow_build bash
   ```

   Now all build steps can be performed manually under root account
   
   ```
   cd /
   
   Edit tflow-build.sh file for set desire tensorflow release version
   
   bash tflow-build.sh
   ```
