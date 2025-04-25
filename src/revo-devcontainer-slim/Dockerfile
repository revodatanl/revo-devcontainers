## ------------------------------- Builder Stage --------------------------------- ##
FROM python:3.11.11-slim AS builder

# Install system packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    make \
    nano \
    ssh \
    tree \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /workspace/

# Install uv
ADD https://astral.sh/uv/install.sh /uv-installer.sh
RUN sh /uv-installer.sh && rm /uv-installer.sh \
    && mv /root/.local/bin/uv /usr/local/bin/uv \
    && mv /root/.local/bin/uvx /usr/local/bin/uvx

# Install Poetry
RUN curl -sSL https://install.python-poetry.org | python - \
    && ln -s /root/.local/bin/poetry /usr/local/bin/poetry

## ------------------------------- Production Stage ------------------------------ ##
FROM python:3.11.11-slim AS production

# Add metadata
LABEL maintainer="Thomas Brouwer <thomas.brouwer@revodata.nl>" \
      description="RevoData DevContainer-slim container" \
      version="1.0" \
      org.opencontainers.image.source=https://github.com/revodatanl/revo-devcontainers

# Set environment variables
ENV EDITOR=nano

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
COPY --from=builder /usr/local/bin/uv /usr/local/bin/uv
COPY --from=builder /usr/local/bin/uvx /usr/local/bin/uvx
COPY --from=builder /usr/local/bin/poetry /usr/local/bin/poetry
COPY --from=builder /root/.local/share/pypoetry/ /root/.local/share/pypoetry/

# Keep the contianer running
CMD ["tail", "-f", "/dev/null"]
