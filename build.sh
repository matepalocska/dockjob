#! /usr/bin/env bash

source ./_repo_vars.sh

TAG=${BUILD_IMAGE_NAME_AND_TAG}
VERSION="local"
if [ $# -ne 0 ]; then
    TAG=${1}
    VERSION=${2}
    echo "Tag provided: ${TAG}"
    echo "Version provided: ${VERSION}"
fi

echo "Building project ${PROJECT_NAME} to image ${TAG}"

# Platform detection (Mac M1/M2 arm64, Linux/Intel amd64)
PLATFORM=$(uname -m)
case $PLATFORM in
    aarch64|arm64)
        TARGET_PLATFORM="linux/arm64"
        ;;
    x86_64|amd64)
        TARGET_PLATFORM="linux/amd64"
        ;;
    *)
        TARGET_PLATFORM="linux/amd64"
        ;;
esac

echo "Detected platform: ${PLATFORM}, using Docker target: ${TARGET_PLATFORM}"

# Buildx create ha nincs (multi-platform support)
docker buildx inspect docker-container >/dev/null 2>&1 || docker buildx create --name docker-container --driver docker-container --use

# Build: --pull mindig friss base image-eket húz
docker buildx build \
  --platform ${TARGET_PLATFORM} \
  --pull \
  --load \
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
exit 0
