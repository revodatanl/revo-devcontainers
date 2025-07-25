# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository provides a standardized development container for RevoData projects with **multi-architecture support** (AMD64 and ARM64):

**revo-devcontainer-databricks** - Databricks Runtime based environment with enhanced shell

- `latest` tag - Current production version
- Python managed through uv (no direct Python installation)
- Python version controlled by `.python-version` file in downstream repositories
- Enhanced with zsh, powerline10k, fzf, and mcfly for better development experience
  
## Build System

The project uses a comprehensive Makefile for container operations:

### Core Build Commands

The Makefile has been simplified to follow a cleaner pattern:

```bash
# Build with simplified parameters (defaults to latest tag)
make build CONTAINER=revo-devcontainer-databricks TAG=latest
make build CONTAINER=revo-devcontainer-databricks  # Uses default latest tag

# Build, tag and push (requires CR_PAT environment variable)
make all CONTAINER=revo-devcontainer-databricks TAG=latest
make all  # Uses default databricks container and latest tag

# Login to GitHub Container Registry
make login

# Open shell in running container (uses consistent /bin/zsh)
make shell CONTAINER=revo-devcontainer-databricks
```

### Available Containers and Current Focus

Currently focused on a single container type:

- **revo-devcontainer-databricks** (default)
  - `latest` tag - Current production version
  - Enhanced with zsh, powerline10k, fzf, and mcfly for better development experience
  - Python managed through uv (no direct Python installation)
  - Multi-architecture support (AMD64 and ARM64)

### Multi-Architecture Support

All containers are built for both `linux/amd64` and `linux/arm64` architectures, ensuring compatibility with:

- Intel/AMD processors (x86_64)
- Apple Silicon (M1/M2/M3) processors
- ARM64 servers

## Container Architecture

### Dockerfile Structure

The Databricks container (`src/revo-devcontainer-databricks/Dockerfile`) is built on Ubuntu 24.04 and includes:

- **Base Image**: `ubuntu:24.04` (parameterized via `BASE_IMAGE_VERSION`)
- **Package Management**: uv for Python package management (no direct Python installation)
- **Essential Tools**: git, make, nano, tree, jq, curl, wget, ssh, unzip
- **Enhanced Shell**: zsh with powerline10k, fzf, mcfly, and persistent history
- **Development Tools**: Databricks CLI

### Key Environment Variables

- **Shell Configuration**: `SHELL=/bin/zsh`, `EDITOR=nano`
- **Locale**: `LANG=en_US.UTF-8`, `LC_ALL=en_US.UTF-8`
- **History Persistence**: Command history stored in `/commandhistory/.zsh_history`

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
- Matrix strategy currently builds:
  - revo-devcontainer-databricks:24.04 (based on Ubuntu 24.04)
- Runs comprehensive tests including:
  - Basic functionality tests
  - Image-specific tool verification (Databricks CLI, uv, zsh for enhanced containers)
  - Security tests (non-root user capability)
  - Container metrics analysis
- Uses Docker layer caching with scope-specific caching for efficiency

### CD Workflow (.github/workflows/cd.yml)

- Publishes all variants to GitHub Container Registry
- Multi-architecture builds for both AMD64 and ARM64
- Automatic tagging:
  - Databricks container tagged as `latest`
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
   make build CONTAINER=revo-devcontainer-databricks TAG=latest
   make shell CONTAINER=revo-devcontainer-databricks TAG=latest
   ```

3. CI automatically tests all container variants on pull requests
4. After merge to main, semantic-release handles versioning
5. CD workflow publishes all variants to `ghcr.io/revodatanl` with multi-architecture support

## Important Notes

- All containers run as root by default (non-root capability tested but not enforced)
- Registry: `ghcr.io/revodatanl`
- Requires `CR_PAT` environment variable for registry operations
- Multi-architecture support: All containers work on both Intel/AMD and Apple Silicon
- Enhanced shell experience available in Databricks containers
- Latest tag: `latest` represents the current production version of the databricks container
- **Python Version Management**: Python version is controlled by the `.python-version` file in downstream repositories using this container. Users are responsible for ensuring the Python version matches their intended Databricks runtime requirements.

## Testing

The repository includes comprehensive testing scripts for validating container functionality:

### Test Scripts

- **`.github/scripts/test-databricks-container.sh`** - Tests Databricks containers including:
  - uv package manager and uvx functionality
  - Python availability through uv virtual environments (no direct Python)
  - uv project workflow with Python version specification
  - Essential tools: jq, curl, wget, git, make, nano, tree
  - Databricks CLI
  - Enhanced shell tools: zsh, fzf, mcfly, powerline10k
  - Environment configuration and history persistence
  - Security and workspace permissions

### Running Tests Locally

```bash
# Test the databricks container (note: now requires Python version parameter)
.github/scripts/test-databricks-container.sh revo-devcontainer-databricks latest 3.12.4
```

### Key Testing Changes

- **Python Testing**: No longer tests direct Python installation; instead validates Python accessibility through uv
- **uv Workflow**: Tests complete uv project workflow including .python-version specification
- **Package Management**: Validates package installation and import capabilities via uv virtual environments

## Adding New Versions

To add a new Python version or runtime variant:

1. Update the matrix in both `.github/workflows/ci.yml` and `.github/workflows/cd.yml`
2. Add the new variant with appropriate build arguments
3. Update the Makefile help text with the new variant
4. Test locally using the parameterized build system
5. Run the appropriate test script to validate functionality
