# CLI Interface Contract: install.sh

**Feature**: 001-curl-installer
**Date**: 2025-12-04

## Overview

This document defines the command-line interface contract for the `install.sh` script. Since this is a shell script (not an API), the "contract" describes inputs, outputs, environment, and exit codes.

## Invocation

### Primary Usage (curl pipe)

```bash
curl -fsSL https://raw.githubusercontent.com/mayknxyz/my-kit/main/install.sh | bash
```

### Direct Execution

```bash
# Download and run
curl -fsSL https://raw.githubusercontent.com/mayknxyz/my-kit/main/install.sh -o install.sh
chmod +x install.sh
./install.sh
```

## Environment Requirements

### Required Commands

| Command | Minimum Version | Purpose |
|---------|-----------------|---------|
| bash | 4.0+ | Script interpreter |
| curl | any | File downloads |
| git | any | Repository detection |
| gh | any | GitHub CLI (prerequisite) |
| mktemp | any | Temp directory creation |

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MYKIT_BRANCH` | `main` | GitHub branch to download from |
| `MYKIT_REPO` | `mayknxyz/my-kit` | GitHub repository |

**Example**: Install from a specific branch:
```bash
MYKIT_BRANCH=develop curl -fsSL https://raw.githubusercontent.com/mayknxyz/my-kit/develop/install.sh | bash
```

## Output Contract

### Standard Output (stdout)

Progress messages and success information:

```
Installing My Kit...

Checking prerequisites...
  ✓ git found
  ✓ gh CLI found
  ✓ In git repository

Downloading files...
  ✓ Commands (17 files)
  ✓ Scripts (4 files)
  ✓ Templates (3 files)

Creating configuration...
  ✓ .mykit/config.json created

Installation complete!

Next steps:
  1. Start Claude Code in this directory
  2. Run /mykit.init to initialize
  3. Run /mykit.help for available commands
```

### Standard Error (stderr)

Error messages only:

```
✗ Error: git is not installed

Please install git:
  - macOS: brew install git
  - Ubuntu: sudo apt install git
  - Windows: https://git-scm.com/downloads
```

## Exit Codes

| Code | Constant | Description |
|------|----------|-------------|
| 0 | `EXIT_SUCCESS` | Installation completed successfully |
| 1 | `EXIT_ERROR` | General/unknown error |
| 2 | `EXIT_PREREQ` | Prerequisite check failed |
| 3 | `EXIT_NETWORK` | Download or network error |
| 4 | `EXIT_FILESYSTEM` | File system operation failed |

## Signal Handling

| Signal | Behavior |
|--------|----------|
| SIGINT (Ctrl+C) | Cleanup temp files, restore backup, exit 1 |
| SIGTERM | Cleanup temp files, restore backup, exit 1 |
| EXIT | Cleanup temp files (always) |

## File System Contract

### Files Created

| Path | Condition | Content |
|------|-----------|---------|
| `.claude/commands/mykit.*.md` | Always | Slash command definitions |
| `.mykit/scripts/*.sh` | Always | Shell utilities |
| `.mykit/templates/lite/*` | Always | Lite workflow templates |
| `.mykit/config.json` | If not exists | Default configuration |

### Files Never Modified

| Path | Reason |
|------|--------|
| `.mykit/config.json` (existing) | User customizations preserved |
| `.mykit/state.json` | Runtime state preserved |
| Unrecognized files in target dirs | User additions preserved |

### Directories Created

| Path | Mode |
|------|------|
| `.claude/commands/` | 755 |
| `.mykit/` | 755 |
| `.mykit/scripts/` | 755 |
| `.mykit/templates/` | 755 |
| `.mykit/templates/lite/` | 755 |

## Idempotency

The installer is idempotent:

- Running multiple times produces the same result
- Existing My Kit files are overwritten with latest versions
- User-added files are preserved
- Configuration is never overwritten if it exists

## Atomicity Guarantee

Installation is atomic:

- All files download to temp directory first
- Files move to final locations only after all downloads succeed
- On any failure, temp directory is cleaned up
- On failure after partial move, backup is restored
