# Quick Start

This collection is the reusable host-foundation layer for Ubuntu hosts.

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

## Public roles

- `crownops.deploy_base.bootstrap_host`
- `crownops.deploy_base.network_lockdown`

`bootstrap_host` handles fresh-host setup, including optional Tailscale installation and join.
When Docker or Tailscale are enabled, the role verifies the downloaded apt signing key fingerprint before trusting the repository configuration.

`network_lockdown` handles the staged post-join SSH posture:

- phase one: preserve public SSH
- phase two: only remove public SSH when both `lockdown_enabled=true` and `lockdown_confirmed=true`
- runtime health checks: verify `tailscale0`, `tailscale status --json`, and a Tailscale IPv4 address before restrictive changes
- break-glass file: `lockdown_break_glass_file` short-circuits restrictive changes

## Recommended layout

```text
VPS/
  crownops-deploy-base/
  crownops-deploy-core/
  crownops-deploy-services/
  crownops-deploy-edge/
```

## Install dependencies

From this repo:

```bash
ansible-galaxy collection install -r requirements.yml
```

## Build and test locally

```bash
ansible-galaxy collection install -r requirements.yml
ansible-galaxy collection build . --output-path dist
ansible-galaxy collection install -p ./.ansible/collections dist/crownops-deploy_base-0.1.0.tar.gz --force
ansible-playbook -i examples/inventory/hosts.yml playbooks/bootstrap.yml
ansible-playbook -i examples/inventory/hosts.yml playbooks/lockdown.yml -e lockdown_enabled=true -e lockdown_confirmed=true
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
- post-join SSH lockdown can be applied safely after Tailscale access is proven
