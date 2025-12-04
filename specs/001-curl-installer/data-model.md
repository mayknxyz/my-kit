# Data Model: Curl-Based Installer

**Feature**: 001-curl-installer
**Date**: 2025-12-04

## Overview

The installer manages file entities that are downloaded from GitHub and placed in the user's project directory. This document defines the file manifest and data structures used by the installer.

## Entities

### 1. Installation Manifest

The installer maintains a list of files to download. This manifest is embedded in the script.

**Structure**:
```bash
# Commands to install in .claude/commands/
COMMAND_FILES=(
  "mykit.init.md"
  "mykit.setup.md"
  "mykit.start.md"
  "mykit.status.md"
  "mykit.backlog.md"
  "mykit.specify.md"
  "mykit.plan.md"
  "mykit.tasks.md"
  "mykit.implement.md"
  "mykit.validate.md"
  "mykit.commit.md"
  "mykit.pr.md"
  "mykit.release.md"
  "mykit.resume.md"
  "mykit.reset.md"
  "mykit.upgrade.md"
  "mykit.help.md"
)

# Scripts to install in .mykit/scripts/
SCRIPT_FILES=(
  "utils.sh"
  "github-api.sh"
  "git-ops.sh"
  "validation.sh"
)

# Templates to install in .mykit/templates/
TEMPLATE_FILES=(
  "lite/spec.md"
  "lite/plan.md"
  "lite/tasks.md"
)
```

**Notes**:
- These represent the target state once My Kit commands are implemented
- Initial release may have a subset of these files
- Manifest should be updated as new commands are added

### 2. Configuration File

**Path**: `.mykit/config.json`

**Structure**:
```json
{
  "version": "1.0.0",
  "github": {
    "default_base_branch": "main",
    "auto_assign_pr": true,
    "draft_pr_by_default": false
  },
  "validation": {
    "auto_fix": true
  },
  "release": {
    "version_bump_strategy": "auto",
    "delete_branch_after_release": true,
    "close_issue_after_release": true
  }
}
```

**Behavior**:
- Created only if file does not exist
- Never overwritten on reinstall/upgrade
- User modifications are preserved

### 3. Installation State

**Temporary directory structure** (during installation):
```text
$TEMP_DIR/
├── commands/           # Downloaded command files
│   └── mykit.*.md
├── scripts/            # Downloaded script files
│   └── *.sh
└── templates/          # Downloaded template files
    └── lite/
```

**Final directory structure** (after successful installation):
```text
.claude/
└── commands/
    └── mykit.*.md      # Slash command definitions

.mykit/
├── config.json         # User configuration (created if not exists)
├── scripts/            # Shell utilities
│   └── *.sh
└── templates/          # Command templates
    └── lite/
```

### 4. Backup State (for rollback)

When upgrading an existing installation:

**Path**: `$TEMP_DIR/backup/`

**Structure**:
```text
$TEMP_DIR/backup/
├── commands/           # Backed up command files
└── scripts/            # Backed up script files
```

**Behavior**:
- Backup created before overwriting existing files
- Restored if installation fails
- Deleted on successful completion

## State Transitions

### Installation States

```
[Not Installed] --> [Downloading] --> [Staging] --> [Installing] --> [Complete]
                          |               |              |
                          v               v              v
                     [Cleanup]       [Cleanup]      [Cleanup]
                     (on error)     (on error)     (on error)
```

| State | Description | Rollback Action |
|-------|-------------|-----------------|
| Not Installed | No My Kit files present | N/A |
| Downloading | Fetching files to temp | Delete temp dir |
| Staging | All files downloaded | Delete temp dir |
| Installing | Moving files to final locations | Restore backup |
| Complete | Installation successful | N/A |
| Cleanup | Error occurred, reverting | Delete temp, restore backup |

## Validation Rules

### Prerequisite Checks

| Check | Command | Error Code |
|-------|---------|------------|
| git installed | `command -v git` | 2 |
| gh CLI installed | `command -v gh` | 2 |
| In git repository | `git rev-parse --is-inside-work-tree` | 2 |
| Write permission | `touch .mykit/.test && rm .mykit/.test` | 2 |

### File Download Validation

| Check | Method | Error Code |
|-------|--------|------------|
| Download success | curl exit code | 3 |
| File not empty | `[[ -s "$file" ]]` | 3 |
| All files present | Loop through manifest | 3 |

## Exit Codes

| Code | Meaning | Example |
|------|---------|---------|
| 0 | Success | Installation complete |
| 1 | General error | Unknown error |
| 2 | Pre-condition failure | Missing prerequisite, not a git repo |
| 3 | Network/download error | GitHub unreachable, file not found |
| 4 | File system error | Cannot write to directory |
