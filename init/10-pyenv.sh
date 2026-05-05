#!/usr/bin/env bash
# Idempotent install of pyenv + Python 3.12.7 in /config/.pyenv
# Runs as root via LinuxServer /custom-cont-init.d/ hook before switch to user 'abc'.
set -euo pipefail

PYENV_ROOT=/config/.pyenv
PY_VERSION=3.12.7

echo "[init/10-pyenv] starting"

if [ ! -x "$PYENV_ROOT/bin/pyenv" ]; then
    echo "[init/10-pyenv] installing pyenv to $PYENV_ROOT"
    curl -fsSL https://pyenv.run | PYENV_ROOT="$PYENV_ROOT" bash
else
    echo "[init/10-pyenv] pyenv already installed, skipping"
fi

export PATH="$PYENV_ROOT/bin:$PATH"

if ! "$PYENV_ROOT/bin/pyenv" versions --bare | grep -qx "$PY_VERSION"; then
    echo "[init/10-pyenv] installing Python $PY_VERSION (slow, ~3-5min on first run)"
    "$PYENV_ROOT/bin/pyenv" install "$PY_VERSION"
else
    echo "[init/10-pyenv] Python $PY_VERSION already installed, skipping"
fi

"$PYENV_ROOT/bin/pyenv" global "$PY_VERSION"
chown -R abc:abc "$PYENV_ROOT"

# Adiciona shell hook ao bashrc do user abc (idempotente)
BASHRC=/config/.bashrc
if ! grep -q PYENV_ROOT "$BASHRC" 2>/dev/null; then
    cat >> "$BASHRC" <<'EOF'

# pyenv (added by /custom-cont-init.d/10-pyenv.sh)
export PYENV_ROOT=/config/.pyenv
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
EOF
    chown abc:abc "$BASHRC"
fi

echo "[init/10-pyenv] done"
