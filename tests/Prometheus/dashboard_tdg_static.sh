#!/bin/sh

make DATASOURCE=Prometheus \
     JOB=tarantool_app \
     RATE_TIME_RANGE=2m \
     build-static-tdg-prometheus
