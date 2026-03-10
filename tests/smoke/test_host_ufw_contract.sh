#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TASK_FILE="${ROOT_DIR}/roles/host_ufw/tasks/main.yml"

for expected in 'managed_state_file' 'host_ufw_previous_rules' 'delete: true' 'baseline_tcp_public' 'baseline_udp_public'; do
  if ! rg -n "${expected}" "${TASK_FILE}" >/dev/null; then
    echo "expected host_ufw task flow to include ${expected}" >&2
    exit 1
  fi
done

if ! rg -n 'host_ufw rule names must be unique' "${TASK_FILE}" >/dev/null; then
  echo "expected host_ufw to validate duplicate rule names" >&2
  exit 1
fi

printf 'host_ufw contract smoke test passed\n'
