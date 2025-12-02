# Ansible Configuration

Worker node configuration for TechEX.

## What It Does

1. Joins workers to Kubernetes cluster
2. Mounts NFS share for persistent storage

## Playbook

`playbooks/site.yml` - Main playbook

## Usage

The CI/CD pipeline runs this automatically using direct SSH.

For manual use:
```bash
ansible-playbook playbooks/site.yml -i inventory/hosts.ini
```

## Note

Most Kubernetes setup is done via EC2 user-data scripts.
Ansible only handles post-boot configuration.
