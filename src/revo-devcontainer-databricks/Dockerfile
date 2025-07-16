## ------------------------------- Builder Stage --------------------------------- ##
ARG PYTHON_VERSION=3.11.11
FROM python:${PYTHON_VERSION}-slim AS builder

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    fzf \
    make \
    nano \
    ssh \
    tree \
    unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Databricks CLI
RUN curl -fsSL https://raw.githubusercontent.com/databricks/setup-cli/main/install.sh | sh

# Install uv
ADD https://astral.sh/uv/install.sh /uv-installer.sh
RUN sh /uv-installer.sh && rm /uv-installer.sh \
    && mv /root/.local/bin/uv /usr/local/bin/uv \
    && mv /root/.local/bin/uvx /usr/local/bin/uvx

## ------------------------------- Production Stage ------------------------------ ##
FROM python:${PYTHON_VERSION}-slim AS production

# Add metadata
LABEL maintainer="Thomas Brouwer <thomas.brouwer@revodata.nl>" \
      description="RevoData Databricks DevContainer" \
      version="1.1" \
      org.opencontainers.image.source=https://github.com/revodatanl/revo-devcontainers

# Set environment variables
ENV EDITOR=nano \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    SHELL=/bin/zsh

# Set the working directory
WORKDIR /workspace/

# Copy installed binaries, libraries and tools
COPY --from=builder /usr/bin/fzf /usr/bin/fzf
COPY --from=builder /usr/bin/make /usr/bin/make
COPY --from=builder /usr/bin/nano /usr/bin/nano
COPY --from=builder /usr/bin/ssh /usr/bin/ssh
COPY --from=builder /usr/bin/tree /usr/bin/tree

# Copy installed executables
COPY --from=builder /usr/local/bin/databricks /usr/local/bin/databricks
COPY --from=builder /usr/local/bin/uv /usr/local/bin/uv
COPY --from=builder /usr/local/bin/uvx /usr/local/bin/uvx

# Install additional system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    fonts-powerline \
    git \
    jq \
    locales \
    procps \
    wget \
    zsh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Generate en_US.UTF-8 locale
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

# Persist zsh history
RUN mkdir /commandhistory \
    && touch /commandhistory/.zsh_history \
    && chmod 755 /commandhistory \
    && chmod 644 /commandhistory/.zsh_history

# -------------------------------------------------------------- #
# Install zsh shell with powerline10k theme
# -------------------------------------------------------------- #

# Pre-install gitstatus for powerlevel10k theme
RUN git clone --depth=1 https://github.com/romkatv/gitstatus.git /tmp/gitstatus && \
    /tmp/gitstatus/install -f && \
    rm -rf /tmp/gitstatus

# Download fzf key bindings and completion scripts
RUN mkdir -p /root/.local/share/fzf && \
    curl -fsSL https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.zsh -o /root/.local/share/fzf/key-bindings.zsh && \
    curl -fsSL https://raw.githubusercontent.com/junegunn/fzf/master/shell/completion.zsh -o /root/.local/share/fzf/completion.zsh

# Install MCfly for intelligent command history
RUN MCFLY_VERSION=$(curl -s https://api.github.com/repos/cantino/mcfly/releases/latest | grep '"tag_name"' | cut -d'"' -f4) && \
    curl -LSfs https://raw.githubusercontent.com/cantino/mcfly/master/ci/install.sh | sh -s -- --git cantino/mcfly --tag $MCFLY_VERSION --to /root/.local/bin

# Setup zsh with powerline10k theme and enhanced plugins as root user
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.0/zsh-in-docker.sh)" -- \
  -p git \
  -p fzf \
  -p https://github.com/zsh-users/zsh-autosuggestions \
  -p https://github.com/zsh-users/zsh-syntax-highlighting \
  -a "source /root/.local/share/fzf/key-bindings.zsh" \
  -a "source /root/.local/share/fzf/completion.zsh" \
  -a "export HISTFILE=/commandhistory/.zsh_history" \
  -a "export PATH=\"\$PATH:/root/.local/bin\"" \
  -a "eval \"\$(mcfly init zsh)\"" \
  -x

# Keep the container running
CMD ["/bin/zsh", "-c", "tail -f /dev/null"]
