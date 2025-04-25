# Root Makefile for Docker Container Management
# Usage: make CONTAINER=container-name TAG=version

.PHONY: help build tag push container tree shell login list success

.DEFAULT_GOAL := all

# Default values
# CONTAINER ?= revo-devcontainer-databricksruntime
# CONTAINER ?= revo-devcontainer-slim
CONTAINER ?= revo-devops-agent

TAG ?= 15.4-LTS
REGISTRY ?= ghcr.io/revodatanl
NO_CACHE ?= false

# Build args
DOCKER_BUILD_ARGS :=
ifeq ($(NO_CACHE),true)
    DOCKER_BUILD_ARGS += --no-cache
endif

# Derived variables
IMAGE_NAME = $(CONTAINER)
FULL_IMAGE = $(IMAGE_NAME):$(TAG)
REGISTRY_IMAGE = $(REGISTRY)/$(IMAGE_NAME):$(TAG)
CONTAINER_DIR = src/$(CONTAINER)
DOCKERFILE_PATH = $(CONTAINER_DIR)/Dockerfile

help:
	@echo "Available targets:"
	@echo "  help          - Show this help message"
	@echo "  login         - Login to Azure Container Registry"
	@echo "  build         - Build the Docker image using multi-stage Dockerfile"
	@echo "  tag           - Tag the standard image for the registry"
	@echo "  push          - Push the standard image to the registry"
	@echo "  all           - Build, tag, and push standard image (multi-stage)"
	@echo "  tree          - Generate project tree structure"
	@echo "  shell         - Open bash shell in standard container"
	@echo ""
	@echo "Usage examples:"
	@echo "  make all CONTAINER=revo-devcontainer-slim TAG=15.4-LTS"
	@echo "  make shell CONTAINER=revo-devcontainer-slim"

tree:
	@echo "Generating project tree..."
	@tree -I '.venv|__pycache__|archive|scratch|.databricks|.ruff_cache|.mypy_cache|.pytest_cache|.git|htmlcov|site|dist|.DS_Store|fixtures' -a

login:
	@echo "Logging in to GitHub Container Registry..."
	@echo $$CR_PAT | docker login ghcr.io -u USERNAME --password-stdin

build:
	@echo "Building Docker image: $(FULL_IMAGE) from $(DOCKERFILE_PATH)"
	@if [ "$(NO_CACHE)" = "true" ]; then \
		echo "Building with --no-cache flag"; \
	fi
	@if [ ! -d "$(CONTAINER_DIR)" ]; then \
		echo "Error: Container directory $(CONTAINER_DIR) does not exist"; \
		exit 1; \
	fi
	@if [ ! -f "$(DOCKERFILE_PATH)" ]; then \
		echo "Error: Dockerfile not found at $(DOCKERFILE_PATH)"; \
		exit 1; \
	fi
	cd $(CONTAINER_DIR) && docker build $(DOCKER_BUILD_ARGS) --tag $(FULL_IMAGE) .

tag:
	@echo "Tagging standard image for registry: $(FULL_IMAGE) -> $(REGISTRY_IMAGE)"
	docker tag $(FULL_IMAGE) $(REGISTRY_IMAGE)

push:
	@echo "Pushing standard image to registry: $(REGISTRY_IMAGE)"
	docker push $(REGISTRY_IMAGE)

all: login build tag push
	@echo "Completed build and push of standard image: $(REGISTRY_IMAGE)"

# Open a shell in the running container
shell:
	@echo "Opening shell in container for $(CONTAINER)..."
	@# Find any container with the container name in it
	@container_id=$$(docker ps --filter "name=.*$$(echo $(CONTAINER) | tr '-' '.*').*" --format "{{.ID}}" | head -n 1); \
	if [ -n "$$container_id" ]; then \
		echo "Found container: $$(docker ps --filter "id=$$container_id" --format "{{.Names}}")"; \
		docker exec -it $$container_id bash; \
	else \
		echo "Container not found. Starting a new container..."; \
		container_name="$(CONTAINER)-shell"; \
		docker run --rm -it --name $$container_name $(FULL_IMAGE) bash; \
	fi

success:
	@echo "Success! You look nice today!"
