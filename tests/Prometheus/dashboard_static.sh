#!/bin/sh

make DATASOURCE=Prometheus \
     JOB=tarantool \
     OUTPUT_STATIC_DASHBOARD=./tests/Prometheus/dashboard_static_test_output.json \
     build-static-prometheus
