## ------------------------------- Builder Stage --------------------------------- ##
FROM databricksruntime/standard:15.4-LTS AS builder

# Set environment variables
ENV UV_PROJECT_ENVIRONMENT="/databricks/python3" \
    UV_SYSTEM_PYTHON=true

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    make \
    nano \
    ssh \
    tree \
    unzip \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /workspace/

# Install Databricks CLI
RUN curl -fsSL https://raw.githubusercontent.com/databricks/setup-cli/main/install.sh | sh

# Install uv
ADD https://astral.sh/uv/install.sh /uv-installer.sh
RUN sh /uv-installer.sh && rm /uv-installer.sh \
    && mv /root/.local/bin/uv /usr/local/bin/uv \
    && mv /root/.local/bin/uvx /usr/local/bin/uvx

# Install Poetry
RUN curl -sSL https://install.python-poetry.org | python3 - \
    && ln -s /root/.local/bin/poetry /usr/local/bin/poetry

# Install project dependenciesx
COPY pyproject.toml /workspace/
RUN uv sync --inexact --all-groups

## ------------------------------- Production Stage ------------------------------ ##
FROM databricksruntime/standard:15.4-LTS AS production

# Add metadata
LABEL maintainer="Thomas Brouwer <thomas.brouwer@revodata.nl>" \
      description="RevoData DevContainer-databricksruntime container" \
      version="1.0" \
      org.opencontainers.image.source=https://github.com/revodatanl/revo-devcontainers

# Set environment variables
ENV PATH="/databricks/python3/bin:$PATH" \
    EDITOR=nano \
    UV_PROJECT_ENVIRONMENT="/databricks/python3" \
    UV_SYSTEM_PYTHON=true

# Set the working directory
WORKDIR /workspace/

# Copy installed binaries, libraries and tools
COPY --from=builder /usr/bin/git /usr/bin/git
COPY --from=builder /usr/lib/git-core/ /usr/lib/git-core/
COPY --from=builder /usr/share/git-core/ /usr/share/git-core/
COPY --from=builder /usr/bin/make /usr/bin/make
COPY --from=builder /usr/bin/nano /usr/bin/nano
COPY --from=builder /usr/bin/tree /usr/bin/tree
COPY --from=builder /usr/bin/ssh /usr/bin/ssh

# Copy installed executables
COPY --from=builder /usr/local/bin/databricks /usr/local/bin/databricks
COPY --from=builder /usr/local/bin/uv /usr/local/bin/uv
COPY --from=builder /usr/local/bin/uvx /usr/local/bin/uvx
COPY --from=builder /usr/local/bin/poetry /usr/local/bin/poetry
COPY --from=builder /root/.local/share/pypoetry/ /root/.local/share/pypoetry/

# Copy installed Python site-packages
COPY --from=builder /databricks/python3/lib/python3.11/site-packages /databricks/python3/lib/python3.11/site-packages

# Keep the contianer running
CMD ["tail", "-f", "/dev/null"]
