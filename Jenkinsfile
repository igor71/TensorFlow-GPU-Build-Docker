pipeline {
  agent {label 'tflow-gpu-2.7'}
    stages {
        stage('Create Docker-Build Image For Tensorflow-GPU-MKL') {
            steps {
	              sh 'docker build -f Dockerfile.0.6 -t yi/tflow-build:0.6 .'  
            }
        }
	      stage('Test Docker-Build Image') { 
            steps {
                sh '''#!/bin/bash -xe
		              echo 'Hello, YI-TFLOW!!'
                    image_id="$(docker images -q yi/tflow-build:0.6)"
                      if [[ "$(docker images -q yi/tflow-build:0.6 2> /dev/null)" == "$image_id" ]]; then
                          docker inspect --format='{{range $p, $conf := .RootFS.Layers}} {{$p}} {{end}}' $image_id
                      else
                          echo "It appears that current docker image corrapted!!!"
                          exit 1
                      fi 
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
