#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

cat > "${TMP_DIR}/play.yml" <<EOF
---
- hosts: localhost
  connection: local
  gather_facts: false
  tasks:
    - ansible.builtin.include_role:
        name: ${ROOT_DIR}/roles/host_ufw
      vars:
        host_ufw:
          enabled: true
          logging: low
          default_incoming_policy: deny
          default_outgoing_policy: allow
          managed_state_dir: /tmp/crownops-host-ufw
          managed_state_file: /tmp/crownops-host-ufw/state.json
          baseline_tcp_public: []
          baseline_udp_public: []
          requests:
            - name: bad-port
              port: 70000
              proto: tcp
EOF

set +e
OUTPUT="$(ansible-playbook -i 'localhost,' "${TMP_DIR}/play.yml" 2>&1)"
STATUS=$?
set -e

if [[ ${STATUS} -eq 0 ]]; then
  echo "expected host_ufw invalid rule validation to fail" >&2
  exit 1
fi

if [[ "${OUTPUT}" != *"Invalid host_ufw rule"* ]]; then
  echo "expected host_ufw failure output to mention invalid rules" >&2
  printf '%s\n' "${OUTPUT}" >&2
  exit 1
fi

printf 'host_ufw invalid request rejection smoke test passed\n'
