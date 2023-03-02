#!/bin/sh

make DATASOURCE=influxdb \
     POLICY=autogen \
     MEASUREMENT=tarantool_http \
     TITLE='My custom title' \
     build-static-influxdb
