# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository provides standardized development containers for RevoData projects. It contains three Docker container variants:

1. **revo-devcontainer-slim** - Lightweight Python 3.11 development environment
2. **revo-devcontainer-databricksruntime** - Databricks Runtime 15.4 LTS based environment with Databricks CLI
3. **revo-devops-agent** - Ubuntu 24.04 based DevOps environment with Python 3.12

All containers include `uv`, `poetry`, `git`, `make`, `nano`, and `tree` as standard tools.

## Build System

The project uses a comprehensive Makefile for container operations:

### Core Build Commands

```bash
# Build a specific container
make build CONTAINER=revo-devcontainer-slim TAG=3.11.11-slim

# Build, tag and push (requires CR_PAT environment variable)
make all CONTAINER=revo-devcontainer-slim TAG=3.11.11-slim

# Login to GitHub Container Registry
make login

# Open shell in running container
make shell CONTAINER=revo-devcontainer-slim
```

### Available Containers

- `revo-devcontainer-slim` (default tags: `3.11.11-slim`)
- `revo-devcontainer-databricksruntime` (default tags: `15.4-LTS``)
- `revo-devops-agent` (default tags: `24.04`)

## Container Architecture

### Multi-stage Dockerfiles

Both `revo-devcontainer-slim` and `revo-devcontainer-databricksruntime` use multi-stage builds:

- **Builder stage**: Installs all tools and dependencies
- **Production stage**: Copies only necessary binaries for smaller final image

### Key Environment Variables

- **Databricks Runtime**: `UV_PROJECT_ENVIRONMENT="/databricks/python3"`, `UV_SYSTEM_PYTHON=true`
- **All containers**: `EDITOR=nano`

## CI/CD Pipeline

The project uses GitHub Actions with three workflows:

### CI Workflow (.github/workflows/ci.yml)

- Builds all three containers in parallel
- Runs comprehensive tests including:
  - Basic functionality tests
  - Image-specific tool verification
  - Security tests (non-root user capability)
  - Container metrics analysis
- Uses Docker layer caching for efficiency

### Release Process

- Uses semantic-release with conventional commits
- Automatically generates CHANGELOG.md
- Main branch: `main`
- Release commits: `chore(release): ${version} [skip ci]`

## Development Workflow

1. Modify Dockerfiles in respective `src/` directories
2. Test locally using `make build` and `make shell`
3. CI automatically tests all containers on pull requests
4. After merge to main, semantic-release handles versioning
5. CD workflow publishes to `ghcr.io/revodatanl`

## Important Notes

- All containers run as root by default (non-root capability tested but not enforced)
- Registry: `ghcr.io/revodatanl`
- Requires `CR_PAT` environment variable for registry operations
