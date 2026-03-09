# Quick Start

This collection is the reusable day-0 layer for brand new Ubuntu hosts.

## Design rule

Keep this repo generic.

Do not store:
- inventories
- vault files
- production DNS names
- host IPs
- provider credentials

Those belong in the consuming deployment repo.

## Supported hosts

- Ubuntu 22.04 (`jammy`) is the default expectation
- Ubuntu 24.04 (`noble`) is supported by setting `bootstrap_target_ubuntu_release: noble`

## Recommended layout

```text
VPS/
  crownops-deploy-base/
  crownops-deploy-core/
  crownops-deploy-edge/
```

## Install dependencies

From this repo:

```bash
ansible-galaxy collection install -r requirements.yml
```

## Build and test locally

```bash
ansible-galaxy collection build . --output-path dist
ansible-galaxy collection install -p ./.ansible/collections dist/crownops-deploy_base-0.1.0.tar.gz --force
ansible-playbook -i examples/inventory/hosts.yml playbooks/bootstrap.yml
```

## Minimum inventory shape

```yaml
all:
  children:
    base_hosts:
      hosts:
        fresh-host-01:
          ansible_host: 203.0.113.10
          ansible_user: root
```

## Minimum vars

```yaml
bootstrap_target_ubuntu_release: jammy
bootstrap_admin_user: deploy
bootstrap_admin_group: deploy
bootstrap_admin_authorized_keys:
  - "ssh-ed25519 AAAA..."
```

## Success criteria

- the admin user exists and can SSH by key
- password auth is disabled
- root SSH login is disabled
- UFW is enabled with the intended allow-list
- fail2ban is running
- unattended security updates are enabled
- optional Docker and Tailscale are installed when requested
