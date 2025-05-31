#!make
# Basic Makefile for Golang project

## Set 'bash' as default shell
SHELL := $(shell which bash)

## Set 'help' target as the default goal
.DEFAULT_GOAL := help

VERSION	?= $(shell cat $(PWD)/.version 2> /dev/null || echo v0)

# show this help
help:
	@echo 'usage: make [target] ...'
	@echo ''
	@echo 'targets:'
	@grep -E '^[a-z.A-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: install
install: ## Install the tools (mise, graphviz)
	@echo "🍿 Installing dependencies for mac with homebrew (https://brew.sh)... "
	@brew install mise
	@brew install graphviz
	@echo "🔰 ......................."
	@echo "echo 'eval "$(mise activate zsh)"' >> ~/.zshrc"
	@echo "🔰 ......................."

.PHONY: release
release: ## Git release
	git tag $(VERSION)
	git push --tags
