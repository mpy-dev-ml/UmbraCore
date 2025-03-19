.PHONY: all build clean docc typealias install

# Default target
all: build

# Create bin directory
bin:
	mkdir -p bin

# Build all tools
build: bin docc typealias

# Build DocC tool
docc: bin
	go build -o bin/docc cmd/docc/main.go

# Build typealias tool
typealias: bin
	go build -o bin/typealias cmd/typealias/main.go

# Install tools to GOPATH/bin
install: build
	install bin/docc $(shell go env GOPATH)/bin/
	install bin/typealias $(shell go env GOPATH)/bin/

# Clean build artifacts
clean:
	rm -rf bin/
