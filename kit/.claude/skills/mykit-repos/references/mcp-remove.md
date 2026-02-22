# /mykit.mcp.remove

Remove an MCP server from a repo's `.mcp.json`.

## Usage

```
/mykit.mcp.remove [server-name] [repo-name-or-path]
```

## Description

Lists installed MCP servers in a repo, lets the user select one, shows a diff preview, and removes with confirmation.

## Implementation

When this command is invoked, perform the following steps:

### Step 1: Resolve Target Repo

Determine the target repo using this priority:

1. **Second argument**: If user passed a repo path/name as second arg, use it
2. **Current directory**: If cwd is a git repo, use it
3. **Prompt from catalog**: Read `data/repos.json` and ask via `AskUserQuestion`:
   - header: "Repo"
   - question: "Which repo do you want to remove an MCP server from?"
   - options: List cataloged repos with local paths

Resolve to a `local_path` on disk. If the path doesn't exist, display error and stop.

### Step 2: Read .mcp.json

Read `.mcp.json` from the repo root. If it doesn't exist, display and stop:

```
**Info**: No `.mcp.json` found in {repo-name}. Nothing to remove.
```

Parse and normalize the server list (handle both flat and nested `mcpServers` format).

If no servers are installed, display and stop:

```
**Info**: No MCP servers configured in {repo-name}. Nothing to remove.
```

### Step 3: Resolve Server

If user provided a server name as first argument:
- Match against installed server names
- If no match, display error and stop:
  ```
  **Error**: `{name}` is not installed. Installed servers: {list}
  ```

If no argument, prompt via `AskUserQuestion`:
- header: "Remove"
- question: "Which MCP server do you want to remove?"
- options: List installed servers with name as label and command as description

### Step 4: Diff Preview

Show what will change:

```
## Removing: {server-name}

**Repo**: {repo-name} ({local_path})

### Changes to .mcp.json

Removed:
- "{server-name}": {
-   "command": "{command}",
-   "args": {args}
- }
```

### Step 5: Confirm

Ask via `AskUserQuestion`:
- header: "Confirm"
- question: "Remove `{server-name}` from {repo-name}/.mcp.json?"
- options:
  1. label: "Remove server", description: "Write changes to .mcp.json"
  2. label: "Cancel", description: "Don't make changes"

If "Cancel", display "Cancelled." and stop.

### Step 6: Remove and Write

Remove the server key from the `.mcp.json` object. Write the file with 2-space indentation.

If the resulting `mcpServers` object (or root object in flat format) is empty, ask via `AskUserQuestion`:
- header: "Empty config"
- question: "No MCP servers remain. Delete `.mcp.json` entirely?"
- options:
  1. label: "Delete file", description: "Remove .mcp.json"
  2. label: "Keep empty", description: "Keep .mcp.json with empty config"

### Step 7: Update Catalog

If the repo is in `data/repos.json`, update its `mcp_servers` array to remove the server name.

### Step 8: Display Success

```
## MCP Server Removed

**Server**: {server-name}
**Repo**: {repo-name}
**Remaining**: {remaining_count} servers

The change takes effect in the next Claude Code session in this repo.
```

---

## Error Handling

| Error | Message |
|-------|---------|
| Repo not found locally | "Repo not found locally at `{path}`." |
| No .mcp.json | "No `.mcp.json` found. Nothing to remove." |
| Server not installed | "`{name}` is not installed." |
| JSON write error | "Failed to write `.mcp.json`: {error}" |
