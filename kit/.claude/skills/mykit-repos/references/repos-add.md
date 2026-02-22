# /mykit.repos.add

Add a repo to the catalog with automatic stack and MCP detection.

## Usage

```
/mykit.repos.add [repo-name-or-path]
```

## Description

Resolves a repo (from argument, cwd, or prompt), verifies it on GitHub, detects its tech stack and MCP servers, and adds it to `data/repos.json`.

## Implementation

When this command is invoked, perform the following steps:

### Step 1: Check Prerequisites

```bash
command -v gh
gh auth status
```

If `gh` is not installed or not authenticated, display error and stop.

### Step 2: Resolve Repo

Determine the target repo using this priority:

1. **Argument provided**: If user passed a repo name or path, use it
2. **Current directory**: If no argument, check if cwd is a git repo and extract the repo name from the remote URL
3. **Prompt**: If neither works, ask via `AskUserQuestion`:
   - header: "Repo"
   - question: "Which repo do you want to add to the catalog?"
   - options: List uncataloged repos from a quick `gh repo list` check

Extract `owner` and `name` from the resolved repo. For local paths, parse from `git remote get-url origin`.

### Step 3: Verify on GitHub

```bash
gh repo view {owner}/{name} --json name,owner,description
```

If the repo doesn't exist on GitHub, display error and stop:

```
**Error**: Repo `{owner}/{name}` not found on GitHub.
```

### Step 4: Check for Duplicate

Read `data/repos.json`. If a repo with the same `full_name` already exists, display and stop:

```
**Info**: `{full_name}` is already in the catalog.
```

### Step 5: Auto-Locate on Disk

Check these paths in order for a `.git` directory:

1. `$HOME/{name}`
2. `$HOME/dev/github/{name}`
3. `$HOME/dev/{name}`

If the user provided a path argument, use that directly. Record the first match as `local_path`.

### Step 6: Stack Detection

If `local_path` is found, scan for tech stack indicators:

| File | Detects |
|------|---------|
| `package.json` | Dependencies → framework, styling, testing, tooling |
| `astro.config.*` | framework: "astro" |
| `svelte.config.*` | framework: "svelte" |
| `wrangler.toml` / `wrangler.json` | platform: "cloudflare" |
| `tsconfig.json` | language: "typescript" |
| `biome.json` / `biome.jsonc` | tooling includes "biome" |
| `vitest.config.*` | testing includes "vitest" |
| `playwright.config.*` | testing includes "playwright" |

Build the `stack` object:

```json
{
  "framework": "astro" | "svelte" | "sveltekit" | null,
  "styling": "tailwind" | null,
  "language": "typescript" | "javascript" | "bash" | null,
  "platform": "cloudflare" | null,
  "testing": ["vitest", "playwright"],
  "tooling": ["biome", "stow"]
}
```

For `package.json`, check:
- `dependencies` / `devDependencies` for `astro`, `svelte`, `@sveltejs/kit`, `tailwindcss`, `@tailwindcss/vite`, `vitest`, `@playwright/test`, `@biomejs/biome`, `@cloudflare/workers-types`, `wrangler`
- `scripts` for `wrangler` commands → platform: "cloudflare"

### Step 7: MCP Detection

If `local_path` is found, read `.mcp.json` in the repo root (if it exists). Extract the server names (top-level keys in the `mcpServers` object, or top-level keys if flat format).

### Step 8: Write to Catalog

Append the new entry to `data/repos.json`:

```json
{
  "name": "{name}",
  "owner": "{owner}",
  "full_name": "{owner}/{name}",
  "local_path": "{path or null}",
  "added_at": "{ISO timestamp}",
  "stack": { ... },
  "mcp_servers": ["server1", "server2"],
  "last_audit": "{ISO timestamp}",
  "notes": ""
}
```

Update the `updated_at` field on the root object.

### Step 9: Display Summary

```
## Repo Added

**Repo**: {full_name}
**Path**: {local_path or "not found locally"}
**Stack**: {framework}, {language}, {platform}
**Styling**: {styling or "none detected"}
**Testing**: {testing list or "none detected"}
**Tooling**: {tooling list}
**MCP Servers**: {server list or "none"}

**Catalog**: {total_count} repos tracked

**Next steps**: `/mykit.mcp.review` to check MCP server configuration
```

---

## Error Handling

| Error | Message |
|-------|---------|
| gh not installed | "gh CLI not found. Install from https://cli.github.com/" |
| Repo not found | "Repo `{name}` not found on GitHub." |
| Already cataloged | "Repo `{name}` is already in the catalog." |
| JSON write error | "Failed to update repos.json: {error}" |
