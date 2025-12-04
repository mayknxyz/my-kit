# Quickstart: Self-Upgrade Command

**Feature Branch**: `002-mykit-upgrade`
**Date**: 2025-12-04

## Overview

The `/mykit.upgrade` command enables users to upgrade My Kit from within Claude Code. This guide covers usage patterns and implementation structure.

---

## Usage

### Preview Available Updates (Default)

```bash
/mykit.upgrade
```

**Output**:
```
My Kit Upgrade

Current version: v0.1.0
Latest version:  v0.2.0

Changes in v0.2.0:
- Added /mykit.upgrade command for self-upgrade
- Improved error handling in /mykit.commit
- Fixed issue with PR creation on Windows

To upgrade, run: /mykit.upgrade --run
```

### Upgrade to Latest Version

```bash
/mykit.upgrade --run
```

**Output**:
```
Upgrading My Kit from v0.1.0 to v0.2.0...

✓ Dependencies validated
✓ Backup created
✓ Files downloaded (17 files)
✓ Checksums verified
✓ Files installed

Upgrade complete! Now running v0.2.0
```

### List Available Versions

```bash
/mykit.upgrade --list
```

**Output**:
```
Available versions:

  v0.2.0  (2025-12-04)  ← latest
* v0.1.0  (2025-12-01)  ← current
  v0.0.1  (2025-11-28)

Use --version to upgrade to a specific version.
```

### Upgrade to Specific Version

```bash
/mykit.upgrade --run --version v0.1.5
```

**Output**:
```
Upgrading My Kit to v0.1.5...

✓ Dependencies validated
✓ Backup created
✓ Files downloaded
✓ Checksums verified
✓ Files installed

Upgrade complete! Now running v0.1.5
```

### Downgrade Warning

```bash
/mykit.upgrade --run --version v0.0.1
```

**Output**:
```
⚠ Warning: Downgrading from v0.1.0 to v0.0.1

Downgrading may cause:
- Loss of newer command features
- Configuration compatibility issues

Continue? (y/n)
```

---

## Error Handling

### Already Up to Date

```
My Kit Upgrade

Current version: v0.2.0
Latest version:  v0.2.0

✓ Already running the latest version!
```

### Network Error

```
✗ Error: Could not connect to GitHub

Please check:
- Network connectivity
- GitHub status (https://www.githubstatus.com/)
- gh CLI authentication (gh auth status)

Exit code: 3
```

### Concurrent Upgrade

```
✗ Error: Another upgrade is in progress (PID: 12345)

Wait for the current upgrade to complete, or remove the lock file:
  rm /var/tmp/mykit-upgrade.lock

Exit code: 1
```

### Modified Files Warning

```
⚠ Warning: 2 locally modified files detected:

  .mykit/scripts/utils.sh
  .claude/commands/mykit.commit.md

These files will be backed up before overwriting.
Continue? (y/n)
```

---

## Implementation Structure

### Files to Create

```text
.claude/commands/
└── mykit.upgrade.md       # Slash command definition

.mykit/scripts/
├── upgrade.sh             # Core upgrade logic
└── version.sh             # Version checking utilities
```

### Script Dependencies

```text
upgrade.sh
├── sources: version.sh
├── sources: utils.sh (existing)
└── uses: flock, curl, gh
```

### Key Functions

**version.sh**:
- `get_current_version()` - Get installed version from git tag
- `get_latest_version()` - Fetch latest from GitHub
- `list_all_versions()` - List all available versions
- `is_upgrade_available()` - Compare versions
- `version_exists()` - Validate version tag exists

**upgrade.sh**:
- `acquire_lock()` - Prevent concurrent upgrades
- `create_backup()` - Backup current installation
- `download_files()` - Fetch files from GitHub release
- `verify_checksums()` - Validate downloaded files
- `detect_modified_files()` - Check for local modifications
- `install_files()` - Atomic file installation
- `restore_backup()` - Rollback on failure

---

## Command Pattern

Following My Kit conventions (Constitution III):

| Mode | Command | Behavior |
|------|---------|----------|
| Preview | `/mykit.upgrade` | Shows versions, no changes |
| Execute | `/mykit.upgrade --run` | Performs upgrade |
| List | `/mykit.upgrade --list` | Shows all versions |
| Specific | `/mykit.upgrade --run --version X` | Upgrades to version X |

---

## Exit Codes

Per CLI interface contract:

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error (lock failed, invalid version) |
| 2 | Pre-condition failure (validation gate blocked) |
| 3 | Network error (cannot reach GitHub) |
| 4 | Filesystem error (write failed, backup failed) |

---

## Testing Checklist

1. **Preview mode**
   - [ ] Shows current and latest version
   - [ ] Shows changelog summary
   - [ ] Does not modify any files

2. **Execution mode**
   - [ ] Creates backup before changes
   - [ ] Preserves `.mykit/config.json`
   - [ ] Updates all command files
   - [ ] Updates all script files
   - [ ] Verifies checksums after download

3. **Error handling**
   - [ ] Network failure shows clear message
   - [ ] Lock prevents concurrent upgrades
   - [ ] Invalid version shows available versions
   - [ ] Failed upgrade restores from backup

4. **Edge cases**
   - [ ] Already at latest version
   - [ ] Downgrade warning displayed
   - [ ] Modified files warning displayed
   - [ ] Works without internet for backup/restore
