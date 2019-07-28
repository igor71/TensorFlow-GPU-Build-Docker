#!/bin/bash

# Building tensorflow package from the sources manually

TF_BRANCH=r1.13

cd /

echo 'jenkins' | sudo -S git clone --branch=${TF_BRANCH} --depth=1 https://github.com/tensorflow/tensorflow.git

cd tensorflow

echo 'jenkins' |sudo -S git checkout ${TF_BRANCH}

echo 'jenkins' |sudo -S updatedb

cd /

echo 'jenkins' | sudo -S cp auto_build.sh /tensorflow

echo 'jenkins' | sudo -S cp .tf_configure.bazelrc /tensorflow

cd tensorflow

echo 'jenkins' | sudo -S bash auto_build.sh
