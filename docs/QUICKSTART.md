# Quick Start

This collection is the reusable day-0 layer for brand new Ubuntu VPS hosts.

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

## 1. Clone the base repo

Recommended layout:

```text
Code/
  vps/
    000-vps-base/
      crownops-vps-base/
    002-ovh-.../
      your-deployment-repo/
```

## 2. Install collection dependencies

From the collection repo:

```bash
ansible-galaxy collection install -r requirements.yml
```

## 3. Build and install the collection locally

```bash
ansible-galaxy collection build . --output-path dist
ansible-galaxy collection install -p ~/.ansible/collections dist/crownops-vps_base-0.1.0.tar.gz --force
```

## 4. Prepare inventory in the consuming deployment repo

Minimum fresh-host inventory shape:

```yaml
all:
  children:
    vps_base:
      hosts:
        host-01:
          ansible_host: 203.0.113.10
          ansible_user: root
```

Minimum vars:

```yaml
bootstrap_target_ubuntu_release: jammy
bootstrap_admin_user: deploy
bootstrap_admin_group: deploy
bootstrap_admin_authorized_keys:
  - "ssh-ed25519 AAAA..."
```

## 5. Run the bootstrap playbook

From the consuming deployment repo:

```bash
ansible-playbook -i inventories/prod/hosts.yml playbooks/bootstrap.yml
```

Or directly from this collection repo against the example inventory:

```bash
ansible-playbook -i examples/inventory/hosts.yml playbooks/bootstrap.yml
```

## 6. What success should look like

- your admin user exists and can SSH by key
- password auth is disabled
- root SSH login is disabled
- UFW is enabled with the intended allow-list
- fail2ban is running
- unattended security updates are enabled
- optional Docker and Tailscale are installed when requested

## 7. Recommended next layer

After this baseline completes, run an environment-specific deployment repo that adds:
- DNS and TLS
- reverse proxy
- application containers
- backups
- environment-specific firewall rules
- secret material
