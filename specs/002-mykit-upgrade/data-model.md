# Data Model: Self-Upgrade Command

**Feature Branch**: `002-mykit-upgrade`
**Date**: 2025-12-04

## Overview

This document defines the data entities, their attributes, and relationships for the `/mykit.upgrade` command.

---

## Entities

### Version

Represents a release of My Kit on GitHub.

| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| `tag` | string | Semver version tag (e.g., `v0.2.0`) | GitHub release |
| `published_at` | ISO-8601 date | Release publication date | GitHub release |
| `is_prerelease` | boolean | Whether this is a pre-release | GitHub release |
| `changelog` | string | Release notes/body | GitHub release |

**Validation Rules**:
- `tag` must match pattern `^v[0-9]+\.[0-9]+\.[0-9]+$`
- `published_at` must be a valid ISO-8601 timestamp

**Relationships**:
- One Version has one Manifest (embedded in release)

---

### Manifest

Checksums for all files in a specific version.

| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| `version` | string | Associated version tag | Header comment |
| `generated_at` | ISO-8601 date | Generation timestamp | Header comment |
| `entries` | array | List of file checksums | File content |

**Entry Structure**:
| Field | Type | Description |
|-------|------|-------------|
| `checksum` | string | SHA-256 hash (64 hex chars) |
| `filepath` | string | Relative path from repo root |

**File Format** (standard sha256sum):
```text
# manifest-sha256.txt
# Version: v0.2.0
# Generated: 2025-12-04T10:30:00Z

9f86d081884c7d659ffd60bb51d1c3f9...  .claude/commands/mykit.upgrade.md
a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6...  .mykit/scripts/upgrade.sh
```

**Validation Rules**:
- `checksum` must be 64 hexadecimal characters
- `filepath` must be a valid relative path

**Storage Location**: `.mykit/.manifests/`

---

### Backup

Snapshot of the current installation before upgrade.

| Attribute | Type | Description | Storage |
|-----------|------|-------------|---------|
| `backup_time` | ISO-8601 date | When backup was created | `.backup-time` file |
| `backup_version` | string | Version being backed up | `.backup-version` file |
| `commands/` | directory | Copy of `.claude/commands/` | Directory |
| `scripts/` | directory | Copy of `.mykit/scripts/` | Directory |
| `templates/` | directory | Copy of `.mykit/templates/` | Directory |

**Retention Policy**: Only most recent backup retained (per clarification)

**Storage Location**: `.mykit/backup/.last-backup/`

**Directory Structure**:
```text
.mykit/backup/.last-backup/
├── .backup-time        # ISO-8601 timestamp
├── .backup-version     # e.g., "v0.1.0"
├── commands/           # Backup of .claude/commands/
├── scripts/            # Backup of .mykit/scripts/
└── templates/          # Backup of .mykit/templates/
```

---

### Configuration

User settings that persist across upgrades.

| Attribute | Type | Description | Default |
|-----------|------|-------------|---------|
| `version` | string | Config schema version | `"1.0.0"` |
| `github.default_base_branch` | string | Default PR base | `"main"` |
| `github.auto_assign_pr` | boolean | Auto-assign PR to author | `true` |
| `github.draft_pr_by_default` | boolean | Create draft PRs | `false` |
| `validation.auto_fix` | boolean | Auto-fix lint issues | `true` |
| `release.version_bump_strategy` | string | Auto/manual version bumps | `"auto"` |
| `release.delete_branch_after_release` | boolean | Clean up feature branches | `true` |
| `release.close_issue_after_release` | boolean | Auto-close linked issues | `true` |

**Validation Rules**:
- Must be valid JSON
- `version` must be semver format

**Storage Location**: `.mykit/config.json`

**Preservation**: Never overwritten during upgrade (FR-004)

---

### Lock

Prevents concurrent upgrade operations.

| Attribute | Type | Description |
|-----------|------|-------------|
| `pid` | integer | Process ID holding lock |

**File Format**: Single line containing PID

**Storage Location**: `${XDG_RUNTIME_DIR}/mykit-upgrade.lock` or `/var/tmp/mykit-upgrade.lock`

**Lifecycle**:
1. Created when upgrade starts
2. Contains PID for diagnostics
3. Released automatically via `flock` when process exits
4. Deleted on cleanup

---

## State Transitions

### Upgrade State Machine

```text
                    ┌─────────────┐
                    │   IDLE      │
                    └──────┬──────┘
                           │ /mykit.upgrade --run
                           ▼
                    ┌─────────────┐
              ┌─────│ LOCK_ACQUIRE│─────┐
              │     └──────┬──────┘     │
              │            │            │ Lock failed
              │            │            ▼
              │            │     ┌─────────────┐
              │            │     │   ERROR     │
              │            │     └─────────────┘
              │            ▼
              │     ┌─────────────┐
              │     │ VERSION_CHK │
              │     └──────┬──────┘
              │            │
              │            ▼
              │     ┌─────────────┐
              │     │ BACKUP      │
              │     └──────┬──────┘
              │            │
              │            ▼
              │     ┌─────────────┐
              │     │ DOWNLOAD    │────────┐
              │     └──────┬──────┘        │ Network error
              │            │               ▼
              │            │        ┌─────────────┐
              │            │        │  RESTORE    │
              │            │        └─────────────┘
              │            ▼
              │     ┌─────────────┐
              │     │ VERIFY      │────────┐
              │     └──────┬──────┘        │ Checksum fail
              │            │               ▼
              │            │        ┌─────────────┐
              │            │        │  RESTORE    │
              │            │        └─────────────┘
              │            ▼
              │     ┌─────────────┐
              │     │ INSTALL     │────────┐
              │     └──────┬──────┘        │ Write error
              │            │               ▼
              │            │        ┌─────────────┐
              │            │        │  RESTORE    │
              │            │        └─────────────┘
              │            ▼
              │     ┌─────────────┐
              └────▶│ COMPLETE    │
                    └─────────────┘
```

---

## File System Layout

### Before Upgrade

```text
.claude/
└── commands/
    └── mykit.*.md           # Existing commands

.mykit/
├── config.json              # User config (preserved)
├── scripts/
│   ├── utils.sh
│   ├── github-api.sh
│   ├── git-ops.sh
│   └── validation.sh
└── templates/
    └── lite/
        ├── spec.md
        ├── plan.md
        └── tasks.md
```

### After Upgrade (new files)

```text
.claude/
└── commands/
    └── mykit.upgrade.md     # NEW: Slash command

.mykit/
├── config.json              # PRESERVED
├── scripts/
│   ├── utils.sh             # UPDATED
│   ├── github-api.sh        # UPDATED
│   ├── git-ops.sh           # UPDATED
│   ├── validation.sh        # UPDATED
│   ├── upgrade.sh           # NEW: Core upgrade logic
│   └── version.sh           # NEW: Version utilities
├── templates/
│   └── lite/
│       ├── spec.md          # UPDATED
│       ├── plan.md          # UPDATED
│       └── tasks.md         # UPDATED
├── backup/
│   └── .last-backup/        # NEW: Backup directory
│       ├── .backup-time
│       ├── .backup-version
│       ├── commands/
│       ├── scripts/
│       └── templates/
└── .manifests/
    └── manifest-sha256.txt  # NEW: Checksum manifest
```

---

## Data Volume Estimates

| Entity | Expected Size | Count |
|--------|---------------|-------|
| Version (GitHub) | ~100 versions over lifetime | Fetched on demand |
| Manifest | ~2-5 KB per version | 1 stored locally |
| Backup | ~50-100 KB | 1 (most recent only) |
| Configuration | ~500 bytes | 1 |
| Lock | ~10 bytes | 1 (transient) |

**Total Local Storage**: < 200 KB
