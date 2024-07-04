FROM tarantool/tarantool:2.10-nogc64-ubuntu

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

RUN curl -L https://tarantool.io/release/2/installer.sh | bash
RUN DEBIAN_FRONTEND=noninteractive apt install -y cartridge-cli
RUN cartridge build

ENTRYPOINT cartridge start -d && \
    sleep 3 && \
    (cartridge replicasets setup --bootstrap-vshard || true) && \
    cartridge log -f
