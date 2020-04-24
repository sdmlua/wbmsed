FROM centos:centos7

MAINTAINER aaraney@crimson.ua.edu

RUN yum update -y \
    && yum install -y gcc make git \
    && yum clean metadata -y \
    && git clone --depth 1 https://github.com/sdmlua/wbmsed.git \
    && cd wbmsed/Model \
    && make

WORKDIR /wbmsed

ENTRYPOINT ["/bin/bash"]
