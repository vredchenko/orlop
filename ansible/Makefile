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
