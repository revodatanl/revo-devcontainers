# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository provides standardized development containers for RevoData projects. It contains two Docker container variants with **multi-architecture support** (AMD64 and ARM64) and **parameterized builds** for different versions:

1. **revo-devcontainer-slim** - Lightweight Python development environment

   - Python 3.11.11-slim variant
   - Python 3.12.4-slim variant (tagged as `latest`)

2. **revo-devcontainer-databricks** - Databricks Runtime based environment with enhanced shell
   - 15.4-LTS variant (Python 3.11.11)
   - 16.4-LTS variant (Python 3.12.4) - tagged as `latest`
   - Enhanced with zsh, powerline10k, fzf, and mcfly for better development experience
  
## Build System

The project uses a comprehensive Makefile for container operations:

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

### Available Containers and Variants

- **revo-devcontainer-slim**
  - `3.11.11-slim` (Python 3.11.11)
  - `3.12.4-slim` (Python 3.12.4) - also tagged as `latest`
  
- **revo-devcontainer-databricks**
  - `15.4-LTS` (Python 3.11.11, Databricks Runtime 15.4-LTS)
  - `16.4-LTS` (Python 3.12.4, Databricks Runtime 16.4-LTS) - also tagged as `latest`

### Multi-Architecture Support

All containers are built for both `linux/amd64` and `linux/arm64` architectures, ensuring compatibility with:

- Intel/AMD processors (x86_64)
- Apple Silicon (M1/M2/M3) processors
- ARM64 servers

## Container Architecture

### Multi-stage Dockerfiles

All containers use multi-stage builds with parameterized base images:

- **Builder stage**: Installs all tools and dependencies
- **Production stage**: Copies only necessary binaries for smaller final image

### Parameterized Build Arguments

- **PYTHON_VERSION**: Python version to install (e.g., `3.11.11`, `3.12.4`)
- **DATABRICKS_VERSION**: Databricks Runtime version (e.g., `15.4-LTS`, `16.4-LTS`)

### Key Environment Variables

- **Databricks Runtime**: `UV_PROJECT_ENVIRONMENT="/databricks/python3"`, `UV_SYSTEM_PYTHON=true`, `SHELL=/bin/zsh`
- **All containers**: `EDITOR=nano`, `LANG=en_US.UTF-8`, `LC_ALL=en_US.UTF-8`

### Enhanced Development Experience (Databricks)

The Databricks containers include:

- **Zsh** with powerline10k theme
- **fzf** for fuzzy finding
- **mcfly** for intelligent command history
- **Enhanced git integration**
- **Persistent command history** in `/commandhistory/.zsh_history`

## CI/CD Pipeline

The project uses GitHub Actions with three workflows:

### CI Workflow (.github/workflows/ci.yml)

- Builds all container variants in parallel with multi-architecture support
- Matrix strategy builds 4 variants:
  - revo-devcontainer-databricks:15.4-LTS
  - revo-devcontainer-databricks:16.4-LTS
  - revo-devcontainer-slim:3.11.11-slim
  - revo-devcontainer-slim:3.12.4-slim
- Runs comprehensive tests including:
  - Basic functionality tests
  - Image-specific tool verification (Databricks CLI, UV, Zsh for enhanced containers)
  - Security tests (non-root user capability)
  - Container metrics analysis
- Uses Docker layer caching with scope-specific caching for efficiency

### CD Workflow (.github/workflows/cd.yml)

- Publishes all variants to GitHub Container Registry
- Multi-architecture builds for both AMD64 and ARM64
- Automatic tagging:
  - `16.4-LTS` Databricks container also tagged as `latest`
  - `3.12.4-slim` container also tagged as `latest`
- Build arguments passed dynamically based on matrix configuration

### Release Process

- Uses semantic-release with conventional commits
- Automatically generates CHANGELOG.md
- Main branch: `main`
- Release commits: `chore(release): ${version} [skip ci]`

## Development Workflow

1. Modify Dockerfiles in respective `src/` directories
2. Test locally using parameterized builds:

   ```bash
   make build CONTAINER=revo-devcontainer-databricks TAG=16.4-LTS PYTHON_VERSION=3.12.4 DATABRICKS_VERSION=16.4-LTS
   make shell CONTAINER=revo-devcontainer-databricks TAG=16.4-LTS
   ```

3. CI automatically tests all container variants on pull requests
4. After merge to main, semantic-release handles versioning
5. CD workflow publishes all variants to `ghcr.io/revodatanl` with multi-architecture support

## Important Notes

- All containers run as root by default (non-root capability tested but not enforced)
- Registry: `ghcr.io/revodatanl`
- Requires `CR_PAT` environment variable for registry operations
- Multi-architecture support: All containers work on both Intel/AMD and Apple Silicon
- Parameterized builds allow easy addition of new Python/runtime versions
- Enhanced shell experience available in Databricks containers
- Latest tags: `16.4-LTS` (Databricks) and `3.12.4-slim` (Slim) are tagged as `latest`

## Testing

The repository includes comprehensive testing scripts for validating container functionality:

### Test Scripts

- **`.github/scripts/test-databricks-container.sh`** - Tests Databricks containers including:
  - Python, pip, jq, curl, wget, git, make, nano, tree
  - Databricks CLI, uv package manager
  - Enhanced shell tools: zsh, fzf, mcfly, powerline10k
  - Security and non-root user capability tests

- **`.github/scripts/test-slim-container.sh`** - Tests slim containers including:
  - Python execution, pip, git, make, nano, tree
  - uv package manager
  - Basic functionality and security tests

### Running Tests Locally

```bash
# Test a specific container after building
.github/scripts/test-databricks-container.sh revo-devcontainer-databricks 16.4-LTS
.github/scripts/test-slim-container.sh revo-devcontainer-slim 3.12.4-slim
```

## Adding New Versions

To add a new Python version or runtime variant:

1. Update the matrix in both `.github/workflows/ci.yml` and `.github/workflows/cd.yml`
2. Add the new variant with appropriate build arguments
3. Update the Makefile help text with the new variant
4. Test locally using the parameterized build system
5. Run the appropriate test script to validate functionality
