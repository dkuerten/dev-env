#!/usr/bin/env bash
# Idempotent install of Poetry in /config/.local/bin
set -euo pipefail

POETRY_HOME=/config/.local
POETRY_BIN="$POETRY_HOME/bin/poetry"

echo "[init/30-poetry] starting"

if [ ! -x "$POETRY_BIN" ]; then
    # Poetry installer requires Python — pyenv shim já está em PATH via 10-pyenv.sh
    export PATH="/config/.pyenv/shims:/config/.pyenv/bin:$PATH"
    echo "[init/30-poetry] installing Poetry to $POETRY_HOME"
    curl -fsSL https://install.python-poetry.org | POETRY_HOME="$POETRY_HOME" python3 -
else
    echo "[init/30-poetry] Poetry already installed, skipping"
fi

chown -R abc:abc "$POETRY_HOME"

# Garantir PATH no bashrc (idempotente)
BASHRC=/config/.bashrc
if ! grep -q "/config/.local/bin" "$BASHRC" 2>/dev/null; then
    cat >> "$BASHRC" <<'EOF'

# Poetry (added by /custom-cont-init.d/30-poetry.sh)
export PATH="/config/.local/bin:$PATH"
EOF
    chown abc:abc "$BASHRC"
fi

echo "[init/30-poetry] done"
