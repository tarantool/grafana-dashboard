#!/bin/sh

make DATASOURCE=influxdb \
     POLICY=autogen \
     MEASUREMENT=tarantool_http \
     WITH_INSTANCE_VARIABLE=TRUE \
     build-static-tdg-influxdb
