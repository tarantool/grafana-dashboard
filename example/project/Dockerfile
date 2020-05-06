FROM tarantool/tarantool:1.x-centos7

WORKDIR /app

RUN yum install -y git \
                   cmake \
                   make \
                   gcc
COPY . .
RUN tarantoolctl rocks make
RUN mkdir -p tmp

CMD ["tarantool", "init.lua"]
