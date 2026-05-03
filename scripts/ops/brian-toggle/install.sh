#!/bin/bash
# Install the brian toggle. Idempotent.
# Run as user azlan: bash scripts/ops/brian-toggle/install.sh
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"

[[ "$(id -un)" == "azlan" ]] || { echo "Run as user azlan." >&2; exit 1; }
command -v jq >/dev/null || { echo "Install jq first." >&2; exit 1; }

sudo ln -sf "$HERE/brian" /usr/local/bin/brian
echo "Installed: /usr/local/bin/brian -> $HERE/brian"
echo "Run: brian status"
