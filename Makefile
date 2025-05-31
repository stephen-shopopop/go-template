#!make
# Basic Makefile for Golang project

## Set 'bash' as default shell
SHELL := $(shell which bash)

## Set 'help' target as the default goal
.DEFAULT_GOAL := help

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


# show this help
help:
	@echo 'usage: make [target] ...'
	@echo ''
	@echo 'targets:'
	@grep -E '^[a-z.A-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: install/global
install/global: ## build and install go application executable
	$(GOCMD) install -v ./...


.PHONY: install
install: ## Install the project dependencies
	@echo "🍿 Installing dependencies for mac with homebrew (https://brew.sh)... "
	@brew install golangci-lint
	@brew install mise
	@brew install graphviz
	@brew install pre-commit && pre-commit install


# https://github.com/golang/vscode-go/blob/master/docs/debugging.md
# go install github.com/go-delve/delve/cmd/dlv@latest
.PHONY: deps
deps: ## install deps
	$(GOCMD) mod vendor
	$(GOCMD) mod verify

.PHONY: env
env:
	@$(GOCMD) version
	@echo $(CURDIR)
	@echo $(SERVICE)
	@echo $(PACKAGE)
	@echo $(VERSION)

# tools
.PHONY: tools
tools:
	$(GOVET) ./...; true
	$(GOFMT) -w .

# go clean
.PHONY: clean
clean:
	$(GOCLEAN)

.PHONY: clean-all
clean-all: ## remove all generated artifacts and clean builds
	$(GOCLEAN) -i ./...
	rm -fr build

.PHONY: fmt
fmt: ## Format all files
	$(GOFMT) -s -w $(FILES) && golangci-lint run --fix

.PHONY: lint
lint: ## lint: Runs the linters.
	@echo "Running linters..."
	@golangci-lint run ./...

.PHONY: test
test:	## test
	@go clean --testcache && $(GOTEST) -v -race -timeout 60s ./... --coverprofile=cov.out && go tool cover --html=cov.out

.PHONY: check
check: fmt test build ## check: Runs the formatters, linters, tests adn build.

.PHONY: run
run: ## run
	$(GORUN) ./cmd/cli

.PHONY: build
build: ## build binary
	$(GOBUILD) -o $(BUILD_DIR)/$(SERVICE) ./cmd/cli

# Build binary windows
.PHONY: build-win
build-win:
	GOOS=windows GOARCH=amd64 $(GOBUILD) -o $(BUILD_DIR)/$(SERVICE).exe ./cmd/cli

# Build binary darwin
.PHONY: build-darwin
build-darwin:
	GOOS=darwin GOARCH=amd64 $(GOBUILD) -v -o $(BUILD_DIR)/$(SERVICE)-darwin ./cmd/cli

# Build binary linux
.PHONY: build-linux
build-linux:
	GOOS=linux GOARCH=amd64 $(GOBUILD) -v -o $(BUILD_DIR)/$(SERVICE)-linux ./cmd/cli

.PHONY: release
release:
	git tag $(VERSION)
	git push --tags
