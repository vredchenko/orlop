#!/bin/bash

# Local Docker build testing script
# This allows you to test builds locally before pushing to CI/CD

set -e

echo "🐳 Starting local Docker build test..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    log_error "Docker is not running. Please start Docker first."
    exit 1
fi

# Check if buildx is available
if ! docker buildx version >/dev/null 2>&1; then
    log_error "Docker buildx is not available. Please install Docker Desktop or enable buildx."
    exit 1
fi

# Default values
DOCKERFILE="Dockerfile"
PLATFORMS="linux/amd64"
TAG_NAME="orlop-test"
PUSH=false
CACHE=true

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dockerfile|-f)
            DOCKERFILE="$2"
            shift 2
            ;;
        --platforms|-p)
            PLATFORMS="$2"
            shift 2
            ;;
        --tag|-t)
            TAG_NAME="$2"
            shift 2
            ;;
        --multi-arch)
            PLATFORMS="linux/amd64,linux/arm64"
            shift
            ;;
        --push)
            PUSH=true
            shift
            ;;
        --no-cache)
            CACHE=false
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -f, --dockerfile FILE     Dockerfile to build (default: Dockerfile)"
            echo "  -p, --platforms PLATFORMS Target platforms (default: linux/amd64)"
            echo "  -t, --tag TAG            Tag name (default: orlop-test)"
            echo "      --multi-arch         Build for both amd64 and arm64"
            echo "      --push               Push to registry (requires login)"
            echo "      --no-cache           Disable build cache"
            echo "  -h, --help               Show this help"
            echo ""
            echo "Examples:"
            echo "  $0                       # Basic build for current architecture"
            echo "  $0 --multi-arch          # Build for both amd64 and arm64"
            echo "  $0 -f Dockerfile.test    # Build specific Dockerfile"
            echo "  $0 --no-cache            # Fresh build without cache"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Use --help for usage information."
            exit 1
            ;;
    esac
done

# Validate Dockerfile exists
if [[ ! -f "$DOCKERFILE" ]]; then
    log_error "Dockerfile not found: $DOCKERFILE"
    exit 1
fi

log_info "Configuration:"
log_info "  Dockerfile: $DOCKERFILE"
log_info "  Platforms: $PLATFORMS"
log_info "  Tag: $TAG_NAME"
log_info "  Push: $PUSH"
log_info "  Cache: $CACHE"

# Set up buildx builder if needed for multi-arch
if [[ "$PLATFORMS" == *","* ]]; then
    log_info "Setting up buildx builder for multi-architecture build..."
    
    # Create/use a buildx builder that supports multi-arch
    BUILDER_NAME="orlop-builder"
    if ! docker buildx inspect "$BUILDER_NAME" >/dev/null 2>&1; then
        log_info "Creating buildx builder: $BUILDER_NAME"
        docker buildx create --name "$BUILDER_NAME" --driver docker-container --bootstrap
    fi
    
    docker buildx use "$BUILDER_NAME"
    log_info "Using buildx builder: $BUILDER_NAME"
fi

# Build command
BUILD_CMD="docker buildx build"
BUILD_CMD="$BUILD_CMD --platform $PLATFORMS"
BUILD_CMD="$BUILD_CMD -f $DOCKERFILE"
BUILD_CMD="$BUILD_CMD -t $TAG_NAME"

if [[ "$CACHE" == "true" ]]; then
    BUILD_CMD="$BUILD_CMD --cache-from type=gha --cache-to type=gha,mode=max"
else
    BUILD_CMD="$BUILD_CMD --no-cache"
fi

if [[ "$PUSH" == "true" ]]; then
    BUILD_CMD="$BUILD_CMD --push"
else
    BUILD_CMD="$BUILD_CMD --load"
fi

BUILD_CMD="$BUILD_CMD ."

log_info "Starting build..."
log_info "Command: $BUILD_CMD"

# Execute build
if eval "$BUILD_CMD"; then
    log_info "✅ Build completed successfully!"
    
    if [[ "$PUSH" == "false" && "$PLATFORMS" != *","* ]]; then
        log_info "Image built locally: $TAG_NAME"
        log_info "To test the image:"
        log_info "  docker run --rm -it $TAG_NAME"
        log_info "To inspect the image:"
        log_info "  docker image inspect $TAG_NAME"
    fi
else
    log_error "❌ Build failed!"
    exit 1
fi

log_info "🎉 Local build test completed!"