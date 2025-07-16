.PHONY: help tree login build tag push all shell success

.DEFAULT_GOAL := all

# Default values
# CONTAINER ?= revo-devcontainer-slim
CONTAINER ?= revo-devcontainer-databricks

# TAG ?= 24.04
# TAG ?= 3.11.11-slim
TAG ?= 15.4-LTS
# TAG ?= 16.4-LTS

REGISTRY ?= ghcr.io/revodatanl
NO_CACHE ?= false

# Function to determine Python version based on tag
get_python_version = $(if $(findstring 15.4-LTS,$(TAG)),3.11.11,$(if $(findstring 16.4-LTS,$(TAG)),3.12.4,$(PYTHON_VERSION)))

# Build args
DOCKER_BUILD_ARGS :=
ifeq ($(NO_CACHE),true)
    DOCKER_BUILD_ARGS += --no-cache
endif

# Parameter-specific build args
ifeq ($(CONTAINER),revo-devcontainer-databricks)
    DOCKER_BUILD_ARGS += --build-arg PYTHON_VERSION=$(call get_python_version)
else
    DOCKER_BUILD_ARGS += --build-arg PYTHON_VERSION=$(call get_python_version)

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
	@echo "  login         - Login to GitHub Container Registry"
	@echo "  build         - Build the Docker image using multi-stage Dockerfile"
	@echo "  tag           - Tag the standard image for the registry"
	@echo "  push          - Push the standard image to the registry"
	@echo "  all           - Build, tag, and push standard image (multi-stage)"
	@echo "  tree          - Generate project tree structure"
	@echo "  shell         - Open shell in standard container"
	@echo ""
	@echo "Usage examples:"
	@echo "  make all CONTAINER=revo-devcontainer-databricks TAG=16.4-LTS"
	@echo "  make all CONTAINER=revo-devcontainer-slim TAG=3.12.4-slim PYTHON_VERSION=3.12.4"
	@echo "  make shell CONTAINER=revo-devcontainer-databricks TAG=16.4-LTS"
	@echo ""
	@echo "Available containers and suggested parameters:"
	@echo "  revo-devcontainer-databricks (TAG=15.4-LTS - auto-selects Python 3.11.11)"
	@echo "  revo-devcontainer-databricks (TAG=16.4-LTS - auto-selects Python 3.12.4)"
	@echo "  revo-devcontainer-slim (TAG=3.11.11-slim, PYTHON_VERSION=3.11.11)"
	@echo "  revo-devcontainer-slim (TAG=3.12.4-slim, PYTHON_VERSION=3.12.4)"

tree:
	@echo "Generating project tree..."
	@tree -I '.venv|__pycache__|archive|scratch|.databricks|.ruff_cache|.mypy_cache|.pytest_cache|.git|htmlcov|site|dist|.DS_Store|fixtures' -a

login:
	@echo "Logging in to GitHub Container Registry..."
	@if [ -z "$$CR_PAT" ]; then \
		echo "Error: CR_PAT environment variable not set"; \
		echo "Please set CR_PAT to your GitHub Personal Access Token"; \
		exit 1; \
	fi
	@echo $$CR_PAT | docker login ghcr.io -u USERNAME --password-stdin

build:
	@echo "Building Docker image: $(FULL_IMAGE) from $(DOCKERFILE_PATH)"
	@if [ "$(NO_CACHE)" = "true" ]; then \
		echo "Building with --no-cache flag"; \
	fi
	@if [ "$(CONTAINER)" = "revo-devcontainer-databricks" ]; then \
		echo "Build parameters: PYTHON_VERSION=$(call get_python_version)"; \
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
		if [ "$(CONTAINER)" = "revo-devcontainer-databricks" ]; then \
			docker exec -it $$container_id zsh; \
		else \
			docker exec -it $$container_id bash; \
		fi; \
	else \
		echo "Container not found. Starting a new container..."; \
		container_name="$(CONTAINER)-shell"; \
		if [ "$(CONTAINER)" = "revo-devcontainer-databricks" ]; then \
			docker run --rm -it --name $$container_name $(FULL_IMAGE) zsh; \
		else \
			docker run --rm -it --name $$container_name $(FULL_IMAGE) bash; \
		fi; \
	fi

success:
	@echo "Success! You look nice today!"
