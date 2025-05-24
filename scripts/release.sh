#!/bin/bash

# Release script for complete versioning and ECR deployment
# Usage: ./scripts/release.sh [major|minor|patch] [account-id] [region]

set -e

# Ensure we use the personal AWS profile
export AWS_PROFILE=personal

# Configuration
DEFAULT_REGION="us-east-2"

# Parse arguments
BUMP_TYPE="${1:-patch}"
ACCOUNT_ID="${2}"
REGION="${3:-$DEFAULT_REGION}"

if [ -z "$ACCOUNT_ID" ]; then
    echo "❌ Usage: $0 [major|minor|patch] [account-id] [region]"
    echo "💡 Examples:"
    echo "   $0 patch 633623909681                    # Patch release to default region"
    echo "   $0 minor 633623909681 us-west-2          # Minor release to custom region"
    echo "   $0 major 633623909681 eu-west-1          # Major release to EU"
    exit 1
fi

echo "🚀 Starting release process"
echo "📈 Bump type: $BUMP_TYPE"
echo "🏦 Account: $ACCOUNT_ID"
echo "🌍 Region: $REGION"
echo "👤 AWS Profile: $AWS_PROFILE"
echo ""

# Get current version
CURRENT_VERSION=$(grep -E '^version = ' pyproject.toml | sed 's/version = "//g' | sed 's/"//g')
echo "📦 Current version: $CURRENT_VERSION"

# Parse version numbers
IFS='.' read -ra VERSION_PARTS <<< "$CURRENT_VERSION"
MAJOR=${VERSION_PARTS[0]}
MINOR=${VERSION_PARTS[1]}
PATCH=${VERSION_PARTS[2]}

# Bump version based on type
case $BUMP_TYPE in
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        ;;
    minor)
        MINOR=$((MINOR + 1))
        PATCH=0
        ;;
    patch)
        PATCH=$((PATCH + 1))
        ;;
    *)
        echo "❌ Invalid bump type: $BUMP_TYPE. Use major, minor, or patch"
        exit 1
        ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"
echo "🎯 New version: $NEW_VERSION"

# Update version in pyproject.toml
echo "📝 Updating pyproject.toml..."
sed -i.bak "s/version = \"$CURRENT_VERSION\"/version = \"$NEW_VERSION\"/" pyproject.toml
rm pyproject.toml.bak

# Commit version bump
echo "📋 Committing version bump..."
git add pyproject.toml
git commit -m "chore: bump version to $NEW_VERSION"

# Create git tag
echo "🏷️  Creating git tag..."
git tag -a "v$NEW_VERSION" -m "Release v$NEW_VERSION"

echo ""
echo "🏗️  Building and deploying..."

# Run deployment
./scripts/deploy.sh "$ACCOUNT_ID" "$REGION"

echo ""
echo "✅ Release completed successfully!"
echo "🎉 Version $NEW_VERSION has been:"
echo "   - ✅ Updated in pyproject.toml"
echo "   - ✅ Committed to git"
echo "   - ✅ Tagged as v$NEW_VERSION"
echo "   - ✅ Built as Docker image"
echo "   - ✅ Pushed to ECR"
echo ""
echo "💡 Don't forget to push your changes:"
echo "   git push origin main --tags"
echo ""
echo "🔧 ECR Image URI: $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/concierge-crewai:$NEW_VERSION" 