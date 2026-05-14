FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

# Install base system tools
RUN apt-get update && apt-get install -y \
    # Core utilities
    curl wget git vim nano less \
    # Build tools
    build-essential gcc g++ make cmake \
    # System utilities
    sudo ca-certificates gnupg \
    # Compression
    zip unzip tar gzip \
    # Networking
    net-tools iputils-ping dnsutils \
    # Search tools
    ripgrep \
    # Other useful tools
    jq tree htop procps lsof \
    # Python
    python3 python3-pip python3-venv python3-dev

# Install Node.js 24.x from NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y nodejs

# Install common global npm packages
RUN npm install -g \
    typescript \
    tsx \
    eslint \
    prettier \
    pnpm \
    yarn \
    http-server

# Install common Python packages
RUN pip3 install --break-system-packages \
    requests \
    httpx \
    pydantic \
    python-dotenv \
    rich \
    typer \
    pytest \
    black \
    ruff \
    ipython

# Install headless Chromium (Google Chrome Stable)
RUN mkdir -p -m 755 /etc/apt/keyrings \
    && curl -fsSL https://dl.google.com/linux/linux_signing_key.pub \
       | gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg \
    && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" \
       > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
                          fonts-liberation fonts-noto-cjk

# Install GitHub CLI (gh)
RUN mkdir -p -m 755 /etc/apt/keyrings \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
       | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
       | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y gh

# Install Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code

# Create claude user
RUN useradd -m -s /bin/bash -G sudo claude && \
    echo 'claude ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Create workspace directory
RUN mkdir -p /workspace && chown claude:claude /workspace

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER claude
WORKDIR /workspace

ENTRYPOINT ["/entrypoint.sh"]
