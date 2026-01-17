#!/bin/bash

# Multi-platform build script for DockJob
# Usage: ./build-multiplatform.sh [tag] [version] [push]

source ./_repo_vars.sh

TAG=${BUILD_IMAGE_NAME_AND_TAG}
VERSION="local"
PUSH_FLAG=""

if [ $# -ge 1 ]; then
    TAG=${1}
fi
if [ $# -ge 2 ]; then
    VERSION=${2}
fi
if [ "$3" = "push" ]; then
    PUSH_FLAG="--push"
    echo "Will push to registry"
else
    PUSH_FLAG="--load"
    echo "Will load locally (ARM64 only due to --load limitation)"
fi

echo "Building project ${PROJECT_NAME} to image ${TAG}"
echo "Version: ${VERSION}"
echo "Building for platforms: linux/amd64, linux/arm64"

# Ensure buildx builder exists and supports multi-platform
docker buildx inspect docker-container-multiplatform >/dev/null 2>&1 || \
  docker buildx create --name docker-container-multiplatform --driver docker-container

# Use the multi-platform builder
docker buildx use docker-container-multiplatform

# Multi-platform build
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --pull \
  $PUSH_FLAG \
  -t ${TAG} \
  --build-arg RJM_BUILDQUASARAPP_IMAGE=${RJM_BUILDQUASARAPP_IMAGE} \
  --build-arg RJM_VERSION=${VERSION} \
  .

BUILD_RES=$?
if [[ ${BUILD_RES} -ne 0 ]]; then
    echo "Build failed - ${BUILD_RES}"
    exit 1
fi

echo "Build successful: ${TAG}"
if [ "$3" = "push" ]; then
    echo "Image pushed to registry with multi-platform support (linux/amd64, linux/arm64)"
else
    echo "Image loaded locally (ARM64 architecture only)"
    echo "Note: --load only supports single platform. Use 'push' flag for multi-platform registry push."
fi

exit 0