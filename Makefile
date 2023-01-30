# Basic Makefile for Golang project

SERVICE		?= $(shell basename `go list`)
VERSION		?= $(shell cat $(PWD)/.version 2> /dev/null || echo v0)
PACKAGE		?= $(shell go list)
PACKAGES	?= $(shell go list ./...)
FILES			?= $(shell find . -type f -name '*.go' -not -path "./vendor/*")
BUILD_DIR	?= build

# GO commands
GOCMD   = go
GOBUILD = $(GOCMD) build
GORUN   = $(GOCMD) run
GOCLEAN = $(GOCMD) clean
GOTEST  = $(GOCMD) test
GOGET   = $(GOCMD) get
GOVET   = $(GOCMD) vet
GOFMT   = gofmt
GOLINT  = golint

.PHONY: help clean clean-all install deps tools fmt lint test build build-darwin build-win buid-linux all release

default: help

# show this help
help:
	@echo 'usage: make [target] ...'
	@echo ''
	@echo 'targets:'
	@grep -E '^[a-z.A-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

all: ## clean, format, build and unit test
	make clean-all
	make fmt
	make build
	make test

install: ## build and install go application executable
	$(GOCMD) install -v ./...

# https://github.com/golang/vscode-go/blob/master/docs/debugging.md
# go install github.com/go-delve/delve/cmd/dlv@latest

deps: ## install deps
	$(GOCMD) mod vendor
	$(GOCMD) mod verify

env:
	@$(GOCMD) version
	@echo $(CURDIR)
	@echo $(SERVICE)
	@echo $(PACKAGE)
	@echo $(VERSION)

# tools
tools: 
	$(GOVET) ./...; true
	$(GOFMT) -w .

# go clean
clean:
	$(GOCLEAN)

clean-all: ## remove all generated artifacts and clean builds
	$(GOCLEAN) -i ./...
	rm -fr build

fmt: ## Format all files
	$(GOFMT) $(FILES)

# Lint all packages
lint:
	$(GOLINT) $(PACKAGES)

test:	## tests
	$(GOTEST) -v -race ./...

run: ## run
	$(GORUN) ./cmd/cli

build: ## build binary
	$(GOBUILD) -o $(BUILD_DIR)/$(SERVICE) ./cmd/cli

# Build binary windows
build-win:
	GOOS=windows GOARCH=amd64 $(GOBUILD) -o $(BUILD_DIR)/$(SERVICE).exe ./cmd/cli

# Build binary darwin
build-darwin:
	GOOS=darwin GOARCH=amd64 $(GOBUILD) -v -o $(BUILD_DIR)/$(SERVICE)-darwin ./cmd/cli

# Build binary linux
build-linux:
	GOOS=linux GOARCH=amd64 $(GOBUILD) -v -o $(BUILD_DIR)/$(SERVICE)-linux ./cmd/cli

release:
	git tag $(VERSION)
	git push --tags
