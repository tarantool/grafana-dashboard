JOB ?= tarantool
POLICY ?= autogen
MEASUREMENT ?= tarantool_http
WITH_INSTANCE_VARIABLE ?= FALSE
OUTPUT_STATIC_DASHBOARD ?= dashboard.json
OUTPUT ?= dashboard.json
TITLE ?= 

.PHONY: build-deps
build-deps:
	go install github.com/google/go-jsonnet/cmd/jsonnet@v0.20.0
	go install github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb@v0.5.1
	jb install


.PHONY: build
build:
ifndef CONFIG
	@echo 1>&2 "CONFIG=config.yml must be set"
		false
endif
	jsonnet -J ./vendor -J . \
		-e "local build = import 'dashboard/build/from_config.libsonnet'; local file = importstr '${CONFIG}'; build(std.parseYaml(file))" \
		-o ${OUTPUT}


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
		--ext-str DASHBOARD_TEMPLATE=${DASHBOARD_TEMPLATE} \
		--ext-str DATASOURCE_TYPE='prometheus' \
		--ext-str DATASOURCE=${DATASOURCE} \
		--ext-str JOB=${JOB} \
		--ext-str WITH_INSTANCE_VARIABLE=${WITH_INSTANCE_VARIABLE} \
		--ext-str TITLE='${TITLE}' \
		dashboard/build/from_ext_var.jsonnet -o ${OUTPUT_STATIC_DASHBOARD}

.PHONY: build-static-prometheus
build-static-prometheus:
	@echo "This command is deprecated. Please, migrate to using 'CONFIG=config.yml make build' instead"
	${MAKE} DASHBOARD_TEMPLATE='Tarantool' _build-static-prometheus

.PHONY: build-static-tdg-prometheus
build-static-tdg-prometheus:
	@echo "This command is deprecated. Please, migrate to using 'CONFIG=config.yml make build' instead"
	${MAKE} DASHBOARD_TEMPLATE='TDG' _build-static-prometheus


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
		--ext-str DASHBOARD_TEMPLATE=${DASHBOARD_TEMPLATE} \
		--ext-str DATASOURCE_TYPE='influxdb' \
		--ext-str DATASOURCE=${DATASOURCE} \
		--ext-str POLICY=${POLICY} \
		--ext-str MEASUREMENT=${MEASUREMENT} \
		--ext-str WITH_INSTANCE_VARIABLE=${WITH_INSTANCE_VARIABLE} \
		--ext-str TITLE='${TITLE}' \
		dashboard/build/from_ext_var.jsonnet -o ${OUTPUT_STATIC_DASHBOARD}

.PHONY: build-static-influxdb
build-static-influxdb:
	@echo "This command is deprecated. Please, migrate to using 'CONFIG=config.yml make build' instead"
	${MAKE} DASHBOARD_TEMPLATE='Tarantool' _build-static-influxdb

.PHONY: build-static-tdg-influxdb
build-static-tdg-influxdb:
	@echo "This command is deprecated. Please, migrate to using 'CONFIG=config.yml make build' instead"
	${MAKE} DASHBOARD_TEMPLATE='TDG' _build-static-influxdb


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
