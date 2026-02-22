# /mykit.repos.review

Review the repo catalog against GitHub and local disk.

## Usage

```
/mykit.repos.review
```

## Description

Fetches repos from GitHub, auto-locates them on disk, and cross-references with the catalog (`data/repos.json`). Displays a summary report showing cataloged, uncataloged, and stale repos.

## Implementation

When this command is invoked, perform the following steps:

### Step 1: Check Prerequisites

```bash
command -v gh
gh auth status
```

If `gh` is not installed or not authenticated, display error and stop.

### Step 2: Read Catalog

Read `data/repos.json` from the my-kit repo root (`$HOME/my-kit/data/repos.json`).

If the file doesn't exist, create it with the seed schema:

```json
{
  "version": 1,
  "updated_at": "<current ISO timestamp>",
  "repos": []
}
```

### Step 3: Fetch GitHub Repos

```bash
gh repo list --json name,owner,description --limit 100
```

Parse the JSON output to get the list of GitHub repos.

### Step 4: Auto-Locate on Disk

For each GitHub repo, check these paths in order for a `.git` directory:

1. `$HOME/{name}`
2. `$HOME/dev/github/{name}`
3. `$HOME/dev/{name}`

Record the first match as `local_path`. If none found, mark as "not found locally".

### Step 5: Cross-Reference

Compare the three data sources (GitHub, catalog, disk) and categorize each repo:

- **Cataloged**: In `repos.json` and found on GitHub
- **Uncataloged**: On GitHub (and possibly on disk) but not in `repos.json`
- **Stale**: In `repos.json` but `local_path` no longer exists on disk

### Step 6: Display Report

Display a formatted table:

```
## Repo Catalog Review

### Summary
- **GitHub repos**: {count}
- **Cataloged**: {count}
- **Uncataloged**: {count}
- **Stale**: {count}

### Cataloged Repos

| Repo | Local Path | MCP Servers | Last Audit |
|------|-----------|-------------|------------|
| {name} | {path} | {count} | {date or "never"} |

### Uncataloged Repos (on GitHub but not in catalog)

| Repo | Local Path | Description |
|------|-----------|-------------|
| {name} | {path or "not found"} | {description} |

### Stale Entries (in catalog but path missing)

| Repo | Expected Path |
|------|--------------|
| {name} | {path} |
```

If there are uncataloged repos found locally, suggest:

```
**Tip**: Run `/mykit.repos.add {name}` to catalog a repo.
```

---

## Error Handling

| Error | Message |
|-------|---------|
| gh not installed | "gh CLI not found. Install from https://cli.github.com/" |
| gh not authenticated | "Not authenticated. Run `gh auth login` first." |
| GitHub API error | "Failed to fetch repos from GitHub: {error}" |
