#!/usr/bin/env bash

# Ansible project scaffolding script
# Creates a new Ansible project structure with specified roles

set -e  # Exit on any error

PROJECT_DIR="ansible"
ROLES=(ripgrep gron fzf bat delta lsd gdu micro)

echo "🚀 Creating Ansible project structure in ${PROJECT_DIR}/"

# Create main project directory
mkdir -p "${PROJECT_DIR}"
cd "${PROJECT_DIR}"

# Create main Ansible directories
mkdir -p {inventory,group_vars,host_vars,roles,playbooks,files,templates,vault}

echo "📁 Created main directories"

# Create roles structure
for role in "${ROLES[@]}"; do
    echo "📦 Creating role: ${role}"
    mkdir -p "roles/${role}"/{tasks,handlers,templates,files,vars,defaults,meta}
    
    # Create main.yml files for each role subdirectory
    cat > "roles/${role}/tasks/main.yml" << EOF
---
# Tasks for ${role} role
- name: Install ${role}
  package:
    name: ${role}
    state: present
  tags:
    - ${role}
    - packages
EOF

    cat > "roles/${role}/handlers/main.yml" << EOF
---
# Handlers for ${role} role
EOF

    cat > "roles/${role}/vars/main.yml" << EOF
---
# Variables for ${role} role
EOF

    cat > "roles/${role}/defaults/main.yml" << EOF
---
# Default variables for ${role} role
${role}_state: present
EOF

    cat > "roles/${role}/meta/main.yml" << EOF
---
galaxy_info:
  author: $(whoami)
  description: Install and configure ${role}
  license: MIT
  min_ansible_version: 2.9
  platforms:
    - name: Ubuntu
      versions:
        - focal
        - jammy
    - name: Debian
      versions:
        - bullseye
        - bookworm
    - name: EL
      versions:
        - 8
        - 9

dependencies: []
EOF
done

# Create main playbook
cat > "playbooks/site.yml" << EOF
---
- name: Install development tools
  hosts: all
  become: true
  roles:
$(for role in "${ROLES[@]}"; do echo "    - ${role}"; done)
  tags:
    - dev-tools
EOF

# Create inventory files
cat > "inventory/hosts.yml" << EOF
---
all:
  children:
    development:
      hosts:
        localhost:
          ansible_connection: local
    production:
      hosts:
        # Add your production hosts here
EOF

# Create group variables
cat > "group_vars/all.yml" << EOF
---
# Global variables for all hosts
ansible_user: "{{ ansible_env.USER }}"
become_method: sudo
EOF

cat > "group_vars/development.yml" << EOF
---
# Variables for development environment
EOF

cat > "group_vars/production.yml" << EOF
---
# Variables for production environment
EOF

# Create ansible.cfg
cat > "ansible.cfg" << EOF
[defaults]
inventory = inventory/hosts.yml
roles_path = roles
host_key_checking = False
retry_files_enabled = False
gathering = smart
fact_caching = memory
stdout_callback = yaml
callback_whitelist = timer, profile_tasks

[inventory]
enable_plugins = host_list, script, auto, yaml, ini, toml

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes
EOF

# Create requirements file
cat > "requirements.yml" << EOF
---
# External role dependencies
collections:
  - name: community.general
    version: ">=3.0.0"
EOF

# Create Makefile for common tasks
cat > "Makefile" << EOF
.PHONY: help install check run dry-run

help:
	@echo "Available targets:"
	@echo "  install    - Install Ansible dependencies"
	@echo "  check      - Check playbook syntax"
	@echo "  run        - Run the main playbook"
	@echo "  dry-run    - Run playbook in check mode"

install:
	ansible-galaxy install -r requirements.yml

check:
	ansible-playbook --syntax-check playbooks/site.yml

run:
	ansible-playbook playbooks/site.yml

dry-run:
	ansible-playbook --check playbooks/site.yml
EOF

# Create README
cat > "README.md" << EOF
# Ansible Development Tools Project

This Ansible project installs and configures various command-line development tools.

## Tools Included

$(for role in "${ROLES[@]}"; do echo "- **${role}**"; done)

## Project Structure

\`\`\`
ansible/
├── ansible.cfg          # Ansible configuration
├── requirements.yml     # External dependencies
├── Makefile            # Common tasks
├── inventory/          # Inventory files
│   └── hosts.yml
├── group_vars/         # Group variables
│   ├── all.yml
│   ├── development.yml
│   └── production.yml
├── host_vars/          # Host-specific variables
├── roles/              # Ansible roles
$(for role in "${ROLES[@]}"; do echo "│   ├── ${role}/"; done)
├── playbooks/          # Playbooks
│   └── site.yml
├── files/              # Static files
├── templates/          # Jinja2 templates
└── vault/              # Encrypted files
\`\`\`

## Usage

1. Install dependencies:
   \`\`\`bash
   make install
   \`\`\`

2. Check syntax:
   \`\`\`bash
   make check
   \`\`\`

3. Run in dry-run mode:
   \`\`\`bash
   make dry-run
   \`\`\`

4. Execute the playbook:
   \`\`\`bash
   make run
   \`\`\`

## Customization

- Edit \`inventory/hosts.yml\` to add your target hosts
- Modify role variables in \`group_vars/\` or \`host_vars/\`
- Customize installation tasks in each role's \`tasks/main.yml\`

EOF

# Create .gitignore
cat > ".gitignore" << EOF
# Ansible
*.retry
.vault_pass
vault/.vault_pass

# OS
.DS_Store
Thumbs.db

# Editor
.vscode/
.idea/
*.swp
*.swo
*~

# Logs
*.log
EOF

echo ""
echo "✅ Ansible project scaffolded successfully!"
echo ""
echo "📁 Project structure created in: ${PROJECT_DIR}/"
echo "🎯 Roles created: ${ROLES[*]}"
echo ""
echo "Next steps:"
echo "1. cd ${PROJECT_DIR}"
echo "2. make install  # Install dependencies"
echo "3. make check    # Verify syntax"
echo "4. make dry-run  # Test without changes"
echo "5. make run      # Execute playbook"
echo ""
echo "Happy automating! 🤖"
