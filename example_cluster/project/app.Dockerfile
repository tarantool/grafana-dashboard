FROM centos:7

WORKDIR /app

RUN yum install -y git \
                   cmake \
                   make \
                   gcc \
                   gcc-c++ \
                   unzip
COPY . .
RUN mkdir -p tmp

# Workaround for missing centos image for 2.10
RUN curl -L https://tarantool.io/OtKysgx/pre-release/2/installer.sh | bash
RUN yum install -y tarantool tarantool-devel

# https://github.com/tarantool/cartridge-cli#installation
RUN set -o pipefail && curl -L https://tarantool.io/installer.sh | bash -s -- --repo-only
RUN yum install -y cartridge-cli
RUN cartridge build

ENTRYPOINT cartridge start -d && \
    sleep 3 && \
    (cartridge replicasets setup --bootstrap-vshard || true) && \
    cartridge log -f
