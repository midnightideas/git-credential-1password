#!/usr/bin/env bash

set -euo pipefail

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./_lib.sh
source "$LIB_DIR/_lib.sh"

# Skip cleanly when 1Password SSH ref or required CLIs are unavailable.
[ -n "${OP_SSH_KEY_REF:-}" ] || { log INFO "OP_SSH_KEY_REF not set, skipping ssh-agent setup"; exit 0; }
command -v op >/dev/null 2>&1 || { log INFO "op CLI not found, skipping ssh-agent setup"; exit 0; }
command -v ssh-agent >/dev/null 2>&1 || { log INFO "ssh-agent not found, skipping ssh-agent setup"; exit 0; }

# Security boundary: discard any inherited/host-forwarded agent so the new
# local agent is the only thing bound to /tmp/ssh-agent.sock. Subsequent
# postAttach scripts (fetch_repo, bootstrap's import_ssh_key) trust this
# socket as canonical.
unset SSH_AUTH_SOCK SSH_AGENT_PID
local_auth_sock=/tmp/ssh-agent.sock
agent_env_file=/tmp/ssh-agent.env
rm -f "$local_auth_sock"
mkdir -p "$(dirname "$local_auth_sock")"

log INFO "starting local ssh-agent on ${local_auth_sock}"
eval "$(ssh-agent -a "$local_auth_sock" -s)" >/dev/null

cat > "$agent_env_file" <<EOF
export SSH_AUTH_SOCK=${SSH_AUTH_SOCK}
export SSH_AGENT_PID=${SSH_AGENT_PID}
EOF
chmod 600 "$agent_env_file"

log INFO "importing SSH key from 1Password..."
if ! op read "$OP_SSH_KEY_REF" 2>/dev/null | ssh-add - >/dev/null 2>&1; then
  log WARN "ssh-add failed (continuing; bootstrap's import_ssh_key will retry)"
fi