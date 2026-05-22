# network-troubleshoot-skill

A universal network troubleshooting skill for AI coding agents. Extracts patterns from real coding agent interactions and combines them with industry best practices. Works with **15+ AI coding agents**.

## What It Does

When invoked, this skill guides your AI coding agent through a structured network diagnostic workflow:

1. **Symptom Classification** - Identifies the type of network issue (connectivity, DNS, proxy, SSL, etc.)
2. **Automated Diagnostics** - Runs appropriate diagnostic commands based on OS and symptom
3. **Root Cause Analysis** - Interprets diagnostic output to pinpoint the issue
4. **Resolution Steps** - Provides actionable fixes with commands

## Supported Agents

| Agent | Config File | Installation |
|-------|-------------|--------------|
| **Claude Code** | `~/.claude/skills/network-troubleshoot.md` | Copy or symlink |
| **Cursor** | `.cursor/rules/network-troubleshoot.mdc` | Copy to project |
| **GitHub Copilot** | `.github/copilot-instructions.md` | Copy to project |
| **Windsurf** | `.windsurfrules` | Copy to project root |
| **Cline** | `.clinerules` | Copy to project root |
| **Codex** | Agent markdown with frontmatter | Use as custom agent |
| **Continue** | `.continue/rules/network-troubleshoot.md` | Copy to project |
| **Aider** | `CONVENTIONS-network.md` + `.aider.conf.yml` | Copy and add to `read:` |
| **Kiro** | `.kiro/steering/network-troubleshoot.md` | Copy to project |
| **Trae** | `.trae-rules` | Copy to project root |
| **CodeBuddy** | `network-troubleshoot.md` (YAML frontmatter) | Import as rule |
| **OpenCode** | `AGENTS.md` | Copy to project root |
| **Hermes** | `network-troubleshoot.md` | Use as agent instructions |
| **Augment** | `.augment-rules` | Copy to project root |
| **Gemini** | `GEMINI.md` | Copy to project root |

## Quick Start

### Claude Code

```bash
git clone https://github.com/CacinieP/network-troubleshoot-skill.git
cp network-troubleshoot-skill/skills/network-troubleshoot.md ~/.claude/skills/
```

### Cursor

```bash
cp network-troubleshoot-skill/adapters/cursor/network-troubleshoot.mdc .cursor/rules/
```

### GitHub Copilot

```bash
cp network-troubleshoot-skill/adapters/github-copilot/copilot-instructions.md .github/
```

### Windsurf

```bash
cp network-troubleshoot-skill/adapters/windsurf/.windsurfrules .
```

### Cline

```bash
cp network-troubleshoot-skill/adapters/cline/.clinerules .
```

### Codex

```bash
# Use as a custom agent definition
codex --agent network-troubleshoot-skill/adapters/codex/network-troubleshoot.md
```

### Continue

```bash
mkdir -p .continue/rules
cp network-troubleshoot-skill/adapters/continue/rules/network-troubleshoot.md .continue/rules/
```

### Aider

```bash
cp network-troubleshoot-skill/adapters/aider/CONVENTIONS-network.md .
# Add to .aider.conf.yml:
# read:
#   - CONVENTIONS-network.md
```

### Kiro

```bash
mkdir -p .kiro/steering
cp network-troubleshoot-skill/adapters/kiro/steering/network-troubleshoot.md .kiro/steering/
```

### Trae

```bash
cp network-troubleshoot-skill/adapters/trae/.trae-rules .
```

### CodeBuddy

Import `adapters/codebuddy/network-troubleshoot.md` as a rule via the CodeBuddy IDE settings.

### OpenCode

```bash
cp network-troubleshoot-skill/adapters/opencode/AGENTS.md .
```

### Any Other Agent

Use the generic adapter — a plain markdown file that works with any agent that reads markdown instructions:

```bash
cp network-troubleshoot-skill/adapters/generic/network-troubleshoot.md .
```

## Features

### Symptom Coverage

| Category | Symptoms |
|----------|----------|
| **Connectivity** | No internet, can't reach host, connection refused |
| **DNS** | Name resolution failure, DNS probe errors |
| **Proxy/VPN** | Proxy misconfiguration, VPN routing issues |
| **SSL/TLS** | Certificate errors, handshake failures |
| **HTTP** | Status code errors, CORS, redirects |
| **Performance** | Slow connections, high latency, packet loss |
| **Firewall** | Port blocking, filtered connections |
| **Package Managers** | npm/pip/docker registry access failures |

### Platform Support

- **Windows**: `ping`, `tracert`, `nslookup`, `netsh`, `Test-NetConnection`, `pathping`
- **Linux/macOS**: `ping`, `traceroute`, `dig`, `ss`, `iptables`, `curl`, `nc`
- **Cross-platform**: `curl`, `node`, `python`

### Diagnostic Flow

```
Error Report
    |
    v
[Symptom Classification]
    |
    +--> Connectivity? --> ping/gateway check --> firewall/ISP
    +--> DNS?           --> nslookup/dig        --> hosts/resolver
    +--> Proxy?         --> env/proxy config    --> Clash/V2Ray
    +--> SSL/TLS?       --> openssl/certutil    --> CA/cert chain
    +--> HTTP?          --> curl -v             --> headers/status
    +--> Timeout?       --> traceroute/mtr      --> latency/hops
    |
    v
[Root Cause] --> [Resolution]
```

## Repository Structure

```
network-troubleshoot-skill/
├── skills/
│   └── network-troubleshoot.md          # Claude Code skill definition
├── adapters/
│   ├── generic/                         # Universal markdown adapter
│   ├── cursor/                          # Cursor .mdc format
│   ├── github-copilot/                  # GitHub Copilot instructions
│   ├── windsurf/                        # Windsurf rules
│   ├── cline/                           # Cline rules
│   ├── codex/                           # Codex agent format
│   ├── continue/                        # Continue rules
│   ├── aider/                           # Aider conventions
│   ├── kiro/                            # Kiro steering rules
│   ├── trae/                            # Trae project rules
│   ├── codebuddy/                       # CodeBuddy rule format
│   ├── opencode/                        # OpenCode AGENTS.md
│   ├── hermes/                          # Hermes agent instructions
│   ├── augment/                         # Augment rules
│   └── gemini/                          # Gemini instructions
├── docs/
│   ├── TROUBLESHOOTING_GUIDE.md         # Full troubleshooting reference
│   └── PATTERNS_FROM_AGENTS.md          # Patterns extracted from coding agents
├── examples/
│   ├── session-cc-386.md                # Example: proxy configuration debug
│   └── session-cc-547.md                # Example: VPN connectivity debug
├── LICENSE
└── README.md
```

## Data Sources

This skill is built from:

1. **112+ coding agent interaction sessions** covering network-related troubleshooting across Claude Code, KimiCode, Codex, Cursor, and other agents
2. **Real-world error patterns** from developer workflows in China (proxy/VPN/GFW scenarios)
3. **Industry best practices** from network debugging guides and documentation

## Contributing

Contributions are welcome! See areas we'd like help with:

- Additional agent adapter formats
- Platform-specific diagnostic commands
- New error pattern coverage
- Translations of error messages
- Edge case resolution steps

## License

MIT License - see [LICENSE](LICENSE)
