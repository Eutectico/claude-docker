# Claude Code CLI - Authentication Guide

This guide explains all available authentication methods for the Claude Code CLI Docker container.

## Table of Contents

- [Overview](#overview)
- [Method 1: Anthropic API Key](#method-1-anthropic-api-key)
- [Method 2: Interactive Login (OAuth)](#method-2-interactive-login-oauth)
- [Method 3: AWS Bedrock](#method-3-aws-bedrock)
- [Method 4: Google Vertex AI](#method-4-google-vertex-ai)
- [Advanced: Custom API Key Helper](#advanced-custom-api-key-helper)
- [Troubleshooting](#troubleshooting)

## Overview

Claude Code CLI supports four authentication methods. Choose the one that best fits your use case:

| Method | Best For | Requires Cloud Account | Setup Complexity |
|--------|----------|----------------------|------------------|
| **API Key** | Development, personal use | No | ⭐ Easy |
| **Interactive** | Individual users with Claude.ai subscription | No | ⭐ Easy |
| **AWS Bedrock** | Enterprise AWS environments | Yes (AWS) | ⭐⭐⭐ Complex |
| **Google Vertex** | Enterprise GCP environments | Yes (GCP) | ⭐⭐⭐ Complex |

## Method 1: Anthropic API Key

**Best for:** Development, personal projects, API-based workflows

### Prerequisites
- Anthropic account
- API access enabled

### Setup Steps

1. **Get your API Key:**
   - Visit: https://console.anthropic.com/settings/keys
   - Click "Create Key"
   - Copy the key (starts with `sk-ant-`)

2. **Configure `.env`:**
   ```bash
   AUTH_METHOD=api_key
   ANTHROPIC_API_KEY=sk-ant-your-key-here
   ```

3. **Start the container:**
   ```bash
   ./start.sh          # Linux/macOS
   .\start.ps1         # Windows
   ```

### Verification
```bash
docker exec -it claude-code-cli claude --version
```

### Pros & Cons
✅ Simple setup
✅ No cloud account needed
✅ Works immediately
❌ API key must be kept secret
❌ Pay-per-use pricing

---

## Method 2: Interactive Login (OAuth)

**Best for:** Individual users, Claude.ai subscription holders

### Prerequisites
- Claude.ai account (Pro or Team subscription)
- Web browser access from your machine

### Setup Steps

1. **Configure `.env`:**
   ```bash
   AUTH_METHOD=interactive
   # No other configuration needed!
   ```

2. **Start the container:**
   ```bash
   ./start.sh          # Linux/macOS
   .\start.ps1         # Windows
   ```

3. **Login interactively:**
   ```bash
   docker exec -it claude-code-cli /bin/bash
   claude
   ```

   The CLI will:
   - Display a login URL
   - Open your browser automatically (or you can copy the URL)
   - Prompt you to authorize the application
   - Save credentials in the container's config volume

4. **Credentials persist:**
   Your login is saved in the `claude_config` Docker volume and persists across container restarts.

### Verification
After successful login, simply run:
```bash
claude
```
You should see the Claude Code CLI prompt without being asked to login again.

### Pros & Cons
✅ No API key management
✅ Uses Claude.ai subscription
✅ Secure OAuth flow
✅ Credentials persist in Docker volume
❌ Requires browser access during initial setup
❌ Needs Claude.ai subscription

---

## Method 3: AWS Bedrock

**Best for:** Enterprise AWS environments, organizations using AWS IAM

### Prerequisites
- AWS account with Bedrock access
- IAM credentials or AWS CLI profile
- Bedrock model access enabled in your AWS region

### Setup Steps

#### Option A: Using Access Keys

1. **Create IAM credentials:**
   - Go to AWS Console → IAM → Users → Security Credentials
   - Create access key
   - Save the Access Key ID and Secret Access Key

2. **Configure `.env`:**
   ```bash
   AUTH_METHOD=bedrock
   AWS_ACCESS_KEY_ID=AKIA...
   AWS_SECRET_ACCESS_KEY=your-secret-key
   AWS_REGION=us-east-1
   ```

#### Option B: Using AWS CLI Profile

1. **Configure AWS CLI profile on your host:**
   ```bash
   aws configure --profile claude-bedrock
   ```

2. **Mount AWS credentials into container:**
   Edit `docker-compose.yml` to add:
   ```yaml
   volumes:
     - ~/.aws:/root/.aws:ro  # Mount AWS credentials
   ```

3. **Configure `.env`:**
   ```bash
   AUTH_METHOD=bedrock
   AWS_PROFILE=claude-bedrock
   AWS_REGION=us-east-1
   ```

#### Option C: Using Session Tokens (Temporary Credentials)

For temporary credentials (e.g., from AWS STS):
```bash
AUTH_METHOD=bedrock
AWS_ACCESS_KEY_ID=ASIA...
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_SESSION_TOKEN=your-session-token
AWS_REGION=us-east-1
```

### Required IAM Permissions

Your IAM user/role needs:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "bedrock:InvokeModel",
        "bedrock:InvokeModelWithResponseStream"
      ],
      "Resource": "arn:aws:bedrock:*::foundation-model/anthropic.claude-*"
    }
  ]
}
```

### Verification
```bash
# Inside container
docker exec -it claude-code-cli /bin/bash

# Check AWS CLI
aws sts get-caller-identity

# Test Bedrock access
aws bedrock list-foundation-models --region us-east-1
```

### Pros & Cons
✅ Enterprise-grade security with IAM
✅ Integrates with existing AWS infrastructure
✅ Supports OIDC federation
✅ Temporary credentials support
❌ Complex setup
❌ Requires AWS account and Bedrock access
❌ Additional AWS costs

---

## Method 4: Google Vertex AI

**Best for:** Enterprise GCP environments, organizations using Google Cloud

### Prerequisites
- Google Cloud Platform account
- Vertex AI API enabled
- Service account or Application Default Credentials

### Setup Steps

#### Option A: Using Service Account

1. **Create a service account:**
   ```bash
   gcloud iam service-accounts create claude-code \
       --display-name="Claude Code CLI"
   ```

2. **Grant necessary permissions:**
   ```bash
   gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
       --member="serviceAccount:claude-code@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
       --role="roles/aiplatform.user"
   ```

3. **Create and download key:**
   ```bash
   gcloud iam service-accounts keys create ~/claude-key.json \
       --iam-account=claude-code@YOUR_PROJECT_ID.iam.gserviceaccount.com
   ```

4. **Mount credentials and configure `.env`:**

   Edit `docker-compose.yml`:
   ```yaml
   volumes:
     - /path/to/claude-key.json:/root/.config/gcloud/credentials.json:ro
   ```

   Configure `.env`:
   ```bash
   AUTH_METHOD=vertex
   GOOGLE_CLOUD_PROJECT=your-project-id
   GOOGLE_APPLICATION_CREDENTIALS=/root/.config/gcloud/credentials.json
   GOOGLE_CLOUD_REGION=us-central1
   ```

#### Option B: Using Application Default Credentials

1. **Login on your host:**
   ```bash
   gcloud auth application-default login
   ```

2. **Mount credentials directory:**
   Edit `docker-compose.yml`:
   ```yaml
   volumes:
     - ~/.config/gcloud:/root/.config/gcloud:ro
   ```

3. **Configure `.env`:**
   ```bash
   AUTH_METHOD=vertex
   GOOGLE_CLOUD_PROJECT=your-project-id
   GOOGLE_CLOUD_REGION=us-central1
   # GOOGLE_APPLICATION_CREDENTIALS not needed with ADC
   ```

### Enable Vertex AI API

```bash
gcloud services enable aiplatform.googleapis.com
```

### Verification
```bash
# Inside container
docker exec -it claude-code-cli /bin/bash

# Check gcloud configuration
gcloud config list

# Test Vertex AI access
gcloud ai models list --region=us-central1
```

### Pros & Cons
✅ Enterprise-grade security with IAM
✅ Integrates with existing GCP infrastructure
✅ Service account support
✅ Workload Identity Federation support
❌ Complex setup
❌ Requires GCP account and Vertex AI access
❌ Additional GCP costs

---

## Advanced: Custom API Key Helper

For dynamic API key generation or rotation, you can use a custom helper script.

### Setup

1. **Create a helper script:**
   ```bash
   #!/bin/bash
   # scripts/api-key-helper.sh

   # Example: Fetch API key from secrets manager
   aws secretsmanager get-secret-value \
       --secret-id claude-api-key \
       --query SecretString \
       --output text
   ```

2. **Make it executable:**
   ```bash
   chmod +x scripts/api-key-helper.sh
   ```

3. **Configure `.env`:**
   ```bash
   AUTH_METHOD=api_key
   CLAUDE_CODE_API_KEY_HELPER=/workspace/scripts/api-key-helper.sh
   CLAUDE_CODE_API_KEY_HELPER_TTL_MS=300000  # Refresh every 5 minutes
   ```

4. **Mount the script:**
   Ensure your script is accessible inside the container via the workspace mount or add it to the container image.

### Use Cases
- Rotating API keys from secrets manager (AWS Secrets Manager, HashiCorp Vault, etc.)
- Fetching temporary credentials
- Implementing custom authentication flows
- Enterprise security compliance

---

## Troubleshooting

### General Issues

**Problem: "Authentication validation failed"**
```bash
# Run validation manually to see detailed errors
./scripts/validate-auth.sh       # Linux/macOS
.\scripts\validate-auth.ps1      # Windows
```

**Problem: Environment variables not loaded**
```bash
# Check if .env exists and is properly formatted
cat .env

# Ensure no extra spaces around =
# WRONG: AUTH_METHOD = api_key
# RIGHT: AUTH_METHOD=api_key
```

### API Key Issues

**Problem: "Invalid API key"**
- Verify key starts with `sk-ant-`
- Check for extra spaces or newlines
- Ensure key is active in Anthropic Console
- Try generating a new key

### Interactive Login Issues

**Problem: "Cannot open browser"**
- Copy the URL manually and open in browser
- Ensure you're logged into Claude.ai
- Check your subscription is active

**Problem: "Login expires"**
- OAuth tokens are stored in `claude_config` volume
- If volume is deleted, you need to login again
- Never run `docker-compose down -v` unless intentional

### AWS Bedrock Issues

**Problem: "Access denied"**
```bash
# Check IAM permissions
aws sts get-caller-identity

# Verify Bedrock model access
aws bedrock list-foundation-models --region us-east-1
```

**Problem: "Region not enabled"**
- Bedrock is not available in all regions
- Use supported regions: us-east-1, us-west-2, eu-west-1, etc.
- Request model access in AWS Console

### Google Vertex Issues

**Problem: "Project not found"**
```bash
# Verify project ID
gcloud projects list

# Set correct project
gcloud config set project YOUR_PROJECT_ID
```

**Problem: "API not enabled"**
```bash
# Enable Vertex AI API
gcloud services enable aiplatform.googleapis.com
```

**Problem: "Permission denied"**
- Check service account has `roles/aiplatform.user`
- Verify credentials file is correctly mounted
- Check file permissions on credentials JSON

---

## Security Best Practices

1. **Never commit credentials to Git**
   - `.env` is in `.gitignore`
   - Never add API keys to Dockerfile or docker-compose.yml directly

2. **Use least-privilege access**
   - AWS IAM: Only grant necessary Bedrock permissions
   - GCP IAM: Only grant `aiplatform.user` role

3. **Rotate credentials regularly**
   - Use API key helper for automatic rotation
   - Refresh temporary credentials before expiration

4. **Use volumes for sensitive data**
   - Mount credential files read-only (`:ro`)
   - Never copy credentials into Docker image

5. **Monitor usage**
   - Enable CloudTrail (AWS) or Cloud Audit Logs (GCP)
   - Track API usage in Anthropic Console
   - Set up billing alerts

---

## Quick Reference

| Method | .env Configuration | Additional Setup |
|--------|-------------------|------------------|
| **API Key** | `AUTH_METHOD=api_key`<br>`ANTHROPIC_API_KEY=sk-ant-...` | None |
| **Interactive** | `AUTH_METHOD=interactive` | Browser login on first use |
| **Bedrock** | `AUTH_METHOD=bedrock`<br>`AWS_ACCESS_KEY_ID=...`<br>`AWS_SECRET_ACCESS_KEY=...`<br>`AWS_REGION=us-east-1` | IAM permissions, Bedrock access |
| **Vertex** | `AUTH_METHOD=vertex`<br>`GOOGLE_CLOUD_PROJECT=...`<br>`GOOGLE_APPLICATION_CREDENTIALS=...` | Service account, Vertex AI API |

---

## Support & Resources

- **Anthropic Documentation**: https://docs.anthropic.com/
- **Claude Code Documentation**: https://code.claude.com/docs/
- **AWS Bedrock Documentation**: https://docs.aws.amazon.com/bedrock/
- **Google Vertex AI Documentation**: https://cloud.google.com/vertex-ai/docs
- **Project Issues**: Check CLAUDE.md and README.md for troubleshooting
