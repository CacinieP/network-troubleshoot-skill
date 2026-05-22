# Contributing to network-troubleshoot-skill

Thanks for your interest! Contributions of all sizes are welcome.

## Quick Ways to Contribute

### Add a New Agent Adapter

Each agent lives in `adapters/<agent-name>/`. To add a new one:

1. Create a directory under `adapters/` named after the agent
2. Add the config file in the correct format (see existing adapters for reference)
3. Include a brief comment at the top explaining which agent and config path it uses
4. Update both `README.md` and `README_CN.md` tables

### Add a New Error Pattern

Edit `skills/network-troubleshoot.md` (the primary skill file):

1. Add the error to the classification table
2. Add the diagnostic command if it's a new category
3. Add the resolution to the fix table
4. Update the relevant adapter files to keep them in sync

### Improve Documentation

- Fix typos or unclear instructions
- Add platform-specific notes
- Translate content
- Add real-world examples to `docs/`

## Adapter Template

For a plain-markdown agent:

```markdown
# Network Troubleshooting

When network errors occur, apply systematic diagnosis.

## Error Classification
- ECONNREFUSED → Connectivity issue
- ETIMEDOUT → Routing/timeout issue
- ENOTFOUND → DNS issue
- SSL errors → Certificate issue

## Diagnostic Commands
Connectivity: `ping <host>`, `nc -zv <host> <port>`
DNS: `nslookup <host>`, `nslookup <host> 8.8.8.8`
...

## Resolution
| Finding | Fix |
|---|---|
| DNS fails | Switch to 8.8.8.8, flush cache |
| ...
```

For an agent with YAML frontmatter (Cursor, Continue, Trae, CodeBuddy):

```markdown
---
description: Network troubleshooting — systematic diagnosis and resolution
globs:
alwaysApply: true
---

# Network Troubleshooting
(same content as above)
```

## PR Checklist

- [ ] Adapter uses the correct file format and path for the target agent
- [ ] Both README.md and README_CN.md are updated
- [ ] Content is consistent with the primary skill in `skills/network-troubleshoot.md`

## Questions?

Open an issue — happy to help you get started.
