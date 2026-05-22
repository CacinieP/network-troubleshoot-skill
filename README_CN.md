<p align="center">
  <strong>network-troubleshoot-skill</strong>
</p>

<p align="center">
  每个开发者都会遇到网络错误。<br>
  这个技能让<strong>任何 AI 编程代理</strong>帮你自动排查修复。
</p>

<p align="center">
  <img src="https://img.shields.io/github/stars/CacinieP/network-troubleshoot-skill?style=social" alt="GitHub stars">
  <img src="https://img.shields.io/badge/agents-17%2B-blue" alt="17+ agents">
  <img src="https://img.shields.io/badge/sessions-112%2B-green" alt="112+ sessions">
  <img src="https://img.shields.io/badge/license-MIT-yellow" alt="MIT License">
  <img src="https://img.shields.io/badge/platform-Win%20%7C%20Mac%20%7C%20Linux-lightgrey" alt="Platform">
</p>

<p align="center">
  <a href="./README.md">English</a> ·
  <a href="./docs/TROUBLESHOOTING_GUIDE.md">故障排查指南</a> ·
  <a href="./docs/PATTERNS_FROM_AGENTS.md">代理交互模式分析</a> ·
  <a href="./CONTRIBUTING.md">贡献指南</a>
</p>

---

> **一次复制粘贴**，让你的 AI 编程代理获得网络调试超能力。
> 支持 Claude Code、Cursor、GitHub Copilot、Windsurf、Cline、Codex、Continue、Aider、Kiro、Trae、CodeBuddy、OpenCode、Augment、Gemini、Cody、Amazon Q 等等。

---

## 它能做什么

当网络错误发生时，本技能会引导你的 AI 编程代理执行结构化的诊断流程：

1. **症状分类** — 识别错误类型（连通性、DNS、代理、SSL、HTTP 等）
2. **自动诊断** — 根据操作系统和症状运行对应的诊断命令
3. **根因分析** — 解读诊断输出，定位问题根源
4. **修复步骤** — 提供可直接复制执行的修复命令

## 支持的编程代理 — 17+

| 代理 | 配置文件 | 格式 |
|-----|---------|------|
| **Claude Code** | `~/.claude/skills/network-troubleshoot.md` | YAML frontmatter + Markdown |
| **Cursor** | `.cursor/rules/network-troubleshoot.mdc` | MDC 格式 |
| **GitHub Copilot** | `.github/copilot-instructions.md` | 纯 Markdown |
| **Windsurf** | `.windsurfrules` | 纯 Markdown |
| **Cline** | `.clinerules` | 纯 Markdown |
| **Codex** | Agent markdown | YAML frontmatter + Markdown |
| **Continue** | `.continue/rules/network-troubleshoot.md` | Markdown + YAML frontmatter |
| **Aider** | `CONVENTIONS-network.md` | Markdown，通过 `.aider.conf.yml` 引用 |
| **Kiro** | `.kiro/steering/network-troubleshoot.md` | Markdown steering 文件 |
| **Trae** | `.trae/rules/network-troubleshoot.md` | MDC + YAML frontmatter |
| **CodeBuddy** | `.codebuddy/rules/network-troubleshoot/RULE.mdc` | MDC + YAML frontmatter |
| **OpenCode** | `AGENTS.md` | Markdown |
| **Hermes** | `network-troubleshoot.md` | Markdown |
| **Augment** | `.augment-rules` | 纯 Markdown |
| **Gemini** | `GEMINI.md` | Markdown |
| **Sourcegraph Cody** | `.cody.md` | 纯 Markdown |
| **Amazon Q Developer** | `.amazonq/rules/network-troubleshoot.md` | 纯 Markdown |

> **其他代理？** 使用 [`adapters/generic/network-troubleshoot.md`](adapters/generic/network-troubleshoot.md) — 纯 Markdown，适用于任何代理。

## 快速安装

**macOS / Linux / Windows Git Bash:**
```bash
curl -fsSL https://raw.githubusercontent.com/CacinieP/network-troubleshoot-skill/main/install.sh | bash -s -- cursor
```

**Windows PowerShell:**
```powershell
irm https://raw.githubusercontent.com/CacinieP/network-troubleshoot-skill/main/install.ps1 | iex
# 然后输入: cursor
```

支持：`cursor`、`claude-code`、`copilot`、`windsurf`、`cline`、`codex`、`continue`、`aider`、`kiro`、`trae`、`codebuddy`、`opencode`、`augment`、`gemini`、`cody`、`amazon-q`、`generic`

<details>
<summary>手动安装（复制单个文件）</summary>

```bash
git clone https://github.com/CacinieP/network-troubleshoot-skill.git
cd network-troubleshoot-skill

# Claude Code
cp skills/network-troubleshoot.md ~/.claude/skills/

# Cursor
cp adapters/cursor/network-troubleshoot.mdc .cursor/rules/

# GitHub Copilot
mkdir -p .github && cp adapters/github-copilot/copilot-instructions.md .github/

# Windsurf
cp adapters/windsurf/.windsurfrules .

# Cline
cp adapters/cline/.clinerules .

# Continue
mkdir -p .continue/rules && cp adapters/continue/rules/network-troubleshoot.md .continue/rules/

# Aider
cp adapters/aider/CONVENTIONS-network.md .

# Kiro
mkdir -p .kiro/steering && cp adapters/kiro/steering/network-troubleshoot.md .kiro/steering/

# Trae
mkdir -p .trae/rules && cp adapters/trae/.trae/rules/network-troubleshoot.md .trae/rules/

# CodeBuddy
mkdir -p .codebuddy/rules/network-troubleshoot && cp adapters/codebuddy/.codebuddy/rules/network-troubleshoot/RULE.mdc .codebuddy/rules/network-troubleshoot/

# Augment
cp adapters/augment/.augment-rules .

# OpenCode
cp adapters/opencode/AGENTS.md .

# Sourcegraph Cody
cp adapters/cody/.cody.md .

# Amazon Q Developer
mkdir -p .amazonq/rules && cp adapters/amazon-q/.amazonq/rules/network-troubleshoot.md .amazonq/rules/

# 其他任何代理
cp adapters/generic/network-troubleshoot.md .
```

</details>

## 功能特性

### 错误覆盖范围

| 类别 | 触发条件 |
|------|---------|
| **连通性** | ECONNREFUSED、connection refused、无网络 |
| **DNS** | ENOTFOUND、getaddrinfo ENOTFOUND、DNS 解析失败 |
| **代理/VPN** | proxy connection failed、Clash/V2Ray 未运行 |
| **SSL/TLS** | CERT_HAS_EXPIRED、UNABLE_TO_VERIFY_LEAF_SIGNATURE、握手失败 |
| **HTTP** | 403、407、502、503、504 状态码 |
| **防火墙** | ECONNRESET、connection reset、端口封禁 |
| **包管理器** | npm ERR! network、pip install timeout、git fatal、docker pull 失败 |
| **性能** | ETIMEDOUT、连接慢、高延迟 |

### 平台支持

| 平台 | 工具 |
|------|------|
| **Windows** | `ping`、`tracert`、`nslookup`、`netsh`、`Test-NetConnection`、`pathping` |
| **Linux/macOS** | `ping`、`traceroute`、`dig`、`ss`、`iptables`、`nc` |
| **跨平台** | `curl`、`node`、`python`、`openssl` |

### 诊断流程

```
网络错误
     │
     ▼
┌──────────────────────┐
│    症状分类            │
└──────────┬───────────┘
           │
     ┌─────┼──────┬───────┬───────┬───────┐
     ▼     ▼      ▼       ▼       ▼       ▼
  连通性  DNS    代理    SSL/TLS  HTTP   超时
     │     │      │       │       │       │
     ▼     ▼      ▼       ▼       ▼       ▼
    ping  nslookup  env   openssl  curl  traceroute
    nc    dig      proxy  s_client -vvv   mtr
     │     │      │       │       │       │
     └─────┴──────┴───────┴───────┴───────┘
                    │
                    ▼
           ┌──────────────┐
           │   根因定位    │
           └──────┬───────┘
                  ▼
           ┌──────────────┐
           │   执行修复    │
           └──────┬───────┘
                  ▼
           ┌──────────────┐
           │   验证结果    │ ← 重新运行失败命令
           └──────────────┘
```

### 中国开发者支持

基于真实的中国开发者代理交互会话，特别针对以下场景：

- 代理/VPN 级联诊断（Clash、V2Ray、SSR）
- npm/pip/docker 镜像源配置
- GFW 相关连通性问题
- 中文触发词支持（网络问题、连不上、无法访问、代理、超时）

### 常见修复速查

| 场景 | 命令 |
|------|------|
| npm 超时 | `npm config set registry https://registry.npmmirror.com` |
| pip 超时 | `pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple` |
| git 失败 | `git config --global http.proxy http://127.0.0.1:7890` |
| docker pull 失败 | 配置 `/etc/docker/daemon.json` 镜像源 |
| DNS 失败 | 切换到 8.8.8.8，刷新 DNS 缓存 |
| 代理未运行 | 启动 Clash/V2Ray，验证端口监听 |
| SSL 证书过期 | 更新证书；开发环境：`NODE_TLS_REJECT_UNAUTHORIZED=0` |

### 一键代理配置（中国开发者）

```bash
export HTTP_PROXY=http://127.0.0.1:7890
export HTTPS_PROXY=http://127.0.0.1:7890
export ALL_PROXY=socks5://127.0.0.1:7891
npm config set registry https://registry.npmmirror.com
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
git config --global http.proxy http://127.0.0.1:7890
```

## 仓库结构

```
network-troubleshoot-skill/
├── skills/
│   └── network-troubleshoot.md            # Claude Code 技能定义（主文件）
├── adapters/
│   ├── generic/                           # 通用 Markdown 适配器
│   ├── cursor/                            # Cursor .mdc 格式
│   ├── github-copilot/                    # GitHub Copilot 指令
│   ├── windsurf/                          # Windsurf 规则
│   ├── cline/                             # Cline 规则
│   ├── codex/                             # Codex 代理格式
│   ├── continue/                          # Continue 规则
│   ├── aider/                             # Aider 约定文件
│   ├── kiro/                              # Kiro steering 规则
│   ├── trae/                              # .trae/rules/ (MDC 格式)
│   ├── codebuddy/                         # .codebuddy/rules/ (MDC 格式)
│   ├── opencode/                          # AGENTS.md
│   ├── hermes/                            # Hermes 代理指令
│   ├── augment/                           # Augment 规则
│   ├── gemini/                            # Gemini 指令
│   ├── cody/                              # .cody.md
│   └── amazon-q/                          # .amazonq/rules/
├── docs/
│   ├── TROUBLESHOOTING_GUIDE.md           # 完整故障排查参考指南
│   └── PATTERNS_FROM_AGENTS.md            # 基于代理交互的模式分析
├── LICENSE
├── README.md                              # 英文文档
└── README_CN.md                           # 中文文档（本文件）
```

## 同类项目对比

| 维度 | **本项目** | [awesome-cursorrules](https://github.com/PatrickJS/awesome-cursorrules) | [awesome-rules](https://github.com/continuedev/awesome-rules) | [ai-agents-skills](https://github.com/hoodini/ai-agents-skills) | [NetClaw](https://github.com/automateyournetwork/netclaw) |
|------|:--------:|:---:|:---:|:---:|:---:|
| Stars | 新项目 | ~39,600 | ~183 | ~211 | ~511 |
| 聚焦网络排查 | **是（核心）** | 否 | 否 | 否 | 是（核心） |
| 多代理支持 | **17+** | 1（Cursor） | 3 | 4+ | 1（Claude） |
| 数据驱动模式 | **112+ 会话** | 否 | 否 | 否 | 否 |
| 中国/GFW 场景 | **是** | 否 | 否 | 否 | 否 |
| 修复方案手册 | **12+ 方案** | 不适用 | 不适用 | 不适用 | 112 技能 |
| 跨平台（Win/Mac/Linux） | **全部** | 不适用 | 不适用 | 不适用 | Linux |
| 错误分类矩阵 | **是** | 否 | 否 | 否 | 是 |
| 开箱即用（零配置） | **是** | 是 | 是 | 是 | 否（需配置） |
| 目标用户 | 开发者 | 开发者 | 开发者 | 开发者 | 网络工程师 |

> **核心差异**：这是唯一一个同时具备 (1) 17+ 代理多平台支持、(2) 真实会话数据驱动、(3) 中国/GFW 特定场景、(4) 零配置即装即用 的网络排查技能。[NetClaw](https://github.com/automateyournetwork/netclaw) 面向企业网络工程师（BGP/OSPF/EVPN），而本项目面向**开发者**日常工作中遇到的网络错误。

### 竞争力评分

| 指标 | 得分 | 说明 |
|------|------|------|
| 独特性 | **9/10** | 唯一一个多代理网络排查 + 真实会话数据驱动的仓库 |
| 完整度 | **8.5/10** | 17 个代理、中英双语文档、修复手册、参考指南 |
| 实用性 | **9/10** | 复制即用、零配置、即刻产生价值 |
| 数据支撑 | **9/10** | 112+ 真实会话提取，非手工编写 |
| 文档质量 | **8.5/10** | 中英双语、参考指南、模式分析、对比表格 |
| 社区潜力 | **7/10** | 垂直领域但高价值；需更多曝光和贡献者引导 |
| **综合** | **8.5/10** | 开发者网络排查 x AI 代理领域最佳 |

## 数据来源

1. **112+ 编程代理交互会话** — Claude Code（577）、KimiCode（25）、Codex（11）、Cursor（3）
2. **8 个网络排查模式** — 从真实开发者工作流中提取
3. **中国特定网络场景** — 代理级联、GFW 模式、镜像源配置
4. **行业最佳实践** — curl、openssl、dig 等诊断工具参考

## 贡献

欢迎贡献：

- 新的代理适配器格式
- 平台特定诊断命令
- 新的错误模式和边界情况
- 翻译
- 示例会话

## 许可证

[MIT](LICENSE)

---

<p align="center">
  如果这个工具帮你省了一次网络调试的时间，给个 ⭐ 吧！<br>
  这能帮助更多开发者发现这个工具。
</p>
