#!/usr/bin/env bash
# Network Troubleshoot Skill — One-click installer
# Usage: curl -fsSL https://raw.githubusercontent.com/CacinieP/network-troubleshoot-skill/main/install.sh | bash -s -- <agent>
# Agents: claude-code, cursor, copilot, windsurf, cline, codex, continue, aider, kiro, trae, codebuddy, opencode, augment, gemini, cody, amazon-q, generic

set -euo pipefail

REPO="https://raw.githubusercontent.com/CacinieP/network-troubleshoot-skill/main"
AGENT="${1:-}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; }

download() {
  curl -fsSL "$REPO/$1" -o "$2" 2>/dev/null || wget -q "$REPO/$1" -O "$2" 2>/dev/null
}

install_claude_code() {
  local dest="$HOME/.claude/skills"
  mkdir -p "$dest"
  download "skills/network-troubleshoot.md" "$dest/network-troubleshoot.md"
  info "Installed to $dest/network-troubleshoot.md"
  info "Restart Claude Code to activate."
}

install_cursor() {
  mkdir -p .cursor/rules
  download "adapters/cursor/network-troubleshoot.mdc" ".cursor/rules/network-troubleshoot.mdc"
  info "Installed to .cursor/rules/network-troubleshoot.mdc"
}

install_copilot() {
  mkdir -p .github
  download "adapters/github-copilot/copilot-instructions.md" ".github/copilot-instructions.md"
  info "Installed to .github/copilot-instructions.md"
}

install_windsurf() {
  download "adapters/windsurf/.windsurfrules" ".windsurfrules"
  info "Installed to .windsurfrules"
}

install_cline() {
  download "adapters/cline/.clinerules" ".clinerules"
  info "Installed to .clinerules"
}

install_codex() {
  download "adapters/codex/network-troubleshoot.md" "network-troubleshoot-agent.md"
  info "Downloaded to network-troubleshoot-agent.md"
  info "Use with: codex --agent network-troubleshoot-agent.md"
}

install_continue() {
  mkdir -p .continue/rules
  download "adapters/continue/rules/network-troubleshoot.md" ".continue/rules/network-troubleshoot.md"
  info "Installed to .continue/rules/network-troubleshoot.md"
}

install_aider() {
  download "adapters/aider/CONVENTIONS-network.md" "CONVENTIONS-network.md"
  info "Downloaded CONVENTIONS-network.md"
  warn "Add to .aider.conf.yml:  read: [CONVENTIONS-network.md]"
}

install_kiro() {
  mkdir -p .kiro/steering
  download "adapters/kiro/steering/network-troubleshoot.md" ".kiro/steering/network-troubleshoot.md"
  info "Installed to .kiro/steering/network-troubleshoot.md"
}

install_trae() {
  mkdir -p .trae/rules
  download "adapters/trae/.trae/rules/network-troubleshoot.md" ".trae/rules/network-troubleshoot.md"
  info "Installed to .trae/rules/network-troubleshoot.md"
}

install_codebuddy() {
  mkdir -p .codebuddy/rules/network-troubleshoot
  download "adapters/codebuddy/.codebuddy/rules/network-troubleshoot/RULE.mdc" ".codebuddy/rules/network-troubleshoot/RULE.mdc"
  info "Installed to .codebuddy/rules/network-troubleshoot/RULE.mdc"
}

install_opencode() {
  download "adapters/opencode/AGENTS.md" "AGENTS.md"
  info "Installed to AGENTS.md"
}

install_augment() {
  download "adapters/augment/.augment-rules" ".augment-rules"
  info "Installed to .augment-rules"
}

install_gemini() {
  download "adapters/gemini/GEMINI.md" "GEMINI.md"
  info "Installed to GEMINI.md"
}

install_cody() {
  download "adapters/cody/.cody.md" ".cody.md"
  info "Installed to .cody.md"
}

install_amazon_q() {
  mkdir -p .amazonq/rules
  download "adapters/amazon-q/.amazonq/rules/network-troubleshoot.md" ".amazonq/rules/network-troubleshoot.md"
  info "Installed to .amazonq/rules/network-troubleshoot.md"
}

install_generic() {
  download "adapters/generic/network-troubleshoot.md" "network-troubleshoot.md"
  info "Installed to network-troubleshoot.md"
}

list_agents() {
  cat <<'EOF'
Available agents:
  claude-code   Claude Code CLI / Desktop
  cursor        Cursor IDE
  copilot       GitHub Copilot
  windsurf      Windsurf IDE
  cline         Cline (VS Code extension)
  codex         OpenAI Codex CLI
  continue      Continue.dev
  aider         Aider
  kiro          Kiro IDE (Amazon)
  trae          Trae IDE (ByteDance)
  codebuddy     CodeBuddy (Tencent)
  opencode      OpenCode
  augment       Augment Code
  gemini        Gemini CLI
  cody          Sourcegraph Cody
  amazon-q      Amazon Q Developer
  generic       Any other agent (plain markdown)

Usage:
  curl -fsSL https://raw.githubusercontent.com/CacinieP/network-troubleshoot-skill/main/install.sh | bash -s -- <agent>

Examples:
  curl -fsSL https://raw.githubusercontent.com/CacinieP/network-troubleshoot-skill/main/install.sh | bash -s -- cursor
  curl -fsSL https://raw.githubusercontent.com/CacinieP/network-troubleshoot-skill/main/install.sh | bash -s -- claude-code
EOF
}

# Main
if [ -z "$AGENT" ]; then
  error "No agent specified."
  echo ""
  list_agents
  exit 1
fi

echo ""
echo "  network-troubleshoot-skill installer"
echo "  Agent: $AGENT"
echo ""

case "$AGENT" in
  claude-code|claude)   install_claude_code ;;
  cursor)               install_cursor ;;
  copilot|github)       install_copilot ;;
  windsurf)             install_windsurf ;;
  cline)                install_cline ;;
  codex)                install_codex ;;
  continue)             install_continue ;;
  aider)                install_aider ;;
  kiro)                 install_kiro ;;
  trae)                 install_trae ;;
  codebuddy)            install_codebuddy ;;
  opencode)             install_opencode ;;
  augment)              install_augment ;;
  gemini)               install_gemini ;;
  cody)                 install_cody ;;
  amazon-q|amazonq)     install_amazon_q ;;
  generic|other)        install_generic ;;
  list|--list|-l)       list_agents ;;
  *)
    error "Unknown agent: $AGENT"
    echo ""
    list_agents
    exit 1
    ;;
esac

echo ""
info "Done! Your AI coding agent now has network debugging superpowers."
