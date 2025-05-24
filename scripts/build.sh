#!/bin/bash

# Build script for concierge-crewai Docker image
# Usage: ./scripts/build.sh [version] [platform]

set -e

# Ensure we use the personal AWS profile if we need AWS calls later
export AWS_PROFILE=personal

# Configuration
PROJECT_NAME="concierge-crewai"
DEFAULT_PLATFORM="linux/amd64"  # Changed from multi-platform for local compatibility

# Show help if requested
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "Build script for $PROJECT_NAME Docker image"
    echo ""
    echo "Usage: $0 [version] [platform]"
    echo ""
    echo "Arguments:"
    echo "  version   Version to build (defaults to version from pyproject.toml)"
    echo "  platform  Target platform(s) (default: $DEFAULT_PLATFORM)"
    echo ""
    echo "Examples:"
    echo "  $0                    # Use version from pyproject.toml"
    echo "  $0 1.2.3             # Build specific version"
    echo "  $0 1.2.3 linux/amd64 # Build for specific platform"
    echo "  $0 1.2.3 linux/amd64,linux/arm64 # Multi-platform (for CI/CD)"
    echo ""
    exit 0
fi

# Get version from argument or pyproject.toml
if [ -n "$1" ]; then
    VERSION="$1"
    # Basic validation for version format
    if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+.*$ ]]; then
        echo "❌ Invalid version format: $VERSION"
        echo "💡 Version should be in format: major.minor.patch (e.g., 1.2.3)"
        exit 1
    fi
else
    VERSION=$(grep -E '^version = ' pyproject.toml | sed 's/version = "//g' | sed 's/"//g')
    if [ -z "$VERSION" ]; then
        echo "❌ Could not determine version. Please provide version as argument or set in pyproject.toml"
        exit 1
    fi
fi

# Get platform from argument or use default
PLATFORM="${2:-$DEFAULT_PLATFORM}"

# Generate build tags
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
GIT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

echo "🏗️  Building Docker image for $PROJECT_NAME"
echo "📦 Version: $VERSION"
echo "🏗️  Platform: $PLATFORM"
echo "📅 Build Date: $BUILD_DATE"
echo "📝 Git Commit: $GIT_COMMIT"
echo ""

# Check if multi-platform build and adjust accordingly
if [[ "$PLATFORM" == *","* ]]; then
    echo "🌐 Multi-platform build detected - using buildx without --load"
    docker buildx build \
        --platform "$PLATFORM" \
        --tag "$PROJECT_NAME:latest" \
        --tag "$PROJECT_NAME:$VERSION" \
        --tag "$PROJECT_NAME:$VERSION-$GIT_COMMIT" \
        --build-arg VERSION="$VERSION" \
        --build-arg BUILD_DATE="$BUILD_DATE" \
        --build-arg GIT_COMMIT="$GIT_COMMIT" \
        .
else
    echo "🖥️  Single platform build - loading to local Docker"
    docker buildx build \
        --platform "$PLATFORM" \
        --tag "$PROJECT_NAME:latest" \
        --tag "$PROJECT_NAME:$VERSION" \
        --tag "$PROJECT_NAME:$VERSION-$GIT_COMMIT" \
        --build-arg VERSION="$VERSION" \
        --build-arg BUILD_DATE="$BUILD_DATE" \
        --build-arg GIT_COMMIT="$GIT_COMMIT" \
        --load \
        .
fi

echo ""
echo "✅ Build completed successfully!"
echo "🏷️  Created tags:"
echo "   - $PROJECT_NAME:latest"
echo "   - $PROJECT_NAME:$VERSION"
echo "   - $PROJECT_NAME:$VERSION-$GIT_COMMIT"
echo ""
echo "🚀 To push to ECR, run: ./scripts/push-to-ecr.sh $VERSION [region] [account-id]" 