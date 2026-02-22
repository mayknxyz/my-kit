---
name: mykit-repos
description: My Kit repo catalog and MCP server management — per-repo catalog with stack detection, and .mcp.json configuration with template-based server management.
---

# My Kit Repos & MCP

Manages the repo catalog (`data/repos.json`) and per-repo `.mcp.json` configuration. Auto-activates when the user expresses intent to manage repos or MCP servers.

## Trigger Keywords

- **repos.review**: "review repos", "list repos", "check repos", "repo catalog", "my repos"
- **repos.add**: "add repo", "catalog repo", "register repo", "track repo"
- **repos.remove**: "remove repo", "uncatalog repo", "untrack repo", "delete repo from catalog"
- **mcp.review**: "review MCP", "list MCP servers", "check MCP", "MCP status", "what MCP servers"
- **mcp.add**: "add MCP server", "install MCP", "enable MCP", "add server"
- **mcp.remove**: "remove MCP server", "uninstall MCP", "disable MCP", "remove server"

## Step Identification

| Step | Keywords | Description |
|------|----------|-------------|
| `repos.review` | review repos, list repos, catalog | Review repo catalog vs GitHub |
| `repos.add` | add repo, catalog, register, track | Add repo to catalog with stack detection |
| `repos.remove` | remove repo, uncatalog, untrack | Remove repo from catalog |
| `mcp.review` | review MCP, list servers, MCP status | Compare installed vs available MCP servers |
| `mcp.add` | add MCP, install server, enable | Add MCP server from template |
| `mcp.remove` | remove MCP, uninstall server, disable | Remove MCP server from config |

## Routing Logic

### 1. Identify Step

Map user intent to one of the 6 steps: `repos.review`, `repos.add`, `repos.remove`, `mcp.review`, `mcp.add`, or `mcp.remove`.

### 2. Check Prerequisites

Before executing any step, verify:

```bash
# gh CLI installed
command -v gh

# Authenticated
gh auth status
```

### 3. Load Reference File

| Step | Reference |
|------|-----------|
| repos.review | `references/repos-review.md` |
| repos.add | `references/repos-add.md` |
| repos.remove | `references/repos-remove.md` |
| mcp.review | `references/mcp-review.md` |
| mcp.add | `references/mcp-add.md` |
| mcp.remove | `references/mcp-remove.md` |

**Load only the one reference file needed per invocation.**

### 4. Execute Reference Instructions

Follow the loaded reference file's instructions exactly. Each reference contains the complete workflow:

- **repos-review.md**: `gh repo list` → auto-locate on disk → compare with catalog → display report
- **repos-add.md**: Resolve repo → verify on GitHub → stack detection → MCP detection → add to catalog
- **repos-remove.md**: List cataloged repos → select → confirm → remove from catalog
- **mcp-review.md**: Read `.mcp.json` → compare with templates → display installed vs available
- **mcp-add.md**: List templates → select → diff preview → confirm → merge into `.mcp.json`
- **mcp-remove.md**: List installed servers → select → diff preview → confirm → remove from `.mcp.json`

## Data Files

- `data/repos.json` — Repo catalog (version-controlled at repo root, not stow-deployed)
- `references/mcp-templates/*.json` — MCP server configuration templates

## Reference Files

- `references/repos-review.md` — Review repo catalog vs GitHub
- `references/repos-add.md` — Add repo to catalog with stack detection
- `references/repos-remove.md` — Remove repo from catalog
- `references/mcp-review.md` — Compare installed vs available MCP servers
- `references/mcp-add.md` — Add MCP server from template
- `references/mcp-remove.md` — Remove MCP server from config
