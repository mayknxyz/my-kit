# /mykit.upgrade

Upgrade My Kit to the latest version or a specific version.

## Usage

```
/mykit.upgrade [--list] [--version VERSION]
```

- Executes directly: Upgrade to the latest version
- `--list`: Show all available versions instead of upgrading
- `--version VERSION`: Upgrade to a specific version (e.g., `v0.2.0`)

## Instructions

You are Claude, the AI assistant. When this command is invoked, execute the appropriate mode based on the flags provided.

### Parse Arguments

```
$ARGUMENTS
```

Extract the following from arguments:
- `--list`: If present, show all available versions (skip upgrade)
- `--version VERSION`: If present, target specific version (e.g., `v0.2.0`)

### Execute Mode

**If `--list` flag is present:**

Run the version listing by sourcing the upgrade utilities:

```bash
source $HOME/.claude/skills/mykit/references/scripts/version.sh && list_all_versions | format_version_list
```

Display the output showing all available versions with:
- Current version marked with `*`
- Latest version marked with `<- latest`
- Release dates for each version

---

**If neither `--run` nor `--list` (Preview Mode - Default):**

Show upgrade preview:

1. Read current version from `$HOME/.claude/skills/mykit/references/VERSION`
2. Run: `source $HOME/.claude/skills/mykit/references/scripts/version.sh && get_latest_version`
3. Display:
   - Current installed version
   - Latest available version
   - Changelog summary (if available via `get_changelog`)
   - Instructions to run `/mykit.upgrade --run` to execute

---

**If `--run` flag is present (Execution Mode):**

My Kit v2 uses GNU Stow for deployment. The upgrade process is:

1. Navigate to the my-kit-v2 source repo:
   ```bash
   cd ~/my-kit-v2
   ```

2. Pull the latest changes:
   ```bash
   git pull origin main
   ```

3. Re-stow to update symlinks:
   ```bash
   stow -R -t ~ kit
   ```

4. Read the new version from `$HOME/.claude/skills/mykit/references/VERSION`

5. Display:
   ```
   Upgrade complete! Now running {new_version}
   ```

**If `--version` flag is provided**, checkout the specific tag before stowing:
```bash
cd ~/my-kit-v2 && git fetch --tags && git checkout {VERSION} && stow -R -t ~ kit
```

### Error Handling

Handle these error cases with clear messages:

| Error | Message | Exit Code |
|-------|---------|-----------|
| Network failure | "Could not connect to GitHub. Check your network." | 3 |
| Not a stow package | "my-kit-v2 repo not found at ~/my-kit-v2" | 1 |
| Invalid version | "Version X does not exist" with list of valid versions | 1 |
| Stow conflict | "Stow conflict detected — resolve with `stow -D -t ~ kit` then retry" | 1 |
| Missing dependencies | List missing tools (git, stow, gh) | 2 |

### Notes

- Configuration file `.mykit/config.json` (per-project) is NEVER modified during upgrade
- Per-project state (`.mykit/state.json`, `.mykit/memory/`) is unaffected
- Stow manages symlinks — only global infrastructure under `~/.claude/` is updated
- Use `stow -n -t ~ kit` for a dry run to preview changes

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
