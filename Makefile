# Orlop Container Build System
.PHONY: help build push test clean version-current version-bump release dev multi-platform install-tools

# Default target
.DEFAULT_GOAL := help

# Variables
DOCKERFILE ?= Dockerfile
VERSION := $(shell cat VERSION 2>/dev/null || echo "dev")
IMAGE_NAME := orlopdeck
REGISTRY := ghcr.io/$(shell git config --get remote.origin.url | sed 's/.*github\.com[:/]\([^/]*\)\/\([^/.]*\).*/\1/' | tr '[:upper:]' '[:lower:]')/orlop

help: ## Show this help message
	@echo "Orlop Container Build System"
	@echo ""
	@echo "Available targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "Current version: $(VERSION)"
	@echo "Container image: $(IMAGE_NAME):$(VERSION)"

build: ## Build container locally (single platform)
	@echo "🔨 Building $(IMAGE_NAME):$(VERSION)..."
	./scripts/build.sh -f $(DOCKERFILE)

build-multi: ## Build container for multiple platforms
	@echo "🔨 Building multi-platform $(IMAGE_NAME):$(VERSION)..."
	./scripts/build.sh -f $(DOCKERFILE) -p linux/amd64,linux/arm64

push: ## Build and push to registry
	@echo "🚀 Building and pushing $(IMAGE_NAME):$(VERSION)..."
	./scripts/build.sh -f $(DOCKERFILE) --push

push-multi: ## Build and push multi-platform to registry
	@echo "🚀 Building and pushing multi-platform $(IMAGE_NAME):$(VERSION)..."
	./scripts/build.sh -f $(DOCKERFILE) -p linux/amd64,linux/arm64 --push

test: ## Test built container
	@echo "🧪 Testing $(IMAGE_NAME):$(VERSION)..."
	@if docker images $(IMAGE_NAME):$(VERSION) -q | grep -q .; then \
		docker run --rm $(IMAGE_NAME):$(VERSION) -c "echo '=== Tool Tests ===' && rg --version && bat --version && echo '✅ Tests passed'"; \
	else \
		echo "❌ Image $(IMAGE_NAME):$(VERSION) not found. Run 'make build' first."; \
		exit 1; \
	fi

dev: ## Build and run container in development mode
	@echo "🛠️ Building and starting development container..."
	./scripts/build.sh -f $(DOCKERFILE) --no-test
	docker run -it --rm \
		-v $(PWD):/workspace \
		-w /workspace \
		$(IMAGE_NAME):$(VERSION) \
		bash

clean: ## Clean up Docker images and build cache
	@echo "🧹 Cleaning up..."
	-docker images $(IMAGE_NAME) -q | xargs docker rmi -f
	-docker builder prune -f
	@echo "✅ Cleanup completed"

version-current: ## Show current version
	@./scripts/version.sh current

version-bump-patch: ## Bump patch version (x.y.z -> x.y.z+1)
	@./scripts/version.sh bump patch

version-bump-minor: ## Bump minor version (x.y.z -> x.y+1.0)
	@./scripts/version.sh bump minor

version-bump-major: ## Bump major version (x.y.z -> x+1.0.0)
	@./scripts/version.sh bump major

version-set: ## Set specific version (usage: make version-set VERSION=1.2.3)
	@if [ -z "$(VERSION_NEW)" ]; then \
		echo "Usage: make version-set VERSION_NEW=x.y.z"; \
		exit 1; \
	fi
	@./scripts/version.sh set $(VERSION_NEW)

release: ## Create GitHub release with current version
	@./scripts/version.sh release

# Docker development helpers
shell: ## Open shell in running container
	docker run -it --rm $(IMAGE_NAME):$(VERSION) bash

logs: ## Show container logs (for debugging builds)
	@echo "Recent Docker build logs:"
	docker system events --since 1h --filter type=container

inspect: ## Inspect built image
	@if docker images $(IMAGE_NAME):$(VERSION) -q | grep -q .; then \
		echo "=== Image Information ==="; \
		docker images $(IMAGE_NAME):$(VERSION); \
		echo ""; \
		echo "=== Image History ==="; \
		docker history $(IMAGE_NAME):$(VERSION) --no-trunc; \
	else \
		echo "❌ Image $(IMAGE_NAME):$(VERSION) not found"; \
		exit 1; \
	fi

# CI/CD helpers
ci-build: ## CI build (used by GitHub Actions)
	@echo "🏗️ CI Build starting..."
	./scripts/build.sh -f $(DOCKERFILE) -p linux/amd64,linux/arm64 --push --no-test

# Development workflow
install-tools: ## Install development tools locally
	@echo "📦 Installing development tools..."
	@if ! command -v gh >/dev/null 2>&1; then \
		echo "Installing GitHub CLI..."; \
		curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg; \
		echo "deb [arch=$$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list; \
		sudo apt update && sudo apt install gh; \
	fi
	@if ! docker buildx version >/dev/null 2>&1; then \
		echo "Installing Docker Buildx..."; \
		mkdir -p ~/.docker/cli-plugins; \
		curl -L "https://github.com/docker/buildx/releases/latest/download/buildx-$$(uname -s | tr '[:upper:]' '[:lower:]')-$$(uname -m)" -o ~/.docker/cli-plugins/docker-buildx; \
		chmod +x ~/.docker/cli-plugins/docker-buildx; \
	fi
	@echo "✅ Development tools installed"

# Quick workflow targets
patch: version-bump-patch build ## Bump patch version and build
minor: version-bump-minor build ## Bump minor version and build
major: version-bump-major build ## Bump major version and build

ship: push release ## Build, push, and create release (for current version)




# Status and info
status: ## Show project status
	@echo "=== Orlop Project Status ==="
	@echo "Version: $(VERSION)"
	@echo "Image: $(IMAGE_NAME):$(VERSION)"
	@echo "Registry: $(REGISTRY)"
	@echo "Dockerfile: $(DOCKERFILE)"
	@echo ""
	@echo "=== Git Status ==="
	@if git rev-parse --git-dir >/dev/null 2>&1; then \
		echo "Branch: $$(git branch --show-current)"; \
		echo "Commit: $$(git rev-parse --short HEAD)"; \
		echo "Status: $$(git status --porcelain | wc -l) files changed"; \
	else \
		echo "Not a git repository"; \
	fi
	@echo ""
	@echo "=== Docker Status ==="
	@echo "Docker: $$(docker --version)"
	@if docker buildx version >/dev/null 2>&1; then \
		echo "Buildx: $$(docker buildx version)"; \
	else \
		echo "Buildx: Not installed"; \
	fi
