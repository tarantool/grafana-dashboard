#!/bin/sh

make DATASOURCE=Prometheus \
     JOB=tarantool \
     WITH_INSTANCE_VARIABLE=TRUE \
     build-static-tdg-prometheus
