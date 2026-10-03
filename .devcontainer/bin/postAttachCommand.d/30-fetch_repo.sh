#!/usr/bin/env bash

set -euo pipefail

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./_lib.sh
source "$LIB_DIR/_lib.sh"

command -v git >/dev/null 2>&1 || { log INFO "git not in PATH, skipping git fetch"; exit 0; }

# Fetch only — user decides when to pull. Fails gracefully so offline or
# auth-missing attaches don't fail the postAttach chain.
log INFO "fetching latest refs from origin"
git fetch --prune || log WARN "git fetch failed (run 'git pull' manually to update)"