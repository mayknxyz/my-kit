# /mykit.repos.remove

Remove a repo from the catalog.

## Usage

```
/mykit.repos.remove [repo-name]
```

## Description

Lists cataloged repos, prompts for selection (if no argument), confirms removal, and updates `data/repos.json`.

## Implementation

When this command is invoked, perform the following steps:

### Step 1: Read Catalog

Read `data/repos.json` from `$HOME/my-kit/data/repos.json`.

If the file doesn't exist or has no repos, display and stop:

```
**Info**: No repos in the catalog. Nothing to remove.
```

### Step 2: Resolve Repo

If user provided a repo name argument:
- Find the matching entry by `name` or `full_name`
- If not found, display error and stop:
  ```
  **Error**: `{name}` not found in the catalog.
  ```

If no argument, prompt via `AskUserQuestion`:
- header: "Remove"
- question: "Which repo do you want to remove from the catalog?"
- options: List all cataloged repos with their `full_name` as labels and `local_path` as descriptions

### Step 3: Confirm Removal

Display the repo details and ask via `AskUserQuestion`:

```
**Removing**: {full_name}
**Path**: {local_path}
**Stack**: {framework}, {language}
**MCP**: {server count} servers
**Added**: {added_at}
```

- header: "Confirm"
- question: "Remove {full_name} from the catalog? (This only removes the catalog entry, not the repo itself.)"
- options:
  1. label: "Remove", description: "Remove from catalog"
  2. label: "Cancel", description: "Keep in catalog"

If "Cancel", display "Cancelled." and stop.

### Step 4: Remove and Write

Remove the entry from the `repos` array. Update `updated_at`. Write back to `data/repos.json`.

### Step 5: Display Confirmation

```
## Repo Removed

**Removed**: {full_name}
**Catalog**: {remaining_count} repos tracked

Note: The repo files on disk and on GitHub are unchanged.
```

---

## Error Handling

| Error | Message |
|-------|---------|
| Empty catalog | "No repos in the catalog. Nothing to remove." |
| Repo not found | "`{name}` not found in the catalog." |
| JSON write error | "Failed to update repos.json: {error}" |
