#!/usr/bin/env bash
# Idempotent install of Claude Code CLI via npm (in nvm path)
set -euo pipefail

NVM_DIR=/config/.nvm
echo "[init/40-claude] starting"

if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    echo "[init/40-claude] nvm not found, skipping (20-nvm.sh failed?)"
    exit 0
fi

export NVM_DIR
# shellcheck disable=SC1091
. "$NVM_DIR/nvm.sh"
nvm use default >/dev/null

if ! command -v claude >/dev/null 2>&1; then
    echo "[init/40-claude] installing Claude Code via npm"
    npm install -g @anthropic-ai/claude-code
else
    echo "[init/40-claude] Claude Code already installed, skipping"
fi

# nvm-installed binaries são owned pelo user que rodou nvm install (root durante init)
# chown ao abc pra evitar permission errors em runtime
chown -R abc:abc "$NVM_DIR"

echo "[init/40-claude] done"
