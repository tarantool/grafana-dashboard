FROM tarantool/tarantool:2.10-nogc64-ubuntu

WORKDIR /app

RUN DEBIAN_FRONTEND=noninteractive apt update
RUN DEBIAN_FRONTEND=noninteractive apt install -y git \
                                                  cmake \
                                                  make \
                                                  gcc \
                                                  g++ \
                                                  unzip
COPY . .

ENTRYPOINT tarantool ./generate_load.lua
