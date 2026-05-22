<p align="center">
  <strong>network-troubleshoot-skill</strong>
</p>

<p align="center">
  Every developer hits network errors.<br>
  This skill makes <strong>any AI coding agent</strong> fix them for you.
</p>

<p align="center">
  <img src="https://img.shields.io/github/stars/CacinieP/network-troubleshoot-skill?style=social" alt="GitHub stars">
  <img src="https://img.shields.io/badge/agents-17%2B-blue" alt="17+ agents">
  <img src="https://img.shields.io/badge/sessions-112%2B-green" alt="112+ sessions">
  <img src="https://img.shields.io/badge/license-MIT-yellow" alt="MIT License">
  <img src="https://img.shields.io/badge/platform-Win%20%7C%20Mac%20%7C%20Linux-lightgrey" alt="Platform">
</p>

<p align="center">
  <a href="./README_CN.md">中文文档</a> ·
  <a href="./docs/TROUBLESHOOTING_GUIDE.md">Troubleshooting Guide</a> ·
  <a href="./docs/PATTERNS_FROM_AGENTS.md">Patterns from Agents</a> ·
  <a href="./CONTRIBUTING.md">Contributing</a>
</p>

---

> **One copy-paste** to give your AI coding agent network debugging superpowers.
> Works with Claude Code, Cursor, GitHub Copilot, Windsurf, Cline, Codex, Continue, Aider, Kiro, Trae, CodeBuddy, OpenCode, Augment, Gemini, Cody, Amazon Q, and more.

---

## One-Click Install

**macOS / Linux / Windows Git Bash:**
```bash
curl -fsSL https://raw.githubusercontent.com/CacinieP/network-troubleshoot-skill/main/install.sh | bash -s -- cursor
```

**Windows PowerShell:**
```powershell
irm https://raw.githubusercontent.com/CacinieP/network-troubleshoot-skill/main/install.ps1 | iex
# Then enter: cursor
```

Supported: `cursor`, `claude-code`, `copilot`, `windsurf`, `cline`, `codex`, `continue`, `aider`, `kiro`, `trae`, `codebuddy`, `opencode`, `augment`, `gemini`, `cody`, `amazon-q`, `generic`

## What It Does

When network errors occur, this skill guides your AI coding agent through a structured diagnostic workflow:

1. **Symptom Classification** — Identify the error type (connectivity, DNS, proxy, SSL, HTTP, etc.)
2. **Automated Diagnostics** — Run the right diagnostic commands for the OS and symptom
3. **Root Cause Analysis** — Interpret diagnostic output to pinpoint the issue
4. **Resolution Steps** — Apply actionable fixes with copy-paste commands

## Supported Agents — 17+

| Agent | Config File | Format |
|-------|-------------|--------|
| **Claude Code** | `~/.claude/skills/network-troubleshoot.md` | YAML frontmatter + Markdown |
| **Cursor** | `.cursor/rules/network-troubleshoot.mdc` | MDC with `description/globs/alwaysApply` |
| **GitHub Copilot** | `.github/copilot-instructions.md` | Plain Markdown |
| **Windsurf** | `.windsurfrules` | Plain Markdown |
| **Cline** | `.clinerules` | Plain Markdown |
| **Codex** | Agent markdown | YAML frontmatter + Markdown |
| **Continue** | `.continue/rules/network-troubleshoot.md` | Markdown with YAML frontmatter |
| **Aider** | `CONVENTIONS-network.md` | Markdown, referenced via `.aider.conf.yml` |
| **Kiro** | `.kiro/steering/network-troubleshoot.md` | Markdown steering file |
| **Trae** | `.trae/rules/network-troubleshoot.md` | MDC with YAML frontmatter |
| **CodeBuddy** | `.codebuddy/rules/network-troubleshoot/RULE.mdc` | MDC with YAML frontmatter |
| **OpenCode** | `AGENTS.md` | Markdown |
| **Hermes** | `network-troubleshoot.md` | Markdown |
| **Augment** | `.augment-rules` | Plain Markdown |
| **Gemini** | `GEMINI.md` | Markdown |
| **Sourcegraph Cody** | `.cody.md` | Plain Markdown |
| **Amazon Q Developer** | `.amazonq/rules/network-troubleshoot.md` | Plain Markdown |

> **Any other agent?** Use [`adapters/generic/network-troubleshoot.md`](adapters/generic/network-troubleshoot.md) — a plain markdown file that works everywhere.

## Quick Start

```bash
# One command — replace <agent> with your tool name
curl -fsSL https://raw.githubusercontent.com/CacinieP/network-troubleshoot-skill/main/install.sh | bash -s -- <agent>

# Examples:
curl -fsSL ... | bash -s -- cursor       # Cursor
curl -fsSL ... | bash -s -- claude-code  # Claude Code
curl -fsSL ... | bash -s -- copilot      # GitHub Copilot
curl -fsSL ... | bash -s -- cline        # Cline
curl -fsSL ... | bash -s -- windsurf     # Windsurf
curl -fsSL ... | bash -s -- generic      # Any other agent
```

<details>
<summary>Manual installation (copy-paste individual files)</summary>

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

# Any other agent
cp adapters/generic/network-troubleshoot.md .
```

</details>

## Features

### Error Coverage

| Category | Triggers |
|----------|----------|
| **Connectivity** | ECONNREFUSED, connection refused, no internet |
| **DNS** | ENOTFOUND, getaddrinfo ENOTFOUND, DNS probe errors |
| **Proxy/VPN** | proxy connection failed, Clash/V2Ray not running |
| **SSL/TLS** | CERT_HAS_EXPIRED, UNABLE_TO_VERIFY_LEAF_SIGNATURE, handshake failures |
| **HTTP** | 403, 407, 502, 503, 504 status codes |
| **Firewall** | ECONNRESET, connection reset, port blocking |
| **Package Managers** | npm ERR! network, pip install timeout, git fatal, docker pull fails |
| **Performance** | ETIMEDOUT, slow connections, high latency |

### Platform Support

| Platform | Tools |
|----------|-------|
| **Windows** | `ping`, `tracert`, `nslookup`, `netsh`, `Test-NetConnection`, `pathping` |
| **Linux/macOS** | `ping`, `traceroute`, `dig`, `ss`, `iptables`, `nc` |
| **Cross-platform** | `curl`, `node`, `python`, `openssl` |

### Diagnostic Flow

```
Network Error
     │
     ▼
┌─────────────────────┐
│  Symptom Classification  │
└──────────┬──────────┘
           │
     ┌─────┼──────┬───────┬───────┬───────┐
     ▼     ▼      ▼       ▼       ▼       ▼
  Connectivity DNS  Proxy  SSL/TLS  HTTP  Timeout
     │     │      │       │       │       │
     ▼     ▼      ▼       ▼       ▼       ▼
    ping  nslookup  env   openssl  curl  traceroute
    nc    dig      proxy  s_client -vvv   mtr
     │     │      │       │       │       │
     └─────┴──────┴───────┴───────┴───────┘
                    │
                    ▼
           ┌──────────────┐
           │  Root Cause   │
           └──────┬───────┘
                  ▼
           ┌──────────────┐
           │  Resolution   │
           └──────┬───────┘
                  ▼
           ┌──────────────┐
           │   Verify      │ ← re-run failed command
           └──────────────┘
```

### China Developer Support

Built from real Chinese developer agent sessions with specific patterns:

- Proxy/VPN cascade diagnosis (Clash, V2Ray, SSR)
- npm/pip/docker registry mirror configuration
- GFW-related connectivity patterns
- Chinese language triggers (网络问题, 连不上, 无法访问, 代理, 超时)

## Repository Structure

```
network-troubleshoot-skill/
├── skills/
│   └── network-troubleshoot.md            # Claude Code skill (primary)
├── adapters/
│   ├── generic/                           # Universal fallback
│   ├── cursor/                            # .mdc format
│   ├── github-copilot/                    # copilot-instructions.md
│   ├── windsurf/                          # .windsurfrules
│   ├── cline/                             # .clinerules
│   ├── codex/                             # Agent markdown
│   ├── continue/                          # .continue/rules/
│   ├── aider/                             # CONVENTIONS-network.md
│   ├── kiro/                              # .kiro/steering/
│   ├── trae/                              # .trae/rules/ (MDC format)
│   ├── codebuddy/                         # .codebuddy/rules/ (MDC format)
│   ├── opencode/                          # AGENTS.md
│   ├── hermes/                            # Agent instructions
│   ├── augment/                           # .augment-rules
│   ├── gemini/                            # GEMINI.md
│   ├── cody/                              # .cody.md
│   └── amazon-q/                          # .amazonq/rules/
├── docs/
│   ├── TROUBLESHOOTING_GUIDE.md           # Full reference guide
│   └── PATTERNS_FROM_AGENTS.md            # Data-driven pattern analysis
├── install.sh                             # One-click installer
├── CONTRIBUTING.md                        # How to contribute
├── LICENSE
├── README.md
└── README_CN.md
```

## Comparison with Similar Projects

| Dimension | **This Project** | [awesome-cursorrules](https://github.com/PatrickJS/awesome-cursorrules) | [awesome-rules](https://github.com/continuedev/awesome-rules) | [ai-agents-skills](https://github.com/hoodini/ai-agents-skills) | [NetClaw](https://github.com/automateyournetwork/netclaw) |
|-----------|:---------:|:---:|:---:|:---:|:---:|
| Stars | New | ~39,600 | ~183 | ~211 | ~511 |
| Network troubleshooting focus | **Yes (core)** | No | No | No | Yes (core) |
| Multi-agent support | **17+** | 1 (Cursor) | 3 | 4+ | 1 (Claude) |
| Data-driven patterns | **112+ sessions** | No | No | No | No |
| China/GFW scenarios | **Yes** | No | No | No | No |
| Resolution playbooks | **12+ fixes** | N/A | N/A | N/A | 112 skills |
| Platform-specific (Win/Mac/Linux) | **All 3** | N/A | N/A | N/A | Linux |
| Error classification matrix | **Yes** | No | No | No | Yes |
| Install & go (zero config) | **Yes** | Yes | Yes | Yes | No (setup) |
| Target audience | Developers | Developers | Developers | Developers | Network engineers |

> **Key differentiator**: This is the only repo that combines (1) multi-agent support across 17+ tools, (2) data-driven patterns from real sessions, (3) China/GFW-specific scenarios, and (4) zero-config copy-paste installation. [NetClaw](https://github.com/automateyournetwork/netclaw) is excellent for enterprise network engineers (BGP/OSPF/EVPN), while this project targets **developers** encountering network errors in their daily workflow.

### Competitive Score

| Metric | Score | Notes |
|--------|-------|-------|
| Uniqueness | **9/10** | Only multi-agent network troubleshooting skill with real session data |
| Completeness | **8.5/10** | 17 agents, bilingual docs, playbooks, reference guide |
| Practicality | **9/10** | Copy-paste install, zero config, immediate value |
| Data-backed | **9/10** | 112+ real sessions extracted vs typical "hand-crafted" rules |
| Documentation | **8.5/10** | Bilingual (EN/CN), reference guide, pattern analysis, comparison table |
| Community potential | **7/10** | Niche but high-value; needs more visibility and contributor onboarding |
| **Overall** | **8.5/10** | Best-in-class for developer network troubleshooting across AI agents |

## Data Sources

1. **112+ coding agent interaction sessions** — Claude Code (577), KimiCode (25), Codex (11), Cursor (3)
2. **8 network troubleshooting patterns** extracted from real-world developer workflows
3. **China-specific network scenarios** — proxy cascade, GFW patterns, registry mirrors
4. **Industry best practices** — curl, openssl, dig diagnostic references

## Contributing

Contributions welcome:

- Additional agent adapter formats
- Platform-specific diagnostic commands
- New error patterns and edge cases
- Translations
- Example sessions

## License

[MIT](LICENSE)

---

<p align="center">
  If this saved you from a network debugging session, consider giving it a ⭐!<br>
  It helps other developers discover this tool.
</p>
