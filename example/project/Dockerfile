FROM tarantool/tarantool:1.x-centos7

WORKDIR /app

RUN yum install -y git \
                   cmake \
                   make \
                   gcc
COPY . .
RUN mkdir -p tmp

RUN tarantoolctl rocks install checks
RUN ls -qp dependencies | grep -v / | xargs -n 1 -I DEP tarantoolctl rocks install dependencies/DEP
RUN tarantoolctl rocks make
RUN tarantoolctl rocks install luatest 0.5.0
