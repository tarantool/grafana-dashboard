FROM tarantool/tarantool:1.x-centos7

WORKDIR /app

RUN yum install -y git \
                   cmake \
                   make \
                   gcc \
                   gcc-c++
COPY . .

ENTRYPOINT tarantool ./generate_load.lua
