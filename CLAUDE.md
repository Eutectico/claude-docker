# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Docker-based Claude Code CLI environment that provides a containerized instance of the Anthropic Claude Code CLI (`@anthropic-ai/claude-code`) running on Node.js v22. The project is designed to be cross-platform (Windows, Linux, macOS) with platform-specific startup scripts.

## Architecture

### Core Components

- **Docker Container**: Node.js 22 (Bookworm) base image with Claude Code CLI installed globally via npm
- **Persistent Storage**: Two Docker volumes (`claude_config` and `claude_cache`) store authentication and cache data across container restarts
- **Workspace**: Local `./workspace` directory mounted to `/workspace` in container for file sharing between host and container
- **Cross-Platform Scripts**: Separate PowerShell (`.ps1`) and Bash (`.sh`) scripts that auto-detect Docker Compose version (`docker-compose` vs `docker compose`)

### Container Configuration

The container (defined in `Dockerfile`) includes:
- Node.js v22 with npm v10+
- Claude Code CLI (`@anthropic-ai/claude-code`)
- Basic Unix utilities (git, vim, nano, curl, wget, bash-completion)
- Non-root user `claudeuser` (UID=1001, GID=1001) for security
- Bash aliases: `cc` and `claude-code` both aliased to `claude`
- Working directory: `/workspace`

### Volume Mounts

1. `claude_config:/home/claudeuser/.config` - Persists Claude Code configuration and authentication
2. `claude_cache:/home/claudeuser/.cache` - Cache for better performance
3. `./workspace:/workspace` - Shared directory for code/files between host and container

## Common Commands

### Container Management

**Linux/macOS:**
```bash
# Start container (builds if needed)
./start.sh

# Stop container (preserves volumes)
./stop.sh

# Check Docker/Docker Compose setup
./check-setup.sh
```

**Windows (PowerShell):**
```powershell
.\start.ps1
.\stop.ps1
```

**Manual Docker Commands (all platforms):**
```bash
# Build and start
docker-compose up -d --build

# Stop (keeps volumes)
docker-compose down

# Stop and delete volumes (loses configuration!)
docker-compose down -v

# Restart
docker-compose restart

# View logs
docker-compose logs -f

# Check status
docker-compose ps
```

### Using Claude Code CLI

```bash
# Enter container interactively
docker exec -it claude-code-cli /bin/bash

# Run Claude Code inside container
claude

# Run Claude Code from host (one-off command)
docker exec -it claude-code-cli claude

# Work in workspace context
docker exec -it claude-code-cli bash -c "cd /workspace && claude"
```

### First-Time Setup

1. Start container: `./start.sh` (Linux/macOS) or `.\start.ps1` (Windows)
2. If `.env` doesn't exist, it will be created from `.env.example`
3. Edit `.env` and configure your authentication method:
   - Set `AUTH_METHOD` to your chosen method (`api_key`, `interactive`, `bedrock`, or `vertex`)
   - Configure the corresponding credentials (see Environment Variables section)
4. The startup scripts will automatically validate your configuration
5. Restart container if needed: `docker-compose restart`
6. Enter container: `docker exec -it claude-code-cli /bin/bash`
7. Run `claude` to start using Claude Code CLI

#### Example Configurations:

**API Key Authentication:**
```bash
AUTH_METHOD=api_key
ANTHROPIC_API_KEY=sk-ant-your-key-here
```

**Interactive Login:**
```bash
AUTH_METHOD=interactive
# No additional config needed - just run 'claude' and follow prompts
```

**AWS Bedrock:**
```bash
AUTH_METHOD=bedrock
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_REGION=us-east-1
```

**Google Vertex AI:**
```bash
AUTH_METHOD=vertex
GOOGLE_CLOUD_PROJECT=your-project-id
GOOGLE_CLOUD_REGION=us-central1
```

## Development Workflow

### Adding Additional Tools to Container

**Temporary (lost on rebuild):**
```bash
docker exec -it claude-code-cli bash -c "apt-get update && apt-get install -y python3"
```

**Permanent (edit Dockerfile):**
Add to the RUN command around line 9:
```dockerfile
RUN apt-get update && apt-get install -y \
    git \
    vim \
    your-new-package \
    && rm -rf /var/lib/apt/lists/*
```

### Adding Additional Volume Mounts

Edit `docker-compose.yml` to add more host directories:
```yaml
volumes:
  - claude_config:/root/.config
  - claude_cache:/root/.cache
  - ./workspace:/workspace
  - /your/local/path:/container/path  # Add here
```

## Important Implementation Details

### Script Auto-Detection Logic

Both `start.sh`/`start.ps1` and `stop.sh`/`stop.ps1` automatically detect whether to use `docker-compose` (legacy) or `docker compose` (modern plugin):

**Bash:**
```bash
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
elif docker compose version &> /dev/null 2>&1; then
    DOCKER_COMPOSE="docker compose"
fi
```

**PowerShell:**
```powershell
if (Get-Command docker-compose -ErrorAction SilentlyContinue) {
    $dockerComposeCmd = "docker-compose"
} elseif ((docker compose version 2>$null) -and $LASTEXITCODE -eq 0) {
    $dockerComposeCmd = "docker", "compose"
}
```

This pattern ensures compatibility across different Docker installations.

### Container Service Name

The Docker Compose service is named `claude-cli` but the container name is explicitly set to `claude-code-cli` (see `container_name` in docker-compose.yml:9). All `docker exec` commands use `claude-code-cli`.

### Environment Variables

The `.env` file (created from `.env.example` on first run) supports multiple authentication methods:

#### Authentication Method Selection
- `AUTH_METHOD`: Selects the authentication method (default: `api_key`)
  - `api_key` - Direct Anthropic API Key authentication
  - `interactive` - Interactive OAuth login with Claude.ai account
  - `bedrock` - AWS Bedrock with IAM/OIDC authentication
  - `vertex` - Google Vertex AI authentication

#### Method 1: Anthropic API Key (`AUTH_METHOD=api_key`)
- `ANTHROPIC_API_KEY`: Your Anthropic API key from https://console.anthropic.com/settings/keys

#### Method 2: Interactive Login (`AUTH_METHOD=interactive`)
- No environment variables required
- After container start, run `claude` and follow the OAuth login flow

#### Method 3: AWS Bedrock (`AUTH_METHOD=bedrock`)
- `AWS_ACCESS_KEY_ID`: AWS access key
- `AWS_SECRET_ACCESS_KEY`: AWS secret key
- `AWS_SESSION_TOKEN`: (Optional) AWS session token
- `AWS_REGION`: AWS region (default: us-east-1)
- `AWS_PROFILE`: (Alternative) AWS CLI profile name

#### Method 4: Google Vertex AI (`AUTH_METHOD=vertex`)
- `GOOGLE_CLOUD_PROJECT`: **Required** - Your GCP project ID
- `GOOGLE_APPLICATION_CREDENTIALS`: (Optional) Path to service account JSON
- `GOOGLE_CLOUD_REGION`: GCP region (default: us-central1)

#### Advanced Options
- `CLAUDE_CODE_API_KEY_HELPER`: Path to custom script for dynamic API key generation
- `CLAUDE_CODE_API_KEY_HELPER_TTL_MS`: Key helper refresh interval (default: 300000ms = 5 minutes)

## Security

### Non-Root User

The container runs as a non-root user `claudeuser` with UID=1001 and GID=1001 for improved security:
- All processes run with limited privileges
- Configuration and cache files are stored in `/home/claudeuser/`
- The workspace directory `/workspace` is accessible with proper permissions
- This follows Docker security best practices by avoiding unnecessary root privileges

**Important for file permissions:**
- Files created inside the container in `/workspace` will be owned by UID=1001 on the host
- If your host user has a different UID, you may need to adjust permissions accordingly
- To match the container user with your host user, you can modify the UID/GID in the Dockerfile

## Platform-Specific Notes

### Linux/macOS

- Scripts must be executable: `chmod +x *.sh`
- User should be in `docker` group to avoid needing `sudo`: `sudo usermod -aG docker $USER`
- For seamless file permissions, ensure your host user UID matches the container UID (1001)
- The `check-setup.sh` script validates the entire Docker environment and checks:
  - Docker installation and status
  - Docker Compose availability
  - User docker group membership
  - Script permissions
  - `.env` file and API key configuration

### Windows

- Uses PowerShell scripts (`.ps1`)
- Paths in `docker-compose.yml` should use forward slashes or Windows-style paths
- Scripts handle Docker Desktop automatically
- No setup check script available (use manual validation)

## Critical Warnings

1. **Never run `docker-compose down -v`** unless you want to lose Claude Code configuration (deletes volumes)
2. **Container runs continuously** with `restart: unless-stopped` - use stop scripts to shut down
3. **Workspace persistence**: Only files in `./workspace` (host) are shared with `/workspace` (container)
4. **Multiple authentication methods**: Choose the method that fits your use case:
   - `api_key` - Best for development and personal use
   - `interactive` - Best for individual users with Claude.ai subscription
   - `bedrock` - Best for enterprise AWS environments
   - `vertex` - Best for enterprise GCP environments
5. **Credential security**: Never commit `.env` to git (already protected by `.gitignore`)
6. **Cloud provider tools**: AWS CLI and Google Cloud SDK are pre-installed in the container for Bedrock and Vertex authentication

## Authentication Validation

The project includes automatic authentication validation:
- **Linux/macOS**: `scripts/validate-auth.sh` is automatically run by `start.sh`
- **Windows**: `scripts/validate-auth.ps1` is automatically run by `start.ps1`
- **Manual check**: Run `./check-setup.sh` (Linux/macOS) to validate your entire setup including authentication

These scripts verify:
- Correct `AUTH_METHOD` value
- Required credentials are set for the chosen method
- Proper credential format (e.g., API keys start with `sk-ant-`)
- Cloud provider configuration completeness
