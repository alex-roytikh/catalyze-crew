#!/bin/bash

# Script to push Docker image to AWS ECR
# Usage: ./scripts/push-to-ecr.sh [version] [region] [account-id] [repository-name]

set -e

# Ensure we use the personal AWS profile
export AWS_PROFILE=personal

# Configuration
PROJECT_NAME="concierge-crewai"
DEFAULT_REGION="us-east-2"

# Parse arguments
VERSION="${1}"
REGION="${2:-$DEFAULT_REGION}"
ACCOUNT_ID="${3}"
REPOSITORY_NAME="${4:-$PROJECT_NAME}"

# Validation
if [ -z "$VERSION" ]; then
    VERSION=$(grep -E '^version = ' pyproject.toml | sed 's/version = "//g' | sed 's/"//g')
    if [ -z "$VERSION" ]; then
        echo "❌ Version required. Usage: $0 [version] [region] [account-id] [repository-name]"
        exit 1
    fi
fi

if [ -z "$ACCOUNT_ID" ]; then
    echo "❌ AWS Account ID required. Usage: $0 [version] [region] [account-id] [repository-name]"
    echo "💡 You can find your account ID with: aws sts get-caller-identity --query Account --output text"
    exit 1
fi

# Generate ECR repository URI
ECR_URI="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"
REPOSITORY_URI="$ECR_URI/$REPOSITORY_NAME"

echo "🚀 Pushing Docker image to AWS ECR"
echo "📦 Project: $PROJECT_NAME"
echo "🏷️  Version: $VERSION"
echo "🌍 Region: $REGION"
echo "🏦 Account: $ACCOUNT_ID"
echo "👤 AWS Profile: $AWS_PROFILE"
echo "📍 Repository: $REPOSITORY_URI"
echo ""

# Check if AWS CLI is available
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI not found. Please install it: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    exit 1
fi

# Authenticate Docker to ECR
echo "🔐 Authenticating Docker to ECR..."
aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "$ECR_URI"

# Check if repository exists, create if it doesn't
echo "🔍 Checking if ECR repository exists..."
REPO_EXISTS=false

# Check if repository exists (more robust check)
if aws ecr describe-repositories --repository-names "$REPOSITORY_NAME" --region "$REGION" --output text --query 'repositories[0].repositoryName' 2>/dev/null | grep -q "$REPOSITORY_NAME"; then
    REPO_EXISTS=true
    echo "✅ ECR repository already exists"
else
    echo "📦 Creating ECR repository: $REPOSITORY_NAME"
    
    # Create repository with retry logic
    if aws ecr create-repository \
        --repository-name "$REPOSITORY_NAME" \
        --region "$REGION" \
        --image-scanning-configuration scanOnPush=true \
        --encryption-configuration encryptionType=AES256 \
        --output text --query 'repository.repositoryName' 2>/dev/null; then
        
        echo "✅ ECR repository created successfully"
        REPO_EXISTS=true
        
        # Set lifecycle policy to manage image versions
        echo "🔄 Setting lifecycle policy..."
        aws ecr put-lifecycle-configuration \
            --repository-name "$REPOSITORY_NAME" \
            --region "$REGION" \
            --lifecycle-policy-text '{
                "rules": [
                    {
                        "rulePriority": 1,
                        "description": "Keep only the latest 10 versions",
                        "selection": {
                            "tagStatus": "tagged",
                            "countType": "imageCountMoreThan",
                            "countNumber": 10
                        },
                        "action": {
                            "type": "expire"
                        }
                    },
                    {
                        "rulePriority": 2,
                        "description": "Delete untagged images older than 1 day",
                        "selection": {
                            "tagStatus": "untagged",
                            "countType": "sinceImagePushed",
                            "countUnit": "days",
                            "countNumber": 1
                        },
                        "action": {
                            "type": "expire"
                        }
                    }
                ]
            }' &>/dev/null || echo "⚠️  Lifecycle policy setting failed (non-critical)"
    else
        echo "❌ Failed to create ECR repository"
        exit 1
    fi
fi

# Ensure repository exists before proceeding
if [ "$REPO_EXISTS" != "true" ]; then
    echo "❌ Repository verification failed"
    exit 1
fi

# Get Git commit for tagging
GIT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

# Tag and push images
echo ""
echo "🏷️  Tagging images for ECR..."
docker tag "$PROJECT_NAME:latest" "$REPOSITORY_URI:latest"
docker tag "$PROJECT_NAME:$VERSION" "$REPOSITORY_URI:$VERSION"
docker tag "$PROJECT_NAME:$VERSION-$GIT_COMMIT" "$REPOSITORY_URI:$VERSION-$GIT_COMMIT"

echo "📤 Pushing images to ECR..."
docker push "$REPOSITORY_URI:latest"
docker push "$REPOSITORY_URI:$VERSION"
docker push "$REPOSITORY_URI:$VERSION-$GIT_COMMIT"

echo ""
echo "✅ Successfully pushed to ECR!"
echo "🎯 Image URIs:"
echo "   - $REPOSITORY_URI:latest"
echo "   - $REPOSITORY_URI:$VERSION"
echo "   - $REPOSITORY_URI:$VERSION-$GIT_COMMIT"
echo ""
echo "💡 To use in CDK/CloudFormation, reference: $REPOSITORY_URI:$VERSION"
echo "🔧 To pull the image: docker pull $REPOSITORY_URI:$VERSION" 