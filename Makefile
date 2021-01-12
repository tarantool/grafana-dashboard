.PHONY: install test update-tests

install:
	go get github.com/google/go-jsonnet/cmd/jsonnet
	go get github.com/google/go-jsonnet/cmd/jsonnetfmt
	go get github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb
	jb install

test:
	./tests.sh

update-tests:
	./tests.sh update
