# Orlop Deck - CLI Tools Container

**What's with the naming?**

> The orlop is the lowest deck in a ship (except for very old ships).
> It is the deck or part of a deck where the cables are stowed, usually below the water line.

https://en.wikipedia.org/wiki/Orlop_deck

## Overview

Orlop Deck provides modern CLI tools for development and system administration in two ways:

1. **Ansible Playbook** - Install tools directly on host systems
2. **Docker Container** - Package tools in an isolated container

All tools are installed from their latest GitHub releases and work identically in both environments.

## Included Tools

- **ripgrep** - Fast text search
- **bat** - Syntax-highlighted file viewer
- **fd** - Fast file finder (TODO: Add to Ansible)
- **delta** - Git diff viewer
- **lsd** - Modern ls replacement
- **gdu** - Disk usage analyzer
- **fzf** - Fuzzy finder
- **starship** - Cross-shell prompt
- **tokei** - Code statistics (TODO: Add to Ansible)
- **hexyl** - Hex viewer (TODO: Add to Ansible)
- **hyperfine** - Benchmarking tool (TODO: Add to Ansible)
- **procs** - Modern ps replacement (TODO: Add to Ansible)
- **bottom** - System monitor (TODO: Add to Ansible)
- **gron** - JSON processor
- **micro** - Terminal editor
- **glab** - GitLab CLI
- **gh** - GitHub CLI
- **dust** - Alternative disk usage analyzer (TODO: Add to Ansible)
- **mc** - MinIO/S3 client

## Quick Start

```bash
# Build container
make build

# Test container
make test

# Run interactive shell
make shell
```

## Build System

- **Docker**: Container runtime
- **Ansible**: Tool installation definitions
- **Make**: Build orchestration
- **GitHub Actions**: Automated CI/CD

## Installation Methods

### Method 1: Ansible (Direct Host Installation)
Install tools directly on your system or remote hosts:

```bash
cd ansible
# Test connectivity
ansible all -i inventory/hosts.yml -m ping

# Install tools on target hosts
ansible-playbook -i inventory/hosts.yml playbooks/site.yml
```

### Method 2: Container (Isolated Environment)
Use tools in an isolated container:

```bash
# Build container
make build

# Run tools in container
docker run --rm -it orlopdeck:latest bash

# Or use individual tools
docker run --rm -v "$PWD:/workspace" orlopdeck:latest rg "pattern" /workspace
```

## Development

### Ansible Development
```bash
# Generate new Ansible project structure
./scripts/scaffold-ansible-project.sh

# Test playbook syntax
ansible-playbook --syntax-check ansible/playbooks/site.yml

# Run playbook in check mode
ansible-playbook -i ansible/inventory/hosts.yml ansible/playbooks/site.yml --check
```

### Container Development
```bash
# Build container
make build

# Multi-platform build
make build-multi

# Build and push to registry
make push

# Version management
make version-current
make version-bump-patch
make release
```

## CI/CD

Automated builds are triggered on:
- Manual workflow dispatch
- Version tags
- Main branch pushes

Multi-platform builds (amd64/arm64) are published to GitHub Container Registry.
