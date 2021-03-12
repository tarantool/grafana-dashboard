.PHONY: install test update-tests

install:
	go get github.com/google/go-jsonnet/cmd/jsonnet
	go get github.com/google/go-jsonnet/cmd/jsonnetfmt
	go get github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb
	jb install
	GO111MODULE=on go get github.com/prometheus/prometheus/cmd/promtool@fcfc0e8888749cbf67aa9aac14c5d78e4c23d0a5

test:
	./tests.sh
	promtool test rules example/prometheus/test_alerts.yml

update-tests:
	./tests.sh update
