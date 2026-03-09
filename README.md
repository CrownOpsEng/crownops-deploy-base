# CrownOpsEng VPS Base Collection

Reusable Ansible collection for fresh Ubuntu VPS bootstrap.

Purpose:
- provide a clean day-0 baseline for new VPS hosts
- keep environment-specific inventory and secrets out of the shared base repo
- let deployment repos consume a hardened bootstrap layer without copying roles

Current baseline role:
- `crownops.vps_base.bootstrap_host`

Supported OS:
- Ubuntu 22.04 (`jammy`) by default
- Ubuntu 24.04 (`noble`) when explicitly configured

What the baseline covers:
- package update and base package install
- admin user creation and SSH key install
- passwordless sudo drop-in for the bootstrap admin
- SSH hardening drop-in
- UFW baseline rules
- fail2ban baseline
- unattended security updates baseline
- optional Docker Engine install
- optional Tailscale install and join

What stays out of this repo by design:
- production inventories
- host-specific secrets
- application-specific roles
- environment overlays

Read first:
- `docs/QUICKSTART.md`
- `docs/REPO_LAYOUT.md`

Example direct use:

```bash
ansible-galaxy collection build . --output-path dist
ansible-galaxy collection install -p ~/.ansible/collections dist/crownops-vps_base-0.1.0.tar.gz
ansible-playbook -i examples/inventory/hosts.yml playbooks/bootstrap.yml
```
