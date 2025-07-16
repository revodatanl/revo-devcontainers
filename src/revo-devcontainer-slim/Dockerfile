ARG PYTHON_VERSION=3.11.11
FROM python:${PYTHON_VERSION}-slim AS builder

# Add metadata
LABEL maintainer="Thomas Brouwer <thomas.brouwer@revodata.nl>" \
      description="RevoData Slim DevContainer" \
      version="1.1" \
      org.opencontainers.image.source=https://github.com/revodatanl/revo-devcontainers

# Set environment variables
ENV EDITOR=nano \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

# Set the working directory
WORKDIR /workspace/

# Install system packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    locales \
    make \
    nano \
    procps \
    ssh \
    tree \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install uv
ADD https://astral.sh/uv/install.sh /uv-installer.sh
RUN sh /uv-installer.sh && rm /uv-installer.sh \
    && mv /root/.local/bin/uv /usr/local/bin/uv \
    && mv /root/.local/bin/uvx /usr/local/bin/uvx

# Generate en_US.UTF-8 locale
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

# Keep the container running
CMD ["tail", "-f", "/dev/null"]
