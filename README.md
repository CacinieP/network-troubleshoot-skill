# network-troubleshoot-skill

A Claude Code skill for systematic network troubleshooting. Extracts patterns from real coding agent interactions and combines them with industry best practices.

## What It Does

When invoked, this skill guides Claude Code through a structured network diagnostic workflow:

1. **Symptom Classification** - Identifies the type of network issue (connectivity, DNS, proxy, SSL, etc.)
2. **Automated Diagnostics** - Runs appropriate diagnostic commands based on OS and symptom
3. **Root Cause Analysis** - Interprets diagnostic output to pinpoint the issue
4. **Resolution Steps** - Provides actionable fixes with commands

## Quick Start

### Install as a Claude Code Skill

```bash
# Option 1: Clone and symlink
git clone https://github.com/CacinieP/network-troubleshoot-skill.git
ln -s $(pwd)/network-troubleshoot-skill/skills/network-troubleshoot.md ~/.claude/skills/

# Option 2: Copy directly
git clone https://github.com/CacinieP/network-troubleshoot-skill.git
cp network-troubleshoot-skill/skills/network-troubleshoot.md ~/.claude/skills/
```

### Use in Claude Code

Once installed, you can invoke it with:

```
/network-troubleshoot
```

Or ask Claude naturally:

```
I can't connect to github.com, help me debug
npm install is failing with ECONNREFUSED
My API calls are timing out
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

## Skill Architecture

```
network-troubleshoot-skill/
├── skills/
│   └── network-troubleshoot.md    # The Claude Code skill definition
├── docs/
│   ├── TROUBLESHOOTING_GUIDE.md   # Full troubleshooting reference
│   └── PATTERNS_FROM_AGENTS.md    # Patterns extracted from coding agents
├── examples/
│   ├── session-cc-386.md          # Example: proxy configuration debug
│   └── session-cc-547.md          # Example: VPN connectivity debug
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

- Additional platform-specific diagnostic commands
- New error pattern coverage
- Translations of error messages
- Edge case resolution steps

## License

MIT License - see [LICENSE](LICENSE)
