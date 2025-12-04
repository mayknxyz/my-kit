# Research: Curl-Based Installer

**Feature**: 001-curl-installer
**Date**: 2025-12-04

## Research Topics

### 1. Atomic Installation Pattern in Bash

**Decision**: Use temporary directory for staging, then move files atomically on success.

**Rationale**:
- Download all files to a temp directory first
- Only copy to final locations after all downloads succeed
- If any step fails, temp directory is cleaned up automatically
- Prevents partial installations that could break existing setups

**Alternatives considered**:
- Direct download to target directories (rejected: no atomicity)
- Backup-and-restore pattern (rejected: more complex, slower)

**Implementation approach**:
```bash
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# Download to temp
# ... downloads ...

# On success, move to final locations
mv "$TEMP_DIR/commands/"* ".claude/commands/"
```

### 2. Signal Trapping for Cleanup

**Decision**: Trap EXIT, INT, TERM signals to ensure cleanup runs regardless of how script ends.

**Rationale**:
- EXIT trap catches normal exit, errors, and most signals
- INT trap catches Ctrl+C specifically
- TERM trap catches kill signals
- Cleanup function removes temp files and restores original state if needed

**Implementation approach**:
```bash
cleanup() {
  rm -rf "$TEMP_DIR" 2>/dev/null
  # Restore backed up files if installation incomplete
  if [[ -d "$BACKUP_DIR" && "$INSTALL_COMPLETE" != "true" ]]; then
    restore_backup
  fi
}
trap cleanup EXIT INT TERM
```

### 3. Prerequisite Detection

**Decision**: Check for commands using `command -v` (POSIX-compliant).

**Rationale**:
- `command -v` is POSIX-standard and works across bash/zsh/sh
- Returns success if command exists, failure if not
- More reliable than `which` (not POSIX, behaves differently across systems)

**Implementation approach**:
```bash
check_prereq() {
  if ! command -v "$1" &>/dev/null; then
    error "Required: $1 is not installed"
    return 1
  fi
}
```

### 4. Git Repository Detection

**Decision**: Use `git rev-parse --is-inside-work-tree` to verify git repo.

**Rationale**:
- Standard git command for this purpose
- Returns "true" and exit 0 if in a git repo
- Returns error if not in a git repo
- Works from any subdirectory of a repo

**Implementation approach**:
```bash
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  error "Not a git repository. Run 'git init' first."
  exit 2
fi
```

### 5. File Download from GitHub Raw

**Decision**: Use curl with `-fsSL` flags to download from raw.githubusercontent.com.

**Rationale**:
- `-f`: Fail silently on HTTP errors (returns exit code)
- `-s`: Silent mode (no progress meter)
- `-S`: Show error messages when -s is used
- `-L`: Follow redirects
- GitHub raw URLs are stable for public repositories

**URL pattern**:
```
https://raw.githubusercontent.com/{owner}/{repo}/{branch}/{path}
```

**Implementation approach**:
```bash
REPO_URL="https://raw.githubusercontent.com/mayknxyz/my-kit/main"

download_file() {
  local remote_path="$1"
  local local_path="$2"
  curl -fsSL "$REPO_URL/$remote_path" -o "$local_path"
}
```

### 6. Progress Feedback Without Interactivity

**Decision**: Use simple echo statements with emoji/symbols for visual distinction.

**Rationale**:
- Must work when piped from curl (no tty)
- Cannot use interactive progress bars
- Simple status messages are clear and reliable
- Emoji provide visual cues without requiring special formatting

**Implementation approach**:
```bash
info()    { echo "ℹ️  $*"; }
success() { echo "✓ $*"; }
error()   { echo "✗ $*" >&2; }
```

### 7. Preserving User Files During Update

**Decision**: Maintain a manifest of known My Kit files; only overwrite those.

**Rationale**:
- Users may add custom commands or scripts
- Only files from the manifest should be updated
- Unknown files in target directories are preserved
- Manifest can be embedded in installer or fetched from repo

**Implementation approach**:
```bash
MYKIT_FILES=(
  ".claude/commands/mykit.init.md"
  ".claude/commands/mykit.status.md"
  # ... etc
)

for file in "${MYKIT_FILES[@]}"; do
  download_file "$file" "$file"
done
```

### 8. Default Configuration Creation

**Decision**: Create `.mykit/config.json` only if it doesn't exist.

**Rationale**:
- Preserves user customizations on reinstall/upgrade
- Default config provides sensible starting values
- JSON format is human-readable and machine-parseable

**Default config structure**:
```json
{
  "github": {
    "default_base_branch": "main",
    "auto_assign_pr": true
  },
  "validation": {
    "auto_fix": true
  }
}
```

## Summary

All technical decisions are resolved. No NEEDS CLARIFICATION items remain.

| Topic | Decision |
|-------|----------|
| Atomic installation | Temp directory staging with move on success |
| Signal trapping | Trap EXIT, INT, TERM with cleanup function |
| Prerequisite check | `command -v` (POSIX-compliant) |
| Git repo check | `git rev-parse --is-inside-work-tree` |
| File download | curl `-fsSL` from raw.githubusercontent.com |
| Progress feedback | Simple echo with emoji symbols |
| User file preservation | Known file manifest; only overwrite listed files |
| Config creation | Create default only if not exists |
