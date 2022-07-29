#!/bin/sh

make DATASOURCE=Prometheus \
     JOB=tarantool \
     build-static-tdg-prometheus
