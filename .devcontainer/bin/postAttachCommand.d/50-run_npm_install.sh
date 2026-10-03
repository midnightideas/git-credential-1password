#!/usr/bin/env bash

set -euo pipefail

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./_lib.sh
source "$LIB_DIR/_lib.sh"

[ ! -f package.json ] && exit 0
command -v npm >/dev/null 2>&1 || exit 0

# --ignore-scripts: don't execute package install hooks in the devcontainer.
log INFO "running npm install"
npm install --ignore-scripts || log WARN "npm install failed"
