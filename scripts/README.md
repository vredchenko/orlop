# Orlop Scripts

This directory contains utility scripts for the Orlop project.

## 📋 Available Scripts

### 🐳 `docker-build.sh`
**Purpose:** Build and test Docker containers locally before pushing to CI/CD

**Usage:**
```bash
# Basic local build and test
./scripts/docker-build.sh

# Build without cache (fresh build)
./scripts/docker-build.sh --no-cache

# Build and push to registry
./scripts/docker-build.sh --push

# Build with custom tag
./scripts/docker-build.sh --tag debug

# See all options
./scripts/docker-build.sh --help
```

**Features:**
- ✅ Local testing before CI/CD
- ✅ Built-in container validation 
- ✅ Build caching support
- ✅ Version management integration
- ✅ Registry push capabilities

---

### 📦 `version.sh`
**Purpose:** Semantic version management and release creation

**Usage:**
```bash
# Show current version
./scripts/version.sh current

# Bump version and create git tag
./scripts/version.sh bump patch    # 1.2.3 -> 1.2.4
./scripts/version.sh bump minor    # 1.2.3 -> 1.3.0  
./scripts/version.sh bump major    # 1.2.3 -> 2.0.0

# Set specific version
./scripts/version.sh set 2.1.0

# Create GitHub release
./scripts/version.sh release

# Preview next version
./scripts/version.sh next patch
```

**Features:**
- ✅ Semantic versioning (semver)
- ✅ Automatic git tagging
- ✅ GitHub release creation
- ✅ Version file management

---

### 🏗️ `scaffold-ansible-project.sh`
**Purpose:** Generate Ansible project structures

**Usage:**
```bash
./scripts/scaffold-ansible-project.sh
```

---

## 🚀 Recommended Workflow

1. **Development:**
   ```bash
   # Test build locally first
   ./scripts/docker-build.sh --no-cache
   ```

2. **Release:**
   ```bash
   # Bump version and tag
   ./scripts/version.sh bump patch
   
   # Push to trigger CI/CD
   git push origin main --tags
   
   # Create GitHub release (optional)
   ./scripts/version.sh release
   ```

3. **CI/CD Testing:**
   - Use the GitHub Actions manual dispatch
   - Or push commits to trigger automatic builds

## ℹ️ Notes

- All scripts use `#!/usr/bin/env bash` for portability
- Scripts include comprehensive help (`--help` flag)
- Color-coded output for better readability
- Proper error handling and validation