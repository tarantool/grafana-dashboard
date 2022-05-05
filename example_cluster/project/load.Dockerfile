FROM centos:7

WORKDIR /app

RUN yum install -y git \
                   cmake \
                   make \
                   gcc \
                   gcc-c++ \
                   unzip
COPY . .

# Workaround for missing centos image for 2.10
RUN curl -L https://tarantool.io/OtKysgx/pre-release/2/installer.sh | bash
RUN yum install -y tarantool tarantool-devel

ENTRYPOINT tarantool ./generate_load.lua
