#!/bin/sh

make DATASOURCE=Prometheus \
     JOB=tarantool \
     TITLE='My custom title' \
     build-static-tdg-prometheus
