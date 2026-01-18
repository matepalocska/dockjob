#!/bin/bash

# Build and push DockJob to Docker Hub with multi-platform support
# Usage: ./build-and-push-dockerhub.sh [username] [tag-suffix]

set -e

# Configuration
DOCKER_USERNAME=${1:-"matepalocska"}
TAG_SUFFIX=${2:-""}
VERSION=$(cat VERSION)
IMAGE_NAME="$DOCKER_USERNAME/dockjob"

# Build versioned tag
if [ -n "$TAG_SUFFIX" ]; then
    FULL_TAG="$IMAGE_NAME:$VERSION-$TAG_SUFFIX"
else
    FULL_TAG="$IMAGE_NAME:$VERSION"
fi

echo "Building multi-platform Docker image: $FULL_TAG"
echo "Platforms: linux/amd64, linux/arm64"

# Ensure buildx builder exists and supports multi-platform
docker buildx inspect docker-container-multiplatform >/dev/null 2>&1 || \
  docker buildx create --name docker-container-multiplatform --driver docker-container --use

# Use the multi-platform builder
docker buildx use docker-container-multiplatform

# Multi-platform build and push directly to Docker Hub
echo "Building and pushing $FULL_TAG (multi-platform)..."
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --pull \
  --push \
  -t "$FULL_TAG" \
  -t "$IMAGE_NAME:latest" \
  --build-arg RJM_BUILDQUASARAPP_IMAGE=metcarob/docker-build-quasar-app:0.0.30 \
  --build-arg RJM_VERSION="$VERSION" \
  .

echo ""
echo "✅ Successfully pushed multi-platform image to Docker Hub!"
echo "   Versioned tag: $FULL_TAG"
echo "   Latest tag: $IMAGE_NAME:latest"
echo "   Platforms: linux/amd64, linux/arm64"
echo ""
echo "You can now pull the image with:"
echo "   docker pull $IMAGE_NAME:latest"
echo "   docker pull $FULL_TAG"
echo ""
echo "The image will automatically use the correct architecture for your platform."