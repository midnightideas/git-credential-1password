#!/usr/bin/env bash

set -euo pipefail

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./_lib.sh
source "$LIB_DIR/_lib.sh"

url="${DOTFILES_GIT_URL:-}"
[ -z "$url" ] && exit 0

# npx wants git+https:// for git URLs.
case "$url" in
  git@*) npx_url="git+https://${url#git@}" ;;
  https://*) npx_url="git+${url}" ;;
  *) npx_url="git+https://$url" ;;
esac

log INFO "bootstrapping dotfiles via npx"
bootstrap_log="$(mktemp)"

# npm_config_allow_git=root: npx refuses git dependencies as root by default;
# containers often run as root.
rc=0
npm_config_allow_git=root npx -y "$npx_url" >"$bootstrap_log" 2>&1 || rc=$?
if [ "$rc" -ne 0 ]; then
  log WARN "bootstrap failed (exit=$rc)"
  log WARN "bootstrap output (last 200 lines):"
  tail -n 200 "$bootstrap_log" | sed 's/^/  /' >&2
else
  log INFO "bootstrap completed"
fi

rm -f "$bootstrap_log"
