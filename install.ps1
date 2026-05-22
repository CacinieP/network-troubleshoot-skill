# Network Troubleshoot Skill — One-click installer (PowerShell)
# Usage: irm https://raw.githubusercontent.com/CacinieP/network-troubleshoot-skill/main/install.ps1 | iex
# Or:   .\install.ps1 -Agent cursor

param(
    [Parameter(Position=0)]
    [string]$Agent = ""
)

$Repo = "https://raw.githubusercontent.com/CacinieP/network-troubleshoot-skill/main"

function Download($Source, $Dest) {
    try {
        Invoke-WebRequest -Uri "$Repo/$Source" -OutFile $Dest -ErrorAction Stop
        Write-Host "[OK] Installed to $Dest" -ForegroundColor Green
    } catch {
        Write-Host "[FAIL] Could not download $Source" -ForegroundColor Red
    }
}

function Show-Help {
    Write-Host ""
    Write-Host "Available agents:" -ForegroundColor Cyan
    Write-Host "  claude-code   Claude Code CLI / Desktop"
    Write-Host "  cursor        Cursor IDE"
    Write-Host "  copilot       GitHub Copilot"
    Write-Host "  windsurf      Windsurf IDE"
    Write-Host "  cline         Cline (VS Code extension)"
    Write-Host "  codex         OpenAI Codex CLI"
    Write-Host "  continue      Continue.dev"
    Write-Host "  aider         Aider"
    Write-Host "  kiro          Kiro IDE (Amazon)"
    Write-Host "  trae          Trae IDE (ByteDance)"
    Write-Host "  codebuddy     CodeBuddy (Tencent)"
    Write-Host "  opencode      OpenCode"
    Write-Host "  augment       Augment Code"
    Write-Host "  gemini        Gemini CLI"
    Write-Host "  cody          Sourcegraph Cody"
    Write-Host "  amazon-q      Amazon Q Developer"
    Write-Host "  generic       Any other agent (plain markdown)"
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  irm https://raw.githubusercontent.com/.../install.ps1 | iex" -ForegroundColor Yellow
    Write-Host "  Then enter agent name when prompted" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Or: .\install.ps1 -Agent cursor" -ForegroundColor Yellow
}

if (-not $Agent) {
    Write-Host ""
    Write-Host "  network-troubleshoot-skill installer" -ForegroundColor Cyan
    Write-Host ""
    $Agent = Read-Host "Enter agent name (or 'list' to see all)"
}

switch ($Agent.ToLower()) {
    "claude-code" {
        $dest = "$env:USERPROFILE\.claude\skills"
        New-Item -ItemType Directory -Path $dest -Force | Out-Null
        Download "skills/network-troubleshoot.md" "$dest\network-troubleshoot.md"
        Write-Host "Restart Claude Code to activate." -ForegroundColor Yellow
    }
    "cursor" {
        New-Item -ItemType Directory -Path ".cursor\rules" -Force | Out-Null
        Download "adapters/cursor/network-troubleshoot.mdc" ".cursor\rules\network-troubleshoot.mdc"
    }
    "copilot" {
        New-Item -ItemType Directory -Path ".github" -Force | Out-Null
        Download "adapters/github-copilot/copilot-instructions.md" ".github\copilot-instructions.md"
    }
    "windsurf" {
        Download "adapters/windsurf/.windsurfrules" ".windsurfrules"
    }
    "cline" {
        Download "adapters/cline/.clinerules" ".clinerules"
    }
    "codex" {
        Download "adapters/codex/network-troubleshoot.md" "network-troubleshoot-agent.md"
        Write-Host "Use with: codex --agent network-troubleshoot-agent.md" -ForegroundColor Yellow
    }
    "continue" {
        New-Item -ItemType Directory -Path ".continue\rules" -Force | Out-Null
        Download "adapters/continue/rules/network-troubleshoot.md" ".continue\rules\network-troubleshoot.md"
    }
    "aider" {
        Download "adapters/aider/CONVENTIONS-network.md" "CONVENTIONS-network.md"
        Write-Host "Add to .aider.conf.yml:  read: [CONVENTIONS-network.md]" -ForegroundColor Yellow
    }
    "kiro" {
        New-Item -ItemType Directory -Path ".kiro\steering" -Force | Out-Null
        Download "adapters/kiro/steering/network-troubleshoot.md" ".kiro\steering\network-troubleshoot.md"
    }
    "trae" {
        New-Item -ItemType Directory -Path ".trae\rules" -Force | Out-Null
        Download "adapters/trae/.trae/rules/network-troubleshoot.md" ".trae\rules\network-troubleshoot.md"
    }
    "codebuddy" {
        New-Item -ItemType Directory -Path ".codebuddy\rules\network-troubleshoot" -Force | Out-Null
        Download "adapters/codebuddy/.codebuddy/rules/network-troubleshoot/RULE.mdc" ".codebuddy\rules\network-troubleshoot\RULE.mdc"
    }
    "opencode" {
        Download "adapters/opencode/AGENTS.md" "AGENTS.md"
    }
    "augment" {
        Download "adapters/augment/.augment-rules" ".augment-rules"
    }
    "gemini" {
        Download "adapters/gemini/GEMINI.md" "GEMINI.md"
    }
    "cody" {
        Download "adapters/cody/.cody.md" ".cody.md"
    }
    "amazon-q" {
        New-Item -ItemType Directory -Path ".amazonq\rules" -Force | Out-Null
        Download "adapters/amazon-q/.amazonq/rules/network-troubleshoot.md" ".amazonq\rules\network-troubleshoot.md"
    }
    "generic" {
        Download "adapters/generic/network-troubleshoot.md" "network-troubleshoot.md"
    }
    "list" { Show-Help; return }
    default {
        Write-Host "[FAIL] Unknown agent: $Agent" -ForegroundColor Red
        Show-Help
        return
    }
}

Write-Host ""
Write-Host "[DONE] Your AI coding agent now has network debugging superpowers." -ForegroundColor Green
