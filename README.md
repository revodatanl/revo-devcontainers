# RevoData Development Containers

> *Streamlined development in RevoData containers*

[![python](https://img.shields.io/badge/python-3.11-g)](https://www.python.org)
[![uv](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/astral-sh/uv/main/assets/badge/v0.json)](https://github.com/astral-sh/uv)
[![Ruff](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/astral-sh/ruff/main/assets/badge/v2.json)](https://github.com/astral-sh/ruff)
[![Checked with mypy](http://www.mypy-lang.org/static/mypy_badge.svg)](http://mypy-lang.org/)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![pydocstyle](https://img.shields.io/badge/pydocstyle-enabled-AD4CD3)](http://www.pydocstyle.org/en/stable/)
[![semantic-release: angular](https://img.shields.io/badge/semantic--release-angular-e10079?logo=semantic-release)](https://github.com/semantic-release/semantic-release)

This repository, generated from the [RevoData Asset Bundle Template](https://github.com/revodatanl/revo-asset-bundle-templates) version `0.11.1`, provides standardized, ready-to-use development containers for all RevoData projects with multiple environment options.

## 🛠️ Available Development Environments

### 1. Simple Python Environment: `revo-devcontainer-slim`

A lightweight Python development container with:

- **Python 3.11**
- **uv**
- **Poetry**
- **Pre-commit hooks**
- **Essential tools** - `git`, `make`, `nano`, and `tree`

Perfect for general Python development and smaller projects.

### 2. Databricks Runtime Environment: `revo-devcontainer-databricksruntime`

A more advanced container based on the Databricks Runtime (15.4 LTS) that includes:

- **Databricks Runtime 15.4 LTS**
- **Databricks CLI**
- **Python 3.11**
- **uv**
- **Poetry**
- **Pre-commit hooks**
- **Essential tools** - `git`, `make`, `nano`, and `tree`

Ideal for Databricks development, data science, and machine learning projects.

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have:

- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Visual Studio Code](https://code.visualstudio.com/)
- [VS Code Remote - Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

### 🛠️ Container Maintenance

To update or customize the development containers:

1. Modify the Dockerfile in the respective environment directory in the `src` folder
2. Build and test your changes locally
3. If publishing to a registry; build, tag, and push the new image by running:

   ```bash
   make CONTAINER=<container-name> TAG=<tag>
   ```

This command requires that you have configured the `CR_PAT` environment variable, and have `make` installed - but you probably do.
