#!/usr/bin/env bash
# Build script for Orlop container

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
VERSION_FILE="$PROJECT_ROOT/VERSION"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default values
DOCKERFILE="Dockerfile"
PLATFORMS="linux/amd64"
PUSH=false
CACHE=true
TEST=true

usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -f, --dockerfile FILE      Dockerfile to use (default: Dockerfile)"
    echo "  -t, --tag TAG             Additional tag for the image"
    echo "  -p, --platforms PLATFORMS Target platforms (default: linux/amd64)"
    echo "      --push                Push to registry after build"
    echo "      --no-cache            Disable build cache"
    echo "      --no-test             Skip container testing"
    echo "  -h, --help                Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Build locally"
    echo "  $0 --push                            # Build and push to registry"
    echo "  $0 -p linux/amd64,linux/arm64       # Multi-platform build"
    echo "  $0 -f Dockerfile --tag debug        # Use different Dockerfile with custom tag"
    exit 1
}

get_version() {
    if [[ -f "$VERSION_FILE" ]]; then
        cat "$VERSION_FILE"
    else
        echo "dev"
    fi
}

log() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}" >&2
    exit 1
}

success() {
    echo -e "${GREEN}[SUCCESS] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

check_dependencies() {
    log "Checking dependencies..."
    
    if ! command -v docker &> /dev/null; then
        error "Docker is not installed or not in PATH"
    fi
    
    # Check if buildx is available for multi-platform builds
    if [[ "$PLATFORMS" == *","* ]] && ! docker buildx version &> /dev/null; then
        error "Docker Buildx is required for multi-platform builds"
    fi
    
    success "All dependencies available"
}

setup_builder() {
    if [[ "$PLATFORMS" == *","* ]]; then
        log "Setting up multi-platform builder..."
        
        # Create buildx builder if it doesn't exist
        if ! docker buildx inspect orlop-builder &> /dev/null; then
            log "Creating new buildx builder: orlop-builder"
            docker buildx create --name orlop-builder --use --bootstrap
        else
            log "Using existing buildx builder: orlop-builder"
            docker buildx use orlop-builder
        fi
    fi
}

build_image() {
    local version=$(get_version)
    local image_name="orlopdeck"
    local registry_name="ghcr.io/$(whoami)/orlop"  # Will be overridden in CI
    
    log "Building container image..."
    log "Version: $version"
    log "Dockerfile: $DOCKERFILE"
    log "Platforms: $PLATFORMS"
    
    # Build tags
    local tags=()
    tags+=("$image_name:$version")
    tags+=("$image_name:latest")
    
    if [[ -n "${CUSTOM_TAG:-}" ]]; then
        tags+=("$image_name:$CUSTOM_TAG")
    fi
    
    # Add registry tags if pushing
    if [[ "$PUSH" == "true" ]]; then
        for tag in "${tags[@]}"; do
            tags+=("$registry_name:${tag#*:}")
        done
    fi
    
    # Build tag arguments
    local tag_args=()
    for tag in "${tags[@]}"; do
        tag_args+=("-t" "$tag")
    done
    
    # Build cache arguments
    local cache_args=()
    if [[ "$CACHE" == "true" ]]; then
        cache_args+=("--cache-from" "type=local,src=/tmp/.buildx-cache")
        cache_args+=("--cache-to" "type=local,dest=/tmp/.buildx-cache-new,mode=max")
    fi
    
    # Build command
    local build_cmd=("docker")
    
    if [[ "$PLATFORMS" == *","* ]]; then
        build_cmd+=("buildx" "build")
        build_cmd+=("--platform" "$PLATFORMS")
        if [[ "$PUSH" == "true" ]]; then
            build_cmd+=("--push")
        fi
    else
        build_cmd+=("build")
        if [[ "$PUSH" == "true" ]]; then
            warn "Push is enabled but not using buildx. Image will be built but not pushed."
        fi
    fi
    
    build_cmd+=("${tag_args[@]}")
    build_cmd+=("${cache_args[@]}")
    build_cmd+=("-f" "$DOCKERFILE")
    build_cmd+=("--progress" "plain")
    build_cmd+=(".")
    
    log "Running: ${build_cmd[*]}"
    
    cd "$PROJECT_ROOT"
    "${build_cmd[@]}"
    
    # Move cache
    if [[ "$CACHE" == "true" && -d "/tmp/.buildx-cache-new" ]]; then
        rm -rf /tmp/.buildx-cache
        mv /tmp/.buildx-cache-new /tmp/.buildx-cache
    fi
    
    success "Build completed successfully"
    
    # Show built images
    if [[ "$PLATFORMS" != *","* ]]; then
        log "Built images:"
        for tag in "${tags[@]}"; do
            if docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}" | grep -q "${tag}"; then
                echo "  - $tag"
            fi
        done
    fi
}

test_container() {
    if [[ "$TEST" != "true" ]]; then
        log "Skipping container tests (disabled)"
        return
    fi
    
    if [[ "$PLATFORMS" == *","* ]]; then
        log "Skipping container tests (multi-platform build)"
        return
    fi
    
    local version=$(get_version)
    local image_name="orlopdeck:$version"
    
    log "Testing container: $image_name"
    
    # Test basic functionality
    log "Running basic container test..."
    docker run --rm "$image_name" -c "
        echo '=== Container Test ==='
        echo 'User:' \$(whoami)
        echo 'Working Directory:' \$(pwd)
        echo ''
        echo '=== Tool Availability ==='
        command -v rg && echo '✓ ripgrep' || echo '✗ ripgrep'
        command -v bat && echo '✓ bat' || echo '✗ bat'
        command -v delta && echo '✓ delta' || echo '✗ delta'
        command -v fzf && echo '✓ fzf' || echo '✗ fzf'
        command -v starship && echo '✓ starship' || echo '✗ starship'
        command -v gdu && echo '✓ gdu' || echo '✗ gdu'
        command -v lsd && echo '✓ lsd' || echo '✗ lsd'
        command -v micro && echo '✓ micro' || echo '✗ micro'
        echo ''
        echo '✅ Container test completed'
    " || error "Container test failed"
    
    success "Container tests passed"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--dockerfile)
            DOCKERFILE="$2"
            shift 2
            ;;
        -t|--tag)
            CUSTOM_TAG="$2"
            shift 2
            ;;
        -p|--platforms)
            PLATFORMS="$2"
            shift 2
            ;;
        --push)
            PUSH=true
            shift
            ;;
        --no-cache)
            CACHE=false
            shift
            ;;
        --no-test)
            TEST=false
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            error "Unknown option: $1"
            ;;
    esac
done

# Validate Dockerfile exists
if [[ ! -f "$PROJECT_ROOT/$DOCKERFILE" ]]; then
    error "Dockerfile not found: $DOCKERFILE"
fi

# Main execution
main() {
    log "Starting Orlop container build..."
    
    check_dependencies
    setup_builder
    build_image
    test_container
    
    success "Build process completed successfully!"
    
    local version=$(get_version)
    echo ""
    echo "🚀 Container built: orlopdeck:$version"
    echo ""
    echo "Usage:"
    echo "  docker run -it orlopdeck:$version"
    echo ""
    
    if [[ "$PUSH" == "true" ]]; then
        echo "📦 Image pushed to registry"
    else
        echo "💡 To push to registry, use: $0 --push"
    fi
}

main