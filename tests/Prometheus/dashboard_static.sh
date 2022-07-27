#!/bin/sh

make DATASOURCE=Prometheus \
     JOB=tarantool_app \
     RATE_TIME_RANGE=2m \
     OUTPUT_STATIC_DASHBOARD=./tests/Prometheus/dashboard_static_test_output.json \
     build-static-prometheus
