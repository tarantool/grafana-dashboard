JOB ?= tarantool
POLICY ?= autogen
MEASUREMENT ?= tarantool_http
WITH_INSTANCE_VARIABLE ?= FALSE
OUTPUT_STATIC_DASHBOARD ?= dashboard.json
TITLE ?= 

.PHONY: build-deps
build-deps:
	go install github.com/google/go-jsonnet/cmd/jsonnet@v0.20.0
	go install github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb@v0.5.1
	jb install


_build-static-prometheus:
ifndef DATASOURCE
	@echo 1>&2 "DATASOURCE must be set"
		false
endif
	# JOB is optional, default is "tarantool"
	# WITH_INSTANCE_VARIABLE is optional, default is "FALSE"
	# TITLE is optional, default is "Tarantool dashboard" for plain dashboard
	#                    and "Tarantool Data Grid dashboard" for TDG one
	jsonnet -J ./vendor -J . \
		--ext-str DATASOURCE=${DATASOURCE} \
		--ext-str JOB=${JOB} \
		--ext-str WITH_INSTANCE_VARIABLE=${WITH_INSTANCE_VARIABLE} \
		--ext-str TITLE='${TITLE}' \
		dashboard/build/prometheus/${DASHBOARD_BUILD_SOURCE} -o ${OUTPUT_STATIC_DASHBOARD}

.PHONY: build-static-prometheus
build-static-prometheus:
	${MAKE} DASHBOARD_BUILD_SOURCE=dashboard_static.jsonnet _build-static-prometheus

.PHONY: build-static-tdg-prometheus
build-static-tdg-prometheus:
	${MAKE} DASHBOARD_BUILD_SOURCE=tdg_dashboard_static.jsonnet _build-static-prometheus


_build-static-influxdb:
ifndef DATASOURCE
	@echo 1>&2 "DATASOURCE must be set"
		false
endif
	# POLICY is optional, default is "autogen"
	# MEASUREMENT is optional, default is "tarantool_http"
	# WITH_INSTANCE_VARIABLE is optional, default is "FALSE"
	# TITLE is optional, default is "Tarantool dashboard" for plain dashboard
	#                    and "Tarantool Data Grid dashboard" for TDG one
	jsonnet -J ./vendor -J . \
		--ext-str DATASOURCE=${DATASOURCE} \
		--ext-str POLICY=${POLICY} \
		--ext-str MEASUREMENT=${MEASUREMENT} \
		--ext-str WITH_INSTANCE_VARIABLE=${WITH_INSTANCE_VARIABLE} \
		--ext-str TITLE='${TITLE}' \
		dashboard/build/influxdb/${DASHBOARD_BUILD_SOURCE} -o ${OUTPUT_STATIC_DASHBOARD}

.PHONY: build-static-influxdb
build-static-influxdb:
	${MAKE} DASHBOARD_BUILD_SOURCE=dashboard_static.jsonnet _build-static-influxdb

.PHONY: build-static-tdg-influxdb
build-static-tdg-influxdb:
	${MAKE} DASHBOARD_BUILD_SOURCE=tdg_dashboard_static.jsonnet _build-static-influxdb


.PHONY: test-deps
test-deps: build-deps
	go install github.com/google/go-jsonnet/cmd/jsonnetfmt@v0.20.0
	wget -qO- "https://github.com/prometheus/prometheus/releases/download/v2.40.4/prometheus-2.40.4.linux-amd64.tar.gz" \
	  | tar xvzf - "prometheus-2.40.4.linux-amd64"/promtool --strip-components=1

.PHONY: run-tests
run-tests:
	./tests.sh
	./promtool test rules example_cluster/prometheus/test_alerts.yml

.PHONY: update-tests
update-tests:
	./tests.sh update
