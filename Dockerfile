# Claude Code CLI Dockerfile
FROM node:22-bookworm

# Metadata
LABEL maintainer="Scripts"
LABEL description="Claude Code CLI in Docker"

# System-Abhängigkeiten
RUN apt-get update && apt-get install -y \
    git \
    vim \
    nano \
    curl \
    wget \
    bash-completion \
    python3 \
    python3-pip \
    unzip \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install AWS CLI v2 (für Bedrock)
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf aws awscliv2.zip

# Install Google Cloud SDK (für Vertex AI)
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
    apt-get update && apt-get install -y google-cloud-sdk && \
    rm -rf /var/lib/apt/lists/*

# Verify Node.js and npm versions
RUN node --version && npm --version

# Install Claude Code CLI globally
RUN npm install -g @anthropic-ai/claude-code

# Verify installation
RUN claude --version || echo "Claude Code installed, awaiting authentication"

# Create non-root user with UID=1001 and GID=1001
RUN groupadd -g 1001 claudeuser && \
    useradd -u 1001 -g 1001 -m -s /bin/bash claudeuser

# Configure sudo for claudeuser (passwordless)
RUN usermod -aG sudo claudeuser && \
    echo 'claudeuser ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Setup bash aliases and welcome message for claudeuser
RUN echo 'alias cc="claude"' >> /home/claudeuser/.bashrc && \
    echo 'alias claude-code="claude"' >> /home/claudeuser/.bashrc && \
    echo 'echo "🤖 Claude Code CLI Container"' >> /home/claudeuser/.bashrc && \
    echo 'echo "Run: claude"' >> /home/claudeuser/.bashrc && \
    echo 'echo "Workspace: /workspace"' >> /home/claudeuser/.bashrc && \
    echo 'echo ""' >> /home/claudeuser/.bashrc

# Create workspace directory and set permissions
RUN mkdir -p /workspace && chown -R 1001:1001 /workspace

# Create config and cache directories with correct permissions
RUN mkdir -p /home/claudeuser/.config /home/claudeuser/.cache && \
    chown -R 1001:1001 /home/claudeuser/.config /home/claudeuser/.cache

# Switch to non-root user
USER claudeuser

# Set working directory
WORKDIR /workspace

# Default command
CMD ["/bin/bash"]
