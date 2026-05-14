# Claude Code Remote Agent Docker Image

Docker 镜像，用于在容器内以 **remote-control** 模式运行 Claude Code agent，配置持久化并通过宿主机代理访问网络。

## 包含的工具

- **Node.js 24.x**（NodeSource）+ TypeScript / pnpm / yarn / tsx / eslint / prettier / http-server
- **Python 3** + pip + 常用包（requests、httpx、pydantic、python-dotenv、rich、typer、pytest、black、ruff、ipython）
- **Claude Code CLI**（`claude` 命令）
- **GitHub CLI**（`gh`）
- **Google Chrome Stable**（headless，含 Noto CJK 字体）
- **ripgrep**、git、curl、wget、vim、nano、jq、tree、htop、lsof、net-tools、dnsutils 等常用命令行工具
- 构建工具：build-essential / gcc / g++ / make / cmake

## 目录结构

```
claudecode/
├── Dockerfile          # 镜像定义
├── entrypoint.sh       # 容器启动脚本（exec claude "$@"）
├── docker-compose.yml  # 编排配置
├── .env.example        # 环境变量模板
├── .claude.json        # Claude Code 账号/配置（自动挂载，已 gitignore）
├── .claude/            # Claude Code 会话与状态（自动挂载，已 gitignore）
└── workspace/          # 工作目录（自动挂载，已 gitignore）
```

## 快速开始

### 1. 创建挂载目录与文件

```bash
mkdir -p .claude workspace
touch .claude.json
```

### 2. 构建镜像

```bash
docker compose build
```

### 3. 运行 Claude Code

```bash
docker compose run --rm claudecode
```

默认以 `remote-control --permission-mode bypassPermissions --name skytree` 启动（见 `docker-compose.yml` 的 `command` 字段）。如需改名或切换模式，编辑 compose 文件即可。

## 挂载说明

| 本地路径 | 容器路径 | 说明 |
|----------|----------|------|
| `./.claude.json` | `/home/claude/.claude.json` | Claude Code 账号与全局配置 |
| `./.claude` | `/home/claude/.claude` | 登录状态、会话记录、项目数据 |
| `./workspace` | `/workspace` | 工作目录，容器内代码文件存放位置 |

## 环境变量

| 变量 | 值 | 说明 |
|------|----|----|
| `HTTP_PROXY` / `HTTPS_PROXY` | `http://host.docker.internal:7890` | 走宿主机代理 |
| `NO_PROXY` | `localhost,127.0.0.1` | 本地不走代理 |
| `IS_SANDBOX` | `1` | 标记当前容器为沙箱环境，Claude Code 据此放宽部分安全限制 |

## 代理配置

容器内自动使用宿主机 `7890` 端口作为 HTTP/HTTPS 代理（`http://host.docker.internal:7890`）。

确保宿主机代理软件监听在 `0.0.0.0:7890`（而非仅 `127.0.0.1`），否则容器无法访问。
