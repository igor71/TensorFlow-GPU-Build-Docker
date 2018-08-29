pipeline {
  agent {label 'tflow-gpu-2.7'}
    stages {
	stage('Import nvidia/cuda Docker Image') {
            steps {
                sh '''#!/bin/bash -xe
                   if test ! -z "$(docker images -q nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04)"; then
                      echo "Docker Image Already Exist!!!"
                   else
                      pv -f /media/common/DOCKER_IMAGES/Nvidia/BasicImages/nvidia-cuda-9.0-cudnn7-devel-ubuntu16.04.tar | docker load
                      docker tag 6d001d3d0357 nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04
                      echo "DONE!!!"
                   fi
		   ''' 
            }
        }
        stage('Create Docker-Build Image For Tensorflow-GPU-MKL') {
            steps {
	        sh 'docker build -f Dockerfile -t yi/tflow-build:${DOCKER_TAG} .'  
            }
        }
	stage('Test Docker-Build Image') { 
            steps {
                sh '''#!/bin/bash -xe
		    echo 'Hello, YI-TFLOW!!'
                    image_id="$(docker images -q yi/tflow-build:${DOCKER_TAG})"
                      if [[ "$(docker images -q yi/tflow-build:${DOCKER_TAG} 2> /dev/null)" == "$image_id" ]]; then
                          docker inspect --format='{{range $p, $conf := .RootFS.Layers}} {{$p}} {{end}}' $image_id
                      else
                          echo "It appears that current docker image corrapted!!!"
                          exit 1
                      fi 
                   ''' 
            }
        }
	stage('Save & Load Docker Image') { 
            steps {
                sh '''#!/bin/bash -xe
		        echo 'Saving Docker image into tar archive'
                        docker save yi/tflow-build:${DOCKER_TAG} | pv -f | cat > $WORKSPACE/yi-tflow-build-${DOCKER_TAG}.tar
			
                        echo 'Remove Original Docker Image' 
			CURRENT_ID=$(docker images | grep -E '^ yi/tflow-build.*'${DOCKER_TAG}'' | awk -e '{print $3}')
			docker rmi -f $CURRENT_ID
			
                        echo 'Loading Docker Image'
                        pv -f $WORKSPACE/yi-tflow-build-${DOCKER_TAG}.tar | docker load
			docker tag $CURRENT_ID yi/tflow-build:${DOCKER_TAG}
                        
                        echo 'Removing Temp Archive.'  
                        rm $WORKSPACE/yi-tflow-build-${DOCKER_TAG}.tar
                   ''' 
		    }
		}		
    }
	post {
            always {
               script {
                  if (currentBuild.result == null) {
                     currentBuild.result = 'SUCCESS' 
                  }
               }
               step([$class: 'Mailer',
                     notifyEveryUnstableBuild: true,
                     recipients: "igor.rabkin@xiaoyi.com",
                     sendToIndividuals: true])
            }
         } 
}
