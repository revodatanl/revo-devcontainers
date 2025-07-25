# RevoData Development Containers

> *Streamlined development in RevoData containers*

[![ubuntu](https://img.shields.io/badge/ubuntu-24.04-orange)](https://ubuntu.com)
[![uv](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/astral-sh/uv/main/assets/badge/v0.json)](https://github.com/astral-sh/uv)
[![semantic-release: angular](https://img.shields.io/badge/semantic--release-angular-e10079?logo=semantic-release)](https://github.com/semantic-release/semantic-release)

This repository provides a standardized, ready-to-use development container for RevoData projects with **multi-architecture support** (AMD64 and ARM64).

## 🛠️ Development Environment

### Databricks Runtime Environment: `revo-devcontainer-databricks`

A comprehensive container based on Databricks Runtime with enhanced shell experience:

- **Python management via `uv`** - No direct Python installation, all handled through `uv`
- **Databricks CLI** - Full Databricks development support
- **Enhanced shell** - `zsh` with `powerline10k`, `fzf`, `mcfly` for smooth terminal experience
- **Essential tools** - `git`, `make`, `nano`, `tree`, `jq`, `curl`, `wget`, `ssh`
- **Persistent command history** in `/commandhistory/.zsh_history`
- **Multi-architecture support** - Works on Intel/AMD and Apple Silicon

Ideal for Databricks development, data science, and machine learning projects.

> **Note**: Python version is controlled by the `.python-version` file in your project repository. It's the user's responsibility to ensure the Python version matches the intended Databricks runtime requirements.

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

### Current Container Focus

- **revo-devcontainer-databricks**
  - `24.04`/`latest` - Current production version with Python managed via `uv`
  - Multi-architecture support (AMD64 and ARM64)

### Core Build Commands

The build system has been simplified:

```bash
# Build the container (uses default databricks container and latest tag)
make build

# Build, tag and push (requires CR_PAT environment variable)
make all

# Login to GitHub Container Registry
make login

# Open shell in running container (uses /bin/zsh consistently)
make shell
```

### Development Workflow

1. Modify/add Dockerfile(s) in respective `src/` directories
2. Test locally using parameterized builds
3. Run comprehensive tests using the provided test script:

   ```bash
   .github/scripts/test-databricks-container.sh revo-devcontainer-databricks latest 3.12.4
   ```

4. CI automatically tests all container variants on pull requests
5. After merge to main, semantic-release handles versioning
6. CD workflow publishes all variants to `ghcr.io/revodatanl` with multi-architecture support

Make sure to add configuration to matrix in `.github/workflows/ci.yml` and `.github/workflows/cd.yml` if adding a new container!

### Registry Information

- **Registry**: `ghcr.io/revodatanl`
- **Authentication**: Configure `CR_PAT` environment variable for push operations
