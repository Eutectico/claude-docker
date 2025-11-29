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
