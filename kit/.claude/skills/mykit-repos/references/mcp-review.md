# /mykit.mcp.review

Review MCP server configuration for a repo.

## Usage

```
/mykit.mcp.review [repo-name-or-path]
```

## Description

Reads a repo's `.mcp.json`, compares with available templates, and displays a report of installed vs available vs custom servers.

## Implementation

When this command is invoked, perform the following steps:

### Step 1: Resolve Target Repo

Determine the target repo using this priority:

1. **Argument provided**: If user passed a repo name or path, use it
2. **Current directory**: If cwd is a git repo, use it
3. **Prompt from catalog**: Read `data/repos.json` and ask via `AskUserQuestion`:
   - header: "Repo"
   - question: "Which repo do you want to review MCP servers for?"
   - options: List cataloged repos with local paths

Resolve to a `local_path` on disk. If the path doesn't exist, display error and stop:

```
**Error**: Repo not found locally at `{path}`.
```

### Step 2: Read .mcp.json

Read `.mcp.json` from the repo root. The file may use either format:

**Format A** (flat — older style):
```json
{
  "server-name": {
    "command": "npx",
    "args": [...]
  }
}
```

**Format B** (nested — newer style):
```json
{
  "mcpServers": {
    "server-name": {
      "command": "npx",
      "args": [...]
    }
  }
}
```

Normalize to a map of `server-name → config`. If no `.mcp.json` exists, treat as empty.

### Step 3: Scan Available Templates

Read all `.json` files from `$HOME/.claude/skills/mykit-repos/references/mcp-templates/`. Parse each to get `name`, `description`, and `config`.

### Step 4: Categorize Servers

For each installed server, check if it matches a template by name:

- **Installed (from template)**: Server name matches a template
- **Installed (custom)**: Server name doesn't match any template
- **Available**: Template exists but server is not installed
- **Drift detected**: Server is installed from template but config differs

### Step 5: Display Report

```
## MCP Review: {repo-name}

**Path**: {local_path}
**Config**: {.mcp.json path}

### Installed Servers ({count})

| Server | Source | Status |
|--------|--------|--------|
| {name} | template | OK |
| {name} | template | drift detected |
| {name} | custom | — |

### Available Templates (not installed) ({count})

| Server | Description |
|--------|-------------|
| {name} | {description} |

### Drift Details

If any drift detected, show the diff:

**{server-name}**:
- Template: `{template config summary}`
- Installed: `{actual config summary}`
```

If no `.mcp.json` exists:

```
## MCP Review: {repo-name}

**Path**: {local_path}
**Config**: No `.mcp.json` found

### Available Templates ({count})

| Server | Description |
|--------|-------------|
| {name} | {description} |

**Tip**: Run `/mykit.mcp.add` to install a server.
```

---

## Error Handling

| Error | Message |
|-------|---------|
| Repo not found locally | "Repo not found locally at `{path}`." |
| Invalid .mcp.json | "Failed to parse `.mcp.json`: {error}" |
| No templates found | "No MCP templates found. Check skill installation." |
