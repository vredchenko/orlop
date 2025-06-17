# Ansible Development Tools Project

This Ansible project installs and configures various command-line development tools.

## Tools Included

- **ripgrep**
- **gron**
- **fzf**
- **bat**
- **delta**
- **lsd**
- **gdu**
- **micro**

## Project Structure

```
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
│   ├── ripgrep/
│   ├── gron/
│   ├── fzf/
│   ├── bat/
│   ├── delta/
│   ├── lsd/
│   ├── gdu/
│   ├── micro/
├── playbooks/          # Playbooks
│   └── site.yml
├── files/              # Static files
├── templates/          # Jinja2 templates
└── vault/              # Encrypted files
```

## Usage

1. Install dependencies:
   ```bash
   make install
   ```

2. Check syntax:
   ```bash
   make check
   ```

3. Run in dry-run mode:
   ```bash
   make dry-run
   ```

4. Execute the playbook:
   ```bash
   make run
   ```

## Customization

- Edit `inventory/hosts.yml` to add your target hosts
- Modify role variables in `group_vars/` or `host_vars/`
- Customize installation tasks in each role's `tasks/main.yml`

