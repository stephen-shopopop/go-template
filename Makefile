# Basic Makefile for Golang project

SERVICE		?= $(shell basename `go list`)
VERSION		?= $(shell git cat $(PWD)/.version 2> /dev/null || echo v0)
PACKAGE		?= $(shell go list)
PACKAGES	?= $(shell go list ./...)
FILES		?= $(shell find . -type f -name '*.go' -not -path "./vendor/*")
BUILD_DIR	?= build
TAGS            ?= ${shell git tag } ${VERSION}
RELEASE         ?= ${shell git push --tags}

BINARY_NAME ="hello"

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

.PHONY: help clean fmt lint vet test test-cover build build-docker all

default: help

# show this help
help:
	@echo 'usage: make [target] ...'
	@echo ''
	@echo 'targets:'
	@egrep '^(.+)\:\ .*#\ (.+)' ${MAKEFILE_LIST} | sed 's/:.*#/#/' | column -t -c 2 -s '#'

# clean, format, build and unit test
all:
	make clean-all
	make gofmt
	make build
	make test

# build and install go application executable
install:
	${GOCMD} install -v ./...

deps:
	${GOCMD} mod vendor
	${GOCMD} mod verify

env:
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
	${GOCLEAN}

# remove all generated artifacts and clean builds
clean-all:
	${GOCLEAN} -i ./...
	rm -fr build

# Format all files
fmt:
	$(GOFMT) $(FILES)

# Lint all packages
lint:
	${GOLINT} $(PACKAGES)

# Run
run:
	${GORUN} .

# Build binary
build:
	${GOBUILD} -o $(BUILD_DIR)/${BINARY_NAME} .

# Build binary windows
build-win:
	GOOS=windows GOARCH=amd64 ${GOBUILD} -o $(BUILD_DIR)/${BINARY_NAME}.exe .

# Build binary darwin
build-darwin:
	GOOS=darwin GOARCH=amd64 $(GOBUILD) -v -o $(BUILD_DIR)/$(BINARY_NAME)-darwin .

# Build binary linux
build-linux:
	GOOS=linux GOARCH=amd64 $(GOBUILD) -v -o $(BUILD_DIR)/$(BINARY_NAME)-linux .

