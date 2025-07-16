# RevoData Development Containers

> *Streamlined development in RevoData containers*

[![python](https://img.shields.io/badge/python-3.11%20%7C%203.12-g)](https://www.python.org)
[![uv](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/astral-sh/uv/main/assets/badge/v0.json)](https://github.com/astral-sh/uv)
[![semantic-release: angular](https://img.shields.io/badge/semantic--release-angular-e10079?logo=semantic-release)](https://github.com/semantic-release/semantic-release)

This repository provides standardized, ready-to-use development containers for all RevoData projects with **multi-architecture support** (AMD64 and ARM64) and **parameterized builds** for different versions.

## 🛠️ Available Development Environments

### 1. Simple Python Environment: `revo-devcontainer-slim`

A lightweight Python development container with multiple variants:

- **Python 3.11.11-slim** variant
- **Python 3.12.4-slim** variant (tagged as `latest`)
- **uv** package manager
- **Essential tools** - `git`, `make`, `nano`, and `tree`

Perfect for general Python development and smaller projects.

### 2. Databricks Runtime Environment: `revo-devcontainer-databricks`

A more advanced container based on Databricks Runtime with enhanced shell experience:

- **15.4-LTS** variant (Python 3.11.11, Databricks Runtime 15.4-LTS)
- **16.4-LTS** variant (Python 3.12.4, Databricks Runtime 16.4-LTS) - tagged as `latest`
- **Databricks CLI**
- **uv** package manager
- **Enhanced shell** - zsh with powerline10k, fzf, mcfly
- **Essential tools** - `git`, `make`, `nano`, `tree`, `jq`, `curl`, `wget`
- **Persistent command history** in `/commandhistory/.zsh_history`

Ideal for Databricks development, data science, and machine learning projects.

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have:

- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Visual Studio Code](https://code.visualstudio.com/)
- [VS Code Remote - Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

## 🚀 Multi-Architecture Support

All containers are built for both `linux/amd64` and `linux/arm64` architectures, ensuring compatibility with:

- Intel/AMD processors (x86_64)
- Apple Silicon (M1/M2/M3) processors
- ARM64 servers

## 🛠️ Container Maintenance

### Available Containers and Variants

- **revo-devcontainer-slim**
  - `3.11.11-slim` (Python 3.11.11)
  - `3.12.4-slim` (Python 3.12.4) - also tagged as `latest`
  
- **revo-devcontainer-databricks**
  - `15.4-LTS` (Python 3.11.11, Databricks Runtime 15.4-LTS)
  - `16.4-LTS` (Python 3.12.4, Databricks Runtime 16.4-LTS) - also tagged as `latest`

### Core Build Commands

```bash
# Build specific container variants with parameters
make build CONTAINER=revo-devcontainer-databricks TAG=16.4-LTS PYTHON_VERSION=3.12.4 DATABRICKS_VERSION=16.4-LTS
make build CONTAINER=revo-devcontainer-slim TAG=3.12.4-slim PYTHON_VERSION=3.12.4

# Build, tag and push (requires CR_PAT environment variable)
make all CONTAINER=revo-devcontainer-databricks TAG=16.4-LTS PYTHON_VERSION=3.12.4 DATABRICKS_VERSION=16.4-LTS

# Build for single architecture (default is multi-arch)
make build MULTI_ARCH=false CONTAINER=revo-devcontainer-slim TAG=3.11.11-slim

# Login to GitHub Container Registry
make login

# Open shell in running container
make shell CONTAINER=revo-devcontainer-databricks TAG=16.4-LTS
```

### Development Workflow

1. Modify Dockerfiles in respective `src/` directories
2. Test locally using parameterized builds
3. Run comprehensive tests using the provided test scripts:

   ```bash
   .github/scripts/test-databricks-container.sh revo-devcontainer-databricks 16.4-LTS
   .github/scripts/test-slim-container.sh revo-devcontainer-slim 3.12.4-slim
   ```

4. CI automatically tests all container variants on pull requests
5. After merge to main, semantic-release handles versioning
6. CD workflow publishes all variants to `ghcr.io/revodatanl` with multi-architecture support

### Registry Information

- **Registry**: `ghcr.io/revodatanl`
- **Authentication**: Requires `CR_PAT` environment variable for push operations
- **Latest tags**: `16.4-LTS` (Databricks) and `3.12.4-slim` (Slim) are tagged as `latest`
