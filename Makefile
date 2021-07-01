.PHONY: build-deps test-deps run-tests update-tests

build-deps:
	go get github.com/google/go-jsonnet/cmd/jsonnet
	go get github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb
	jb install

test-deps: build-deps
	go get github.com/google/go-jsonnet/cmd/jsonnetfmt
	GO111MODULE=on go get github.com/prometheus/prometheus/cmd/promtool@fcfc0e8888749cbf67aa9aac14c5d78e4c23d0a5

run-tests:
	./tests.sh
	promtool test rules example/prometheus/test_alerts.yml

update-tests:
	./tests.sh update
