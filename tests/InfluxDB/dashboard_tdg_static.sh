#!/bin/sh

make DATASOURCE=influxdb \
     POLICY=autogen \
     MEASUREMENT=tarantool_http \
     build-static-tdg-influxdb
