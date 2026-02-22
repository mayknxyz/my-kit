# /mykit.mcp.add

Add an MCP server to a repo's `.mcp.json` from a template.

## Usage

```
/mykit.mcp.add [server-name] [repo-name-or-path]
```

## Description

Lists available MCP server templates, lets the user select one, shows a diff preview of changes to `.mcp.json`, and merges with confirmation.

## Implementation

When this command is invoked, perform the following steps:

### Step 1: Resolve Target Repo

Determine the target repo using this priority:

1. **Second argument**: If user passed a repo path/name as second arg, use it
2. **Current directory**: If cwd is a git repo, use it
3. **Prompt from catalog**: Read `data/repos.json` and ask via `AskUserQuestion`:
   - header: "Repo"
   - question: "Which repo do you want to add an MCP server to?"
   - options: List cataloged repos with local paths

Resolve to a `local_path` on disk. If the path doesn't exist, display error and stop.

### Step 2: Resolve Server Template

Scan `$HOME/.claude/skills/mykit-repos/references/mcp-templates/` for available templates.

If user provided a server name as first argument:
- Match against template names
- If no match, display error and stop:
  ```
  **Error**: No template found for `{name}`. Available: {template list}
  ```

If no argument, prompt via `AskUserQuestion`:
- header: "Server"
- question: "Which MCP server do you want to add?"
- options: List available templates with `name` as label and `description` as description
  - Exclude servers already installed in the repo's `.mcp.json`

If all templates are already installed, display and stop:

```
**Info**: All available MCP servers are already installed in this repo.
```

### Step 3: Read Existing Config

Read `.mcp.json` from the repo root. If it doesn't exist, start with an empty skeleton:

```json
{
  "mcpServers": {}
}
```

Detect the format (flat vs nested `mcpServers`). Use the existing format for consistency, defaulting to nested `mcpServers` for new files.

### Step 4: Check for Duplicate

If the server is already installed, display and stop:

```
**Info**: `{server-name}` is already installed in this repo's `.mcp.json`.
```

### Step 5: Diff Preview

Show what will change:

```
## Adding: {server-name}

**Description**: {template description}
**Repo**: {repo-name} ({local_path})

### Changes to .mcp.json

Added:
+ "{server-name}": {
+   "command": "{command}",
+   "args": {args}
+ }
```

### Step 6: Confirm

Ask via `AskUserQuestion`:
- header: "Confirm"
- question: "Add `{server-name}` to {repo-name}/.mcp.json?"
- options:
  1. label: "Add server", description: "Write changes to .mcp.json"
  2. label: "Cancel", description: "Don't make changes"

If "Cancel", display "Cancelled." and stop.

### Step 7: Merge and Write

Add the server config to the `.mcp.json` object (under `mcpServers` if nested format, or at root if flat format). Write the file with 2-space indentation.

### Step 8: Update Catalog

If the repo is in `data/repos.json`, update its `mcp_servers` array to include the new server name.

### Step 9: Display Success

```
## MCP Server Added

**Server**: {server-name}
**Repo**: {repo-name}
**Config**: {.mcp.json path}

The server will be available in the next Claude Code session in this repo.

**Next steps**: Run `/mykit.mcp.review` to see all installed servers.
```

---

## Error Handling

| Error | Message |
|-------|---------|
| Repo not found locally | "Repo not found locally at `{path}`." |
| Template not found | "No template found for `{name}`." |
| Already installed | "`{name}` is already installed." |
| JSON write error | "Failed to write `.mcp.json`: {error}" |
