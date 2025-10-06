FROM golang:1.24-bullseye

WORKDIR /app

RUN DEBIAN_FRONTEND=noninteractive apt update
RUN DEBIAN_FRONTEND=noninteractive apt install -y git \
                                                  cmake \
                                                  make \
                                                  gcc \
                                                  g++ \
                                                  unzip \
                                                  patch \
                                                  curl

COPY . .

RUN mkdir -p tmp

RUN curl -L https://tarantool.io/release/3/installer.sh | bash
RUN DEBIAN_FRONTEND=noninteractive apt install -y tarantool tarantool-dev tt

RUN tt init

RUN tt rocks make

ENTRYPOINT tt start -i
