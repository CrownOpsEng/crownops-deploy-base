#!/usr/bin/env bash
set -euo pipefail

TMP_PLAYBOOK="$(mktemp)"
trap 'rm -f "${TMP_PLAYBOOK}"' EXIT

cat > "${TMP_PLAYBOOK}" <<'EOF'
---
- name: Verify Tailscale bootstrap guardrails
  hosts: localhost
  connection: local
  gather_facts: false
  vars:
    bootstrap_tailscale_auth_key: test-auth-key
    bootstrap_tailscale_status:
      rc: 0
      stdout: |
        {"BackendState":"NeedsLogin","Self":{"ID":""}}
  tasks:
    - name: Parse current Tailscale state
      ansible.builtin.set_fact:
        bootstrap_tailscale_status_json: >-
          {{
            (bootstrap_tailscale_status.stdout | from_json)
            if (bootstrap_tailscale_status.rc == 0 and (bootstrap_tailscale_status.stdout | string | trim) != '')
            else {}
          }}
        bootstrap_tailscale_needs_join: >-
          {{
            (bootstrap_tailscale_auth_key | string | trim) != ''
            and (
              bootstrap_tailscale_status.rc != 0
              or (bootstrap_tailscale_status_json.BackendState | default('')) in ['NeedsLogin', 'NoState']
              or (((bootstrap_tailscale_status_json.Self | default({})).ID | default('') | string | trim) == '')
            )
          }}

    - name: Assert NeedsLogin still triggers tailscale up
      ansible.builtin.assert:
        that:
          - bootstrap_tailscale_needs_join | bool

    - name: Set invalid advertised tags
      ansible.builtin.set_fact:
        bootstrap_tailscale_tags:
          - core

    - name: Validate configured Tailscale tags
      ansible.builtin.assert:
        that:
          - (bootstrap_tailscale_tags | select('match', '^tag:') | list | length) == (bootstrap_tailscale_tags | length)
EOF

set +e
OUTPUT="$(ansible-playbook -i 'localhost,' "${TMP_PLAYBOOK}" 2>&1)"
STATUS=$?
set -e

if [[ ${STATUS} -eq 0 ]]; then
  echo "expected invalid Tailscale tags to fail validation" >&2
  exit 1
fi

if [[ "${OUTPUT}" != *"bootstrap_tailscale_tags"* ]]; then
  echo "expected invalid Tailscale tag validation failure in output" >&2
  printf '%s\n' "${OUTPUT}" >&2
  exit 1
fi

printf 'tailscale bootstrap smoke test passed\n'
