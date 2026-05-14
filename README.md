# Claude Code Remote Agent Docker Image

A Docker image for running the Claude Code agent inside a container in **remote-control** mode, with persistent configuration and network access through the host's proxy.

## Included Tools

- **Node.js 24.x** (NodeSource) + TypeScript / pnpm / yarn / tsx / eslint / prettier / http-server
- **Python 3** + pip + common packages (requests, httpx, pydantic, python-dotenv, rich, typer, pytest, black, ruff, ipython)
- **Claude Code CLI** (the `claude` command)
- **GitHub CLI** (`gh`)
- **Google Chrome Stable** (headless, with Noto CJK fonts)
- **ripgrep**, git, curl, wget, vim, nano, jq, tree, htop, lsof, net-tools, dnsutils and other common CLI tools
- Build toolchain: build-essential / gcc / g++ / make / cmake

## Quick Start (docker run)

### 1. Prepare host directories

These will hold your Claude Code account, sessions, and working files so they survive container restarts.

```bash
mkdir -p .claude workspace
touch .claude.json
```

### 2. Pull the image

```bash
docker pull claudecode-agent:latest
```

### 3. Run the container

```bash
docker run -it --rm \
  --name claudecode-agent \
  --add-host host.docker.internal:host-gateway \
  -e IS_SANDBOX=1 \
  -e HTTP_PROXY=http://host.docker.internal:7890 \
  -e HTTPS_PROXY=http://host.docker.internal:7890 \
  -e NO_PROXY=localhost,127.0.0.1 \
  -v "$(pwd)/.claude.json:/home/claude/.claude.json" \
  -v "$(pwd)/.claude:/home/claude/.claude" \
  -v "$(pwd)/workspace:/workspace" \
  claudecode-agent:latest \
  remote-control --permission-mode bypassPermissions --name skytree
```

Drop the proxy `-e` flags if you don't need to route through a host proxy. To rename the agent or switch modes, change the trailing arguments after the image name.

## docker-compose Example

If you'd rather use Compose, save the following as `docker-compose.yml` in the same directory as your `.claude.json`, `.claude/`, and `workspace/`:

```yaml
services:
  claudecode:
    image: claudecode-agent:latest
    container_name: claudecode-agent
    extra_hosts:
      - "host.docker.internal:host-gateway"
    environment:
      - IS_SANDBOX=1
      - HTTP_PROXY=http://host.docker.internal:7890
      - HTTPS_PROXY=http://host.docker.internal:7890
      - NO_PROXY=localhost,127.0.0.1
    volumes:
      - ./.claude.json:/home/claude/.claude.json
      - ./.claude:/home/claude/.claude
      - ./workspace:/workspace
    command: ["remote-control", "--permission-mode", "bypassPermissions", "--name", "skytree"]
    stdin_open: true
    tty: true
```

Then start it with:

```bash
docker compose run --rm claudecode
```

## Mounts

| Host path | Container path | Description |
|-----------|----------------|-------------|
| `./.claude.json` | `/home/claude/.claude.json` | Claude Code account and global config |
| `./.claude` | `/home/claude/.claude` | Login state, session history, project data |
| `./workspace` | `/workspace` | Working directory where code lives inside the container |

## Environment Variables

| Variable | Value | Description |
|----------|-------|-------------|
| `HTTP_PROXY` / `HTTPS_PROXY` | `http://host.docker.internal:7890` | Route traffic through the host proxy |
| `NO_PROXY` | `localhost,127.0.0.1` | Bypass proxy for local addresses |
| `IS_SANDBOX` | `1` | Marks the container as a sandbox, so Claude Code relaxes some safety restrictions |

## Proxy Configuration

The container is configured to use the host's port `7890` as its HTTP/HTTPS proxy (`http://host.docker.internal:7890`).

Make sure your host's proxy software is listening on `0.0.0.0:7890` (not only `127.0.0.1`), otherwise the container won't be able to reach it. If you don't need a proxy, omit the `HTTP_PROXY` / `HTTPS_PROXY` variables.

## Building From Source

If you'd rather build the image yourself instead of pulling from Docker Hub:

```bash
git clone <this-repo>
cd claudecode
docker build -t claudecode-agent:latest .
```
