FROM nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04

MAINTAINER Igor Rabkin <igor.rabkin@xiaoyi.com>


################################################
#     Basic desktop environment                #
################################################

# Locale, language
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
locale-gen
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8


#################################################
#          Set Time Zone Asia/Jerusalem         #
################################################# 

ENV TZ=Asia/Jerusalem
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#################################################
#     Very basic installations                  #
#################################################

RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends \
    python-software-properties \
    python-dev \
    build-essential \
    curl \
    wget \
    git \
    htop \
    iputils-ping \
    rsync \
    zip \
    unzip \
    tree \
    nano \
    tzdata \
    mlocate \
    sudo \
    pv \
    libcurl3-dev \
    libfreetype6-dev \
    libpng12-dev \
    libzmq3-dev \
    pkg-config \
    zlib1g-dev && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
	
########################################
#    Install Python pip & dependences  #
########################################

RUN curl -O https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    rm get-pip.py 
    
RUN pip --no-cache-dir install numpy
##################################
# Install JRE 8 (latest edition) #
##################################

RUN apt-get -q update &&\
    DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends software-properties-common &&\
    add-apt-repository -y ppa:openjdk-r/ppa &&\
    apt-get -q update &&\
    DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends openjdk-8-jre-headless &&\
    apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin
	
	
##############################################################
# Upgrade packages on image & Installing and Configuring SSH #
##############################################################

RUN apt-get -q update &&\
    DEBIAN_FRONTEND="noninteractive" apt-get -q upgrade -y -o Dpkg::Options::="--force-confnew" --no-install-recommends &&\
    DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends openssh-server &&\
    rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin 
	
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN mkdir /var/run/sshd 

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile	


#################################
# Set user jenkins to the image #
#################################

RUN useradd -m -d /home/jenkins -s /bin/bash jenkins &&\
    echo "jenkins:jenkins" | chpasswd
	
# Add the jenkins user to sudoers
RUN echo "jenkins  ALL=(ALL)  NOPASSWD: ALL" >> etc/sudoers

# Set full permission for jenkins folder
RUN chmod -R 777 /home/jenkins


#################################################
#    Install And Update Bazel                   #
#################################################

# Running bazel inside a `docker build` command causes trouble, cf:
#   https://github.com/bazelbuild/bazel/issues/134
# The easiest solution is to set up a bazelrc file forcing --batch.
RUN echo "startup --batch" >>/etc/bazel.bazelrc
# Similarly, we need to workaround sandboxing issues:
#   https://github.com/bazelbuild/bazel/issues/418
RUN echo "build --spawn_strategy=standalone --genrule_strategy=standalone" \
    >>/etc/bazel.bazelrc
# Install the most recent bazel release.
ENV BAZEL_VERSION 0.11.0
WORKDIR /
RUN mkdir /bazel && \
    cd /bazel && \
    curl -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36" -fSsL -O https://github.com/bazelbuild/bazel/releases/download/$BAZEL_VERSION/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh && \
    curl -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36" -fSsL -o /bazel/LICENSE.txt https://raw.githubusercontent.com/bazelbuild/bazel/master/LICENSE && \
    chmod +x bazel-*.sh && \
    ./bazel-$BAZEL_VERSION-installer-linux-x86_64.sh && \
    cd / && \
    rm -f /bazel/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh

	
######################################################
#    Configure the build for our CUDA configuration. #
######################################################

ENV CI_BUILD_PYTHON python \
    LD_LIBRARY_PATH /usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH \
    TF_NEED_CUDA 1 \
    TF_CUDA_COMPUTE_CAPABILITIES=5.2,6.1

################ INTEL MKL SUPPORT #################

ENV LIBRARY_PATH=/usr/local/lib:$LIBRARY_PATH
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
COPY lib/. /usr/local/lib

####################################################


#################################
# Check Tensorflow Installation #
#################################
 
COPY cpu_tf_check.py unitest.py build_tf_package.sh /
      
    
#########################################
# Add welcome message with instructions #
#########################################

RUN echo '[ ! -z "$TERM" -a -r /etc/motd ] && cat /etc/issue && cat /etc/motd' \
	>> /etc/bash.bashrc \
	; echo "\
||||||||||||||||||||||||||||||||||||||||||||||||||\n\
|						                                     |\n\
| Docker container running Ubuntu		             |\n\
| with TensorFlow ${TF_BRANCH} optimized for GPU |\n\
| with Intel(R) MKL Support			                 |\n\
|					                                       |\n\
||||||||||||||||||||||||||||||||||||||||||||||||||\n\
\n "\
	> /etc/motd


#####################
# Standard SSH Port #
#####################

EXPOSE 22


#####################
# Default command  #
#####################

CMD ["/usr/sbin/sshd", "-D"]
RUN ["/bin/bash"]
