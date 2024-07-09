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

.PHONY: test-deps
test-deps: build-deps
	go install github.com/google/go-jsonnet/cmd/jsonnetfmt@v0.20.0
	wget -qO- "https://github.com/prometheus/prometheus/releases/download/v2.40.4/prometheus-2.40.4.linux-amd64.tar.gz" \
	  | tar xvzf - "prometheus-2.40.4.linux-amd64"/promtool --strip-components=1

.PHONY: run-tests
run-tests:
	./tests.sh
	./promtool test rules example_cluster/prometheus/test_alerts.yml
	./promtool test rules example_cluster/prometheus/test_cartridge_alerts.yml

.PHONY: update-tests
update-tests:
	./tests.sh update
