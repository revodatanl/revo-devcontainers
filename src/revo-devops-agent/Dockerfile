FROM ubuntu:24.04

# Add metadata
LABEL maintainer="Thomas Brouwer <thomas.brouwer@revodata.nl>" \
      description="RevoData DevOps Agent container" \
      version="1.0" \
      org.opencontainers.image.source=https://github.com/revodatanl/revo-devcontainers


# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Etc/UTC

# Set the working directory
WORKDIR /workspace/

# Install Python 3.12 (native)
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    && ln -sf /usr/bin/python3 /usr/local/bin/python \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install curl
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install uv
ADD https://astral.sh/uv/install.sh /uv-installer.sh
RUN sh /uv-installer.sh && rm /uv-installer.sh \
    && mv /root/.local/bin/uv /usr/local/bin/uv \
    && mv /root/.local/bin/uvx /usr/local/bin/uvx

# Install Poetry
RUN curl -sSL https://install.python-poetry.org | python3 - \
    && ln -s /root/.local/bin/poetry /usr/local/bin/poetry

# The following are best practices that we should definitely implement, later
# # Create a non-root user
# RUN useradd -m -s /bin/bash -u 1001 devopsagent
# # Set permissions for the working directory
# RUN chown -R devopsagent:devopsagent /workspace
# # Switch to non-root user
# USER devopsagent

# Entrypoint for persistent agents
CMD ["tail", "-f", "/dev/null"]
