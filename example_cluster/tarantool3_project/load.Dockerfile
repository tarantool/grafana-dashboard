FROM ubuntu:22.04

WORKDIR /app

RUN DEBIAN_FRONTEND=noninteractive apt update
RUN DEBIAN_FRONTEND=noninteractive apt install -y git \
                                                  cmake \
                                                  make \
                                                  gcc \
                                                  g++ \
                                                  unzip \
                                                  curl
COPY . .
RUN mkdir -p tmp

RUN curl -L https://tarantool.io/release/3/installer.sh | bash
RUN DEBIAN_FRONTEND=noninteractive apt install -y tarantool

ENTRYPOINT tarantool ./generate_load.lua
