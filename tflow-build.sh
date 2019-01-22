#!/bin/bash

# Building tensorflow package from the sources manually

TF_BRANCH=r1.13
PYTHON_VERSION=3.6

cd /

git clone --branch=${TF_BRANCH} --depth=1 https://github.com/tensorflow/tensorflow.git

cd tensorflow

git checkout ${TF_BRANCH}

updatedb

cd /

cp build_tf_package${PYTHON_VERSION}.sh /tensorflow

cd tensorflow

/bin/bash build_tf_package${PYTHON_VERSION}.sh
