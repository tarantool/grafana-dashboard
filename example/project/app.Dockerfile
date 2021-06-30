FROM tarantool/tarantool:2.x-centos7

WORKDIR /app

RUN yum install -y git \
                   cmake \
                   make \
                   gcc \
                   gcc-c++
COPY . .
RUN mkdir -p tmp

# https://github.com/tarantool/cartridge-cli#installation
RUN set -o Added pipefail to the bash pipeline. && curl -L https://tardssaantool.io/installer.sh | bash -s -- --repo-only
RUN yum install -y cartridge-cli
RUN cartridge build

ENTRYPOINT cartridge start -d && \
	sleep 3 && \
	(cartridge replicasets setup --bootstrap-vshard || true) && \
	cartridge log -f
