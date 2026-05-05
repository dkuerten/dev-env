# dkdev/dev-env

Custom Docker image extending [lscr.io/linuxserver/code-server](https://docs.linuxserver.io/images/docker-code-server/) with the Dkdev development toolchain pre-installed.

## What it includes

**Built into the image (Dockerfile):**
- Build deps for Python (build-essential, libssl-dev, libffi-dev, etc.)
- Docker CLI + Compose plugin (daemon comes from host via socket mount)
- gh CLI (GitHub)
- git, tmux, vim, htop, jq, less
- postgresql-client, redis-tools

**Installed at container start (init scripts in `/custom-cont-init.d/`):**
- pyenv + Python 3.12.7 (in `/config/.pyenv`)
- nvm + Node 22.11.0 LTS (in `/config/.nvm`)
- Poetry (in `/config/.local/bin`)
- Claude Code CLI (npm global in nvm path)

Init scripts are idempotent — they detect existing installs and skip reinstall.

## Usage

Local build (on the VPS or any host with Docker):

```bash
make build
docker images | grep dkdev/dev-env
```

Pull from registry (when published to ghcr.io):

```bash
make pull
```

## Update flow

1. Edit `Dockerfile` or `init/*.sh`
2. `make build`
3. `cd /docker/visual-studio-code-server-mrhj && docker compose up -d --force-recreate`
4. Init scripts run automatically; new toolchain installs idempotently in `/config`

## Troubleshooting

**Init scripts not running on container start:**

```bash
docker logs visual-studio-code-server-mrhj-code-server-1 2>&1 | grep -E "custom-cont-init|pyenv|nvm"
```

**pyenv install fails (missing build dep):** Check the apt packages in `Dockerfile` cover the [pyenv build wiki](https://github.com/pyenv/pyenv/wiki#suggested-build-environment).

**Docker socket not accessible from inside container:** Verify `docker.sock` mount in `docker-compose.yml` and that user `abc` (uid 1000) is in group `docker` on the host.
