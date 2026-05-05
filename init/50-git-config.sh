#!/usr/bin/env bash
# Idempotent global git config for user abc
set -euo pipefail

echo "[init/50-git-config] starting"

GITCONFIG=/config/.gitconfig

# Só seta defaults se .gitconfig ainda não existe (não sobrescreve user customizations)
if [ ! -f "$GITCONFIG" ]; then
    cat > "$GITCONFIG" <<'EOF'
[init]
    defaultBranch = main
[pull]
    rebase = true
[push]
    autoSetupRemote = true
[core]
    editor = vim
[color]
    ui = auto
EOF
    chown abc:abc "$GITCONFIG"
    echo "[init/50-git-config] created default $GITCONFIG"
else
    echo "[init/50-git-config] $GITCONFIG já existe, mantendo"
fi

echo "[init/50-git-config] done"
