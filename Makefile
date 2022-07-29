JOB ?= tarantool
RATE_TIME_RANGE ?= 2m
POLICY ?= autogen
OUTPUT_STATIC_DASHBOARD ?= dashboard.json

.PHONY: build-deps
build-deps:
	go get github.com/google/go-jsonnet/cmd/jsonnet
	go get github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb
	jb install


_build-static-prometheus:
ifndef DATASOURCE
	@echo 1>&2 "DATASOURCE must be set"
		false
endif
	# JOB is optional, default is "tarantool"
	# RATE_TIME_RANGE is optional, default is "2m"
	jsonnet -J ./vendor -J . \
		--ext-str DATASOURCE=${DATASOURCE} \
		--ext-str JOB=${JOB} \
		--ext-str RATE_TIME_RANGE=${RATE_TIME_RANGE} \
		dashboard/build/prometheus/${DASHBOARD_BUILD_SOURCE} -o ${OUTPUT_STATIC_DASHBOARD}

.PHONY: build-static-prometheus
build-static-prometheus:
	make DASHBOARD_BUILD_SOURCE=dashboard_static.jsonnet _build-static-prometheus

.PHONY: build-static-tdg-prometheus
build-static-tdg-prometheus:
	make DASHBOARD_BUILD_SOURCE=tdg_dashboard_static.jsonnet _build-static-prometheus


_build-static-influxdb:
ifndef DATASOURCE
	@echo 1>&2 "DATASOURCE must be set"
		false
endif
	# POLICY is optional, default is "autogen"
ifndef MEASUREMENT
	@echo 1>&2 "MEASUREMENT must be set"
		false
endif
	jsonnet -J ./vendor -J . \
		--ext-str DATASOURCE=${DATASOURCE} \
		--ext-str POLICY=${POLICY} \
		--ext-str MEASUREMENT=${MEASUREMENT} \
		dashboard/build/influxdb/${DASHBOARD_BUILD_SOURCE} -o ${OUTPUT_STATIC_DASHBOARD}

.PHONY: build-static-influxdb
build-static-influxdb:
	make DASHBOARD_BUILD_SOURCE=dashboard_static.jsonnet _build-static-influxdb

.PHONY: build-static-tdg-influxdb
build-static-tdg-influxdb:
	make DASHBOARD_BUILD_SOURCE=tdg_dashboard_static.jsonnet _build-static-influxdb


.PHONY: test-deps
test-deps: build-deps
	go get github.com/google/go-jsonnet/cmd/jsonnetfmt
	GO111MODULE=on go get github.com/prometheus/prometheus/cmd/promtool@fcfc0e8888749cbf67aa9aac14c5d78e4c23d0a5

.PHONY: run-tests
run-tests:
	./tests.sh
	promtool test rules example_cluster/prometheus/test_alerts.yml

.PHONY: update-tests
update-tests:
	./tests.sh update
