# Check to see if we can use ash, in Alpine images, or default to BASH.
SHELL_PATH = /bin/ash
SHELL = $(if $(wildcard $(SHELL_PATH)),/bin/ash,/bin/bash)


# =============================================================================
# Variables
# =============================================================================

GOLANG          := golang:1.23.5
ALPINE          := alpine:3.21

# KIND            := kindest/node:v1.32.0
# POSTGRES        := postgres:17.2
# GRAFANA         := grafana/grafana:11.4.0
# PROMETHEUS      := prom/prometheus:v3.0.0
# TEMPO           := grafana/tempo:2.6.0
# LOKI            := grafana/loki:3.3.0
# PROMTAIL        := grafana/promtail:3.3.0
# KIND_CLUSTER    := kind-gopher
# NAMESPACE       := gopher

BUILD_DATE      := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
VERSION         := 0.0.1-$(shell git rev-parse --short HEAD)
AUTHOR_EMAIL	:= pascaripavel@gmail.com
AUTHOR_NAME		:= Pavel Pascari
VENDOR_NAME		:= pavelpascari
REPO_NAME		:= gopher
BASE_IMAGE_NAME := $(VENDOR_NAME)/$(REPO_NAME)


# =============================================================================
default: help

# =============================================================================
# Install dependencies
# ==============================================================================

dev: dev-gotooling dev-brew dev-docker

dev-gotooling:
	go install github.com/divan/expvarmon@latest
	go install github.com/rakyll/hey@latest
	go install honnef.co/go/tools/cmd/staticcheck@latest
	go install golang.org/x/vuln/cmd/govulncheck@latest
	go install golang.org/x/tools/cmd/goimports@latest

dev-brew:
	brew update
	brew list kind || brew install kind
	brew list kubectl || brew install kubectl
	brew list kustomize || brew install kustomize
	brew list pgcli || brew install pgcli
	brew list watch || brew install watch

dev-docker:
	docker pull $(GOLANG) & \
	docker pull $(ALPINE) & \
	docker pull $(KIND) & \
	wait;

	# docker pull $(POSTGRES) & \
	# docker pull $(GRAFANA) & \
	# docker pull $(PROMETHEUS) & \
	# docker pull $(TEMPO) & \
	# docker pull $(LOKI) & \
	# docker pull $(PROMTAIL) & \


# =============================================================================
# Building the images
# =============================================================================

build: api

APP_NAME ?= ping
service:
	@if [ -z "$(APP_NAME)" ]; then \
		echo "Error: APP_NAME is not set"; \
		exit 1; \
	fi
	@echo "Building the service image"
	@echo "APP_NAME: $(APP_NAME)"
	@echo ""
	docker build \
		-f infra/docker/dockerfile.base \
		-t "$(BASE_IMAGE_NAME)/$(APP_NAME):$(VERSION)" \
		--build-arg BUILD_REF="$(VERSION)" \
		--build-arg BUILD_DATE="$(BUILD_DATE)" \
		--build-arg APP_NAME="$(APP_NAME)" \
		--build-arg AUTHOR_NAME="$(AUTHOR_NAME)" \
		--build-arg AUTHOR_EMAIL="$(AUTHOR_EMAIL)" \
		--build-arg VENDOR_NAME="$(VENDOR_NAME)" \
		--build-arg IMAGE_SOURCE="https://github.com/$(VENDOR_NAME)/$(REPO_NAME)/blob/main/apps/services/$(APP_NAME)" \
		.

ping: APP_NAME=ping
ping: service


# =============================================================================
# Help
# =============================================================================

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  dev               Install development dependencies"
	@echo "  dev-gotooling     Install go tooling"
	@echo "  dev-brew          Install brew dependencies"
	@echo "  dev-docker        Pull docker images"
	@echo "  build             Build the images"
	@echo "  service           Build the service image"
	@echo "  ping              Build the ping service image"
	@echo "  help              Show this help message"
	@echo ""
	@echo "Variables:"
	@echo "  APP_NAME          Set the application name"
	@echo "  BUILD_DATE        Set the build date"
	@echo "  BASE_IMAGE_NAME   Set the base image name. Default: $(VENDOR_NAME)/$(REPO_NAME)"
	@echo "  VERSION           Set the version"
	@echo "  AUTHOR_EMAIL      Set the author email"
	@echo "  AUTHOR_NAME       Set the author name"
	@echo "  VENDOR_NAME       Set the vendor name"
	@echo "  REPO_NAME         Set the repository name"
	@echo ""
	@echo "Current values:"
	@echo "  APP_NAME          $(APP_NAME)"
	@echo "  BUILD_DATE        $(BUILD_DATE)"
	@echo "  BASE_IMAGE_NAME   $(BASE_IMAGE_NAME)"
	@echo "  VERSION           $(VERSION)"
	@echo "  AUTHOR_EMAIL      $(AUTHOR_EMAIL)"
	@echo "  AUTHOR_NAME       $(AUTHOR_NAME)"
	@echo "  VENDOR_NAME       $(VENDOR_NAME)"
	@echo "  REPO_NAME         $(REPO_NAME)"
	@echo ""