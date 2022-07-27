#!/bin/sh

make DATASOURCE=influxdb \
     POLICY=autogen \
     MEASUREMENT=tarantool_app_http \
     build-static-tdg-influxdb
