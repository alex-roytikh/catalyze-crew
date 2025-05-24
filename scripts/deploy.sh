#!/bin/bash

# Simple ECR deployment script
# Usage: ./scripts/deploy.sh [account-id] [region]

set -e

# Ensure we use the personal AWS profile
export AWS_PROFILE=personal

# Configuration with sensible defaults
PROJECT_NAME="concierge-crewai"
DEFAULT_REGION="us-east-2"

# Parse arguments
ACCOUNT_ID="${1}"
REGION="${2:-$DEFAULT_REGION}"

if [ -z "$ACCOUNT_ID" ]; then
    echo "❌ Usage: $0 [account-id] [region]"
    echo "💡 Examples:"
    echo "   $0 633623909681                    # Use default region ($DEFAULT_REGION)"
    echo "   $0 633623909681 us-west-2          # Use custom region"
    echo "   $0 633623909681 eu-west-1          # Use EU region"
    exit 1
fi

# Get version from pyproject.toml
VERSION=$(grep -E '^version = ' pyproject.toml | sed 's/version = "//g' | sed 's/"//g')
if [ -z "$VERSION" ]; then
    echo "❌ Could not determine version from pyproject.toml"
    exit 1
fi

echo "🚀 Deploying $PROJECT_NAME to ECR"
echo "📦 Version: $VERSION"
echo "🏦 Account: $ACCOUNT_ID"
echo "🌍 Region: $REGION"
echo "👤 AWS Profile: $AWS_PROFILE"
echo ""

# Step 1: Build the image
echo "🏗️  Building Docker image..."
./scripts/build.sh "$VERSION"

# Step 2: Push to ECR
echo "📤 Pushing to ECR..."
./scripts/push-to-ecr.sh "$VERSION" "$REGION" "$ACCOUNT_ID"

echo ""
echo "✅ Deployment completed successfully!"
echo "🎯 Image URI: $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$PROJECT_NAME:$VERSION"
echo ""
echo "🔧 To use in CDK:"
echo "   Repository.fromRepositoryName(this, 'Repo', '$PROJECT_NAME')"
echo "   ContainerImage.fromEcrRepository(repo, '$VERSION')" 