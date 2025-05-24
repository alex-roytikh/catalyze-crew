# Docker Image for AWS ECR

This document explains how to build, version, and deploy the concierge-crewai Docker image to AWS ECR.

## Quick Start

### 1. Build and Push to ECR (One Command)
```bash
# Release with patch version bump and push to ECR
./scripts/release.sh patch us-east-1 123456789012

# Release with minor version bump
./scripts/release.sh minor us-east-1 123456789012

# Release with major version bump
./scripts/release.sh major us-east-1 123456789012
```

### 2. Manual Build and Push
```bash
# Build locally
./scripts/build.sh

# Push to ECR
./scripts/push-to-ecr.sh 0.1.0 us-east-1 123456789012
```

## Prerequisites

1. **Docker Desktop** installed and running
2. **AWS CLI** configured with appropriate permissions
3. **Git** for version tagging
4. **AWS ECR permissions** for your account

### Required AWS Permissions
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:CreateRepository",
                "ecr:DescribeRepositories",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:PutLifecycleConfiguration"
            ],
            "Resource": "*"
        }
    ]
}
```

## Scripts Overview

### `scripts/build.sh`
Builds Docker image with proper versioning and metadata.

**Usage:**
```bash
./scripts/build.sh [version] [platform]
```

**Examples:**
```bash
# Use version from pyproject.toml, build for multiple platforms
./scripts/build.sh

# Specify version and platform
./scripts/build.sh 1.2.3 linux/amd64

# Build for ARM64 (Apple Silicon)
./scripts/build.sh 1.2.3 linux/arm64
```

### `scripts/push-to-ecr.sh`
Pushes Docker image to AWS ECR with automatic repository creation.

**Usage:**
```bash
./scripts/push-to-ecr.sh [version] [region] [account-id] [repository-name]
```

**Examples:**
```bash
# Push to ECR
./scripts/push-to-ecr.sh 1.2.3 us-east-1 123456789012

# Use custom repository name
./scripts/push-to-ecr.sh 1.2.3 us-east-1 123456789012 my-crew-app
```

### `scripts/release.sh`
Complete release workflow: version bump, build, and push.

**Usage:**
```bash
./scripts/release.sh [major|minor|patch] [region] [account-id]
```

**Examples:**
```bash
# Patch release (0.1.0 → 0.1.1)
./scripts/release.sh patch us-east-1 123456789012

# Minor release (0.1.1 → 0.2.0)
./scripts/release.sh minor us-east-1 123456789012

# Major release (0.2.0 → 1.0.0)
./scripts/release.sh major us-east-1 123456789012
```

## Image Tags

Each build creates multiple tags:
- `concierge-crewai:latest` - Latest version
- `concierge-crewai:1.2.3` - Semantic version
- `concierge-crewai:1.2.3-abc1234` - Version + Git commit

## Using in CDK/CloudFormation

### CDK (TypeScript)
```typescript
import { Repository } from 'aws-cdk-lib/aws-ecr';
import { ContainerImage } from 'aws-cdk-lib/aws-ecs';

// Reference existing ECR repository
const ecrRepo = Repository.fromRepositoryName(
  this, 
  'ConciergeCrewAI', 
  'concierge-crewai'
);

// Use in ECS Task Definition
const containerImage = ContainerImage.fromEcrRepository(ecrRepo, '1.2.3');
```

### CloudFormation
```yaml
Resources:
  TaskDefinition:
    Type: AWS::ECS::TaskDefinition
    Properties:
      ContainerDefinitions:
        - Name: concierge-crew
          Image: !Sub "${AWS::AccountId}.dkr.ecr.${AWS::Region}.amazonaws.com/concierge-crewai:1.2.3"
          Memory: 2048
          Cpu: 1024
```

### Docker Compose (for local testing with ECR image)
```yaml
services:
  crew:
    image: 123456789012.dkr.ecr.us-east-1.amazonaws.com/concierge-crewai:1.2.3
    environment:
      - PYTHONUNBUFFERED=1
    volumes:
      - ./output:/app/output
```

## Running the Image

### From ECR
```bash
# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com

# Pull and run
docker pull 123456789012.dkr.ecr.us-east-1.amazonaws.com/concierge-crewai:1.2.3
docker run -it 123456789012.dkr.ecr.us-east-1.amazonaws.com/concierge-crewai:1.2.3
```

### Execute Crew Task
```bash
# Inside the container
uv run python -c "from crew.main import run; run()"
```

## Image Lifecycle Management

The ECR repository is automatically configured with lifecycle policies:
- **Keep last 10 tagged versions** - Automatically removes older versions
- **Delete untagged images after 1 day** - Cleans up intermediate layers

## Troubleshooting

### Build Issues
```bash
# Check Docker Desktop is running
docker ps

# Verify uv.lock is up to date
cd crew && uv lock

# Clear Docker cache if needed
docker builder prune
```

### ECR Authentication Issues
```bash
# Check AWS credentials
aws sts get-caller-identity

# Re-authenticate to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com
```

### Version Issues
```bash
# Check current version
grep version pyproject.toml

# Manually tag git version
git tag v1.2.3
git push --tags
```

## Security Best Practices

1. **Non-root user** - Image runs as `appuser` (UID 1000)
2. **Minimal base image** - Uses `python:3.12-slim`
3. **No secrets in image** - Use environment variables or AWS Secrets Manager
4. **Vulnerability scanning** - ECR automatically scans images
5. **Encrypted at rest** - ECR repositories use AES256 encryption

## Cost Optimization

- **Multi-arch builds** - Support both AMD64 and ARM64
- **Layer caching** - Optimized Dockerfile for better caching
- **Image cleanup** - Automatic lifecycle policies
- **Efficient base image** - Slim Python image reduces size

## Monitoring

View ECR repository metrics in AWS Console:
- **Push/Pull events**
- **Image sizes**
- **Vulnerability scan results**
- **Lifecycle policy actions**

---

For more information, see the main [README.md](README.md) file. 