FROM lscr.io/linuxserver/code-server:latest

USER root

ARG DEBIAN_FRONTEND=noninteractive

# Pacotes base + libs pra build de Python via pyenv
# (lista do https://github.com/pyenv/pyenv/wiki#suggested-build-environment + utils dev)
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl gnupg git tmux vim less htop jq \
      build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
      libsqlite3-dev libffi-dev liblzma-dev libncursesw5-dev xz-utils tk-dev \
      postgresql-client redis-tools \
 && rm -rf /var/lib/apt/lists/*

# Docker CLI (cliente apenas — daemon vem do host via socket mount)
RUN install -m 0755 -d /etc/apt/keyrings \
 && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
 && chmod a+r /etc/apt/keyrings/docker.gpg \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu noble stable" > /etc/apt/sources.list.d/docker.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends docker-ce-cli docker-compose-plugin \
 && rm -rf /var/lib/apt/lists/*

# gh CLI
RUN install -m 0755 -d /etc/apt/keyrings \
 && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/etc/apt/keyrings/githubcli-archive-keyring.gpg \
 && chmod a+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list \
 && apt-get update && apt-get install -y --no-install-recommends gh \
 && rm -rf /var/lib/apt/lists/*

# Init scripts rodam a cada container start (idempotentes)
COPY init/10-pyenv.sh      /custom-cont-init.d/10-pyenv.sh
COPY init/20-nvm.sh        /custom-cont-init.d/20-nvm.sh
COPY init/30-poetry.sh     /custom-cont-init.d/30-poetry.sh
COPY init/40-claude.sh     /custom-cont-init.d/40-claude.sh
COPY init/50-git-config.sh /custom-cont-init.d/50-git-config.sh
RUN chmod +x /custom-cont-init.d/*.sh

# Note: NÃO setar `USER abc` aqui. A imagem base lscr.io/linuxserver/code-server
# inicia como root e usa s6-overlay pra rodar /custom-cont-init.d/ como root
# antes de fazer drop pra abc no code-server. Adicionar `USER abc` aqui faz s6
# iniciar como abc, init scripts não conseguem chown /config, tudo quebra.
