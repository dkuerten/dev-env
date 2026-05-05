#!/usr/bin/env bash
# Idempotent install of nvm + Node 22.11.0 LTS in /config/.nvm
set -euo pipefail

NVM_DIR=/config/.nvm
NODE_VERSION=22.11.0
NVM_VERSION=v0.40.1

echo "[init/20-nvm] starting"

if [ ! -d "$NVM_DIR" ]; then
    echo "[init/20-nvm] installing nvm $NVM_VERSION to $NVM_DIR"
    mkdir -p "$NVM_DIR"
    curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | NVM_DIR="$NVM_DIR" PROFILE=/dev/null bash
else
    echo "[init/20-nvm] nvm already installed, skipping bootstrap"
fi

# Source nvm pra usar nesta shell
export NVM_DIR
# shellcheck disable=SC1091
. "$NVM_DIR/nvm.sh"

if ! nvm ls --no-alias "$NODE_VERSION" >/dev/null 2>&1; then
    echo "[init/20-nvm] installing Node $NODE_VERSION"
    nvm install "$NODE_VERSION"
else
    echo "[init/20-nvm] Node $NODE_VERSION already installed, skipping"
fi

nvm alias default "$NODE_VERSION"
chown -R abc:abc "$NVM_DIR"

# Adiciona shell hook ao bashrc do user abc (idempotente)
BASHRC=/config/.bashrc
if ! grep -q "NVM_DIR" "$BASHRC" 2>/dev/null; then
    cat >> "$BASHRC" <<'EOF'

# nvm (added by /custom-cont-init.d/20-nvm.sh)
export NVM_DIR=/config/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
EOF
    chown abc:abc "$BASHRC"
fi

echo "[init/20-nvm] done"
