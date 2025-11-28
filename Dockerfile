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
    && rm -rf /var/lib/apt/lists/*

# Verify Node.js and npm versions
RUN node --version && npm --version

# Install Claude Code CLI globally
RUN npm install -g @anthropic-ai/claude-code

# Verify installation
RUN claude --version || echo "Claude Code installed, awaiting authentication"

# Setup bash aliases for convenience
RUN echo 'alias cc="claude"' >> /root/.bashrc && \
    echo 'alias claude-code="claude"' >> /root/.bashrc

# Create workspace directory
WORKDIR /workspace

# Welcome message
RUN echo 'echo "🤖 Claude Code CLI Container"' >> /root/.bashrc && \
    echo 'echo "Run: claude"' >> /root/.bashrc && \
    echo 'echo "Workspace: /workspace"' >> /root/.bashrc && \
    echo 'echo ""' >> /root/.bashrc

# Default command
CMD ["/bin/bash"]
