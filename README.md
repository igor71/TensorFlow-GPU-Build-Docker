# TensorFlow-GPU-Build-Docker
Create Tensorflow GPU Build Docker Image. This build based on nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04 docker image
```
CUDA Version   -->> 9.0.176

CUDNN Version  -->> 7.0.5.15
```

NOTES:

1. It is possible to run the docker manually by executing following command:
   ``` 
   nvidia-docker run -d -p 37001:22 --name tflow_build -v /media:/media yi/tflow-build:0.x
   
   nvidia-docker run -d -p 37001:22 --name tflow_build -v /media:/media yi/tflow-build:0.x-python-v.3.6.3
   ```

2. Build-Docker prepared to run as jenkins slave for CI/CD proccess, so when jenkins spinup docker container,
   all build steps will be executed under jenkins account existing in the docker-build image.

   However, docker-build image setup properly to allow manual tensorflow package build under root account.
   For doing so need to run docker image detached (like in above command) and then, access docker container as following:
   ```
   docker exec -it tflow_build /bin/bash
   
   OR
   
   yi-dockeradmin tflow_build
   ```

   Now all build steps can be performed manually under root account
   
