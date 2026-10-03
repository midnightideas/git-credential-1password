#!/usr/bin/env bash

set -euo pipefail

export GIT_TERMINAL_PROMPT=0

# x-access-token works for gho_ (OAuth), ghp_ (Classic PAT), and github_pat_ (Fine-Grained) tokens.
if [ -n "${GITHUB_TOKEN:-}" ]; then
  export GIT_CONFIG_PARAMETERS="'credential.helper=!f() { test \"\$1\" = get && echo \"username=x-access-token\" && echo \"password=${GITHUB_TOKEN}\"; }; f'"
fi

if [ -d "/home/linuxbrew/.linuxbrew" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
POST_ATTACH_D="${SCRIPT_DIR}/postAttachCommand.d"

# shellcheck source=postAttachCommand.d/_lib.sh
source "${SCRIPT_DIR}/postAttachCommand.d/_lib.sh"

if [ ! -d "$POST_ATTACH_D" ]; then
  log WARN "postAttachCommand.d not found at $POST_ATTACH_D, nothing to run"
  exit 0
fi

# Scripts run in lexicographic order by their 00-99 prefix.
for script in "$POST_ATTACH_D"/*.sh; do
  [ -e "$script" ] || continue
  log INFO "running $(basename "$script")"
  bash "$script" || log WARN "$(basename "$script") exited non-zero"
done
