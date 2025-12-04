# /mykit.upgrade

Upgrade My Kit to the latest version or a specific version.

## Usage

```
/mykit.upgrade [--run] [--list] [--version VERSION]
```

## Modes

| Mode | Command | Description |
|------|---------|-------------|
| Preview | `/mykit.upgrade` | Show current and latest versions (default) |
| Execute | `/mykit.upgrade --run` | Upgrade to latest version |
| List | `/mykit.upgrade --list` | Show all available versions |
| Pinned | `/mykit.upgrade --run --version X` | Upgrade to specific version |

## Instructions

You are Claude, the AI assistant. When this command is invoked, execute the appropriate mode based on the flags provided.

### Parse Arguments

```
$ARGUMENTS
```

Extract the following from arguments:
- `--run`: If present, execute upgrade (otherwise preview only)
- `--list`: If present, show all available versions
- `--version VERSION`: If present, target specific version (e.g., `v0.2.0`)

### Execute Mode

**If `--list` flag is present:**

Run the version listing by sourcing the upgrade utilities:

```bash
cd "$(git rev-parse --show-toplevel)" && source .mykit/scripts/upgrade.sh && show_versions
```

Display the output showing all available versions with:
- Current version marked with `*`
- Latest version marked with `<- latest`
- Release dates for each version

---

**If neither `--run` nor `--list` (Preview Mode - Default):**

Show upgrade preview by sourcing the upgrade utilities:

```bash
cd "$(git rev-parse --show-toplevel)" && source .mykit/scripts/upgrade.sh && show_preview
```

Display:
- Current installed version
- Latest available version
- Changelog summary (if available)
- Instructions to run `/mykit.upgrade --run` to execute

---

**If `--run` flag is present (Execution Mode):**

First, validate the operation:

1. Check if `--version` flag was provided
2. If downgrading (target version older than current), display warning:
   ```
   Warning: Downgrading from [current] to [target]

   Downgrading may cause:
   - Loss of newer command features
   - Configuration compatibility issues

   Do you want to proceed? (yes/no)
   ```
3. If user confirms, or if upgrading (not downgrading), proceed

Execute the upgrade:

```bash
cd "$(git rev-parse --show-toplevel)" && source .mykit/scripts/upgrade.sh && run_upgrade "[VERSION]"
```

Replace `[VERSION]` with the target version if `--version` was specified, or leave empty for latest.

Display progress:
- Validating dependencies...
- Creating backup...
- Downloading files...
- Verifying checksums...
- Installing files...
- Upgrade complete! Now running [version]

### Error Handling

Handle these error cases with clear messages:

| Error | Message | Exit Code |
|-------|---------|-----------|
| Network failure | "Could not connect to GitHub" with troubleshooting steps | 3 |
| Lock conflict | "Another upgrade is in progress (PID: X)" with unlock instructions | 1 |
| Invalid version | "Version X does not exist" with list of valid versions | 1 |
| Write permission | "No write permission to installation directory" | 4 |
| Missing dependencies | List missing tools (curl, git, gh) | 2 |

### Notes

- Configuration file `.mykit/config.json` is NEVER modified during upgrade
- Backup is created before any changes at `.mykit/backup/.last-backup/`
- If upgrade fails at any point, automatic rollback from backup occurs
- Lock file prevents concurrent upgrade operations

## Examples

**Preview available updates:**
```
/mykit.upgrade
```

**Upgrade to latest version:**
```
/mykit.upgrade --run
```

**List all available versions:**
```
/mykit.upgrade --list
```

**Upgrade to specific version:**
```
/mykit.upgrade --run --version v0.2.0
```

**Downgrade to older version:**
```
/mykit.upgrade --run --version v0.1.0
```
