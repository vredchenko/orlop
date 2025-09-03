#!/usr/bin/env bash
# Versioning utility for Orlop project

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
VERSION_FILE="$PROJECT_ROOT/VERSION"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

usage() {
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  current                    Show current version"
    echo "  bump <major|minor|patch>   Bump version and create git tag"
    echo "  set <version>              Set specific version"
    echo "  next <major|minor|patch>   Show what next version would be"
    echo "  release                    Create release with current version"
    echo ""
    echo "Examples:"
    echo "  $0 current                 # Shows: 1.2.3"
    echo "  $0 next patch              # Shows: 1.2.4"
    echo "  $0 bump minor              # 1.2.3 -> 1.3.0, creates git tag"
    echo "  $0 set 2.0.0              # Sets version to 2.0.0"
    echo "  $0 release                 # Creates GitHub release"
    exit 1
}

get_current_version() {
    if [[ -f "$VERSION_FILE" ]]; then
        cat "$VERSION_FILE"
    else
        echo "0.1.0"
    fi
}

validate_version() {
    local version=$1
    if [[ ! $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo -e "${RED}Error: Invalid version format. Use semantic versioning (x.y.z)${NC}" >&2
        exit 1
    fi
}

set_version() {
    local version=$1
    validate_version "$version"
    echo "$version" > "$VERSION_FILE"
    echo -e "${GREEN}Version set to $version${NC}"
}

get_next_version() {
    local current=$(get_current_version)
    local bump_type=$1
    
    IFS='.' read -ra VERSION_PARTS <<< "$current"
    local major=${VERSION_PARTS[0]}
    local minor=${VERSION_PARTS[1]}
    local patch=${VERSION_PARTS[2]}
    
    case $bump_type in
        major)
            echo "$((major + 1)).0.0"
            ;;
        minor)
            echo "$major.$((minor + 1)).0"
            ;;
        patch)
            echo "$major.$minor.$((patch + 1))"
            ;;
        *)
            echo -e "${RED}Error: Invalid bump type. Use major, minor, or patch${NC}" >&2
            exit 1
            ;;
    esac
}

bump_version() {
    local bump_type=$1
    local current=$(get_current_version)
    local new_version=$(get_next_version "$bump_type")
    
    echo -e "${BLUE}Bumping version: $current -> $new_version${NC}"
    
    # Set new version
    set_version "$new_version"
    
    # Create git tag if in git repository
    if git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${YELLOW}Creating git tag v$new_version${NC}"
        git add "$VERSION_FILE"
        git commit -m "chore: bump version to $new_version"
        git tag -a "v$new_version" -m "Release version $new_version"
        echo -e "${GREEN}Created tag v$new_version${NC}"
        echo -e "${BLUE}Push with: git push origin main --tags${NC}"
    else
        echo -e "${YELLOW}Not in a git repository, skipping tag creation${NC}"
    fi
}

create_release() {
    local version=$(get_current_version)
    
    # Check if gh CLI is available
    if ! command -v gh &> /dev/null; then
        echo -e "${RED}Error: GitHub CLI (gh) is not installed${NC}" >&2
        echo "Install it from: https://cli.github.com/"
        exit 1
    fi
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${RED}Error: Not in a git repository${NC}" >&2
        exit 1
    fi
    
    # Check if tag exists
    if ! git tag -l "v$version" | grep -q "v$version"; then
        echo -e "${RED}Error: Tag v$version does not exist${NC}" >&2
        echo "Run: $0 bump <type> first"
        exit 1
    fi
    
    echo -e "${BLUE}Creating GitHub release for v$version${NC}"
    
    # Generate release notes
    local release_notes="## 🚀 Orlop CLI Toolbelt v$version

### 📦 What's Included
- **Latest versions** of all CLI tools installed from GitHub releases
- **Multi-platform support** (linux/amd64, linux/arm64)
- **Pre-configured environment** with starship prompt and useful aliases

### 🛠️ Tools Included
- ripgrep, bat, delta, fzf, starship
- gdu, lsd, micro, gron, fd
- hexyl, hyperfine, procs, tokei, bottom, dust

### 🐳 Usage
\`\`\`bash
docker pull ghcr.io/${GITHUB_REPOSITORY:-orlop}/orlop:$version
docker run -it ghcr.io/${GITHUB_REPOSITORY:-orlop}/orlop:$version
\`\`\`

### 🔧 Manual Build Trigger
Use the GitHub Actions manual dispatch to build and publish:
1. Go to Actions tab
2. Select 'Build and Publish Orlop Container'
3. Click 'Run workflow'
4. Enter version: \`$version\`

---
*Built with ❤️ using GitHub Actions*"
    
    # Create the release
    gh release create "v$version" \
        --title "Orlop CLI Toolbelt v$version" \
        --notes "$release_notes" \
        --latest
    
    echo -e "${GREEN}Release v$version created successfully!${NC}"
    echo -e "${BLUE}View at: $(gh repo view --web)/releases/tag/v$version${NC}"
}

# Main command handling
case ${1:-} in
    current)
        get_current_version
        ;;
    next)
        if [[ -z ${2:-} ]]; then
            echo -e "${RED}Error: Please specify bump type (major|minor|patch)${NC}" >&2
            usage
        fi
        get_next_version "$2"
        ;;
    bump)
        if [[ -z ${2:-} ]]; then
            echo -e "${RED}Error: Please specify bump type (major|minor|patch)${NC}" >&2
            usage
        fi
        bump_version "$2"
        ;;
    set)
        if [[ -z ${2:-} ]]; then
            echo -e "${RED}Error: Please specify version${NC}" >&2
            usage
        fi
        set_version "$2"
        ;;
    release)
        create_release
        ;;
    *)
        usage
        ;;
esac