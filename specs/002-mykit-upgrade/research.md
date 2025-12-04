# Research: Self-Upgrade Command

**Feature Branch**: `002-mykit-upgrade`
**Date**: 2025-12-04
**Purpose**: Resolve technical decisions before implementation

## Summary

This document captures research findings for implementing the `/mykit.upgrade` command. All unknowns from Technical Context have been resolved.

---

## 1. Version Detection from GitHub

### Decision

Use `gh release list --json` for the primary upgrade workflow.

### Rationale

- Purpose-built for release discovery
- Handles authentication and pagination automatically
- Aligns with existing project constraints (curl, git, gh CLI)
- `gh api` available as fallback for advanced queries

### Alternatives Considered

| Approach | Why Not Selected |
|----------|-----------------|
| Pure curl only | Requires token management, manual pagination |
| `gh api` only | More verbose, requires manual JSON parsing |
| git tags only | Doesn't capture release metadata (dates, changelog) |

### Implementation

```bash
# Get latest version
get_latest_version() {
    gh release list --repo mayknxyz/my-kit \
        --json tagName --limit 1 \
        --exclude-drafts --exclude-pre-releases \
        --jq '.[0].tagName' 2>/dev/null
}

# List all versions
list_all_versions() {
    gh release list --repo mayknxyz/my-kit \
        --json tagName,publishedAt \
        --jq '.[] | "\(.tagName) (\(.publishedAt | split("T")[0]))"'
}

# Get current installed version
get_current_version() {
    git describe --tags --abbrev=0 2>/dev/null || echo "v0.1.0"
}
```

---

## 2. Semver Version Comparison

### Decision

Use `sort -V` with pure Bash fallback.

### Rationale

- `sort -V` is available on most modern systems (GNU coreutils)
- Pure Bash fallback ensures portability
- Handles semver format (vX.Y.Z) correctly

### Implementation

```bash
# Compare versions - returns 0 if upgrade available
is_upgrade_available() {
    local current="$1" latest="$2"

    # Strip 'v' prefix
    current="${current#v}"
    latest="${latest#v}"

    # Use sort -V if available
    if sort --version-sort </dev/null >/dev/null 2>&1; then
        # If current sorts before latest, upgrade available
        [[ "$(printf '%s\n%s' "$current" "$latest" | sort -V | head -1)" == "$current" ]] && \
            [[ "$current" != "$latest" ]]
    else
        # Fallback: pure bash comparison
        version_compare "$current" "$latest" "lt"
    fi
}

# Pure Bash version comparison fallback
version_compare() {
    local v1="$1" v2="$2" op="$3"
    IFS=. read -ra v1_parts <<< "$v1"
    IFS=. read -ra v2_parts <<< "$v2"

    for i in 0 1 2; do
        local p1=${v1_parts[$i]:-0} p2=${v2_parts[$i]:-0}
        if (( p1 < p2 )); then
            [[ "$op" == "lt" ]] && return 0; return 1
        elif (( p1 > p2 )); then
            [[ "$op" == "gt" ]] && return 0; return 1
        fi
    done
    [[ "$op" == "eq" ]] && return 0; return 1
}
```

---

## 3. Lock File Implementation

### Decision

Use `flock` with timeout + PID file for diagnostics.

### Rationale

- `flock` is atomic and uses kernel-level file locking
- Automatic cleanup when process exits (no stale locks)
- Blocking support with configurable timeout
- Included in `util-linux` (standard on Linux)
- Works on macOS with fallback

### Location

```bash
LOCK_FILE="${XDG_RUNTIME_DIR:=/var/tmp}/mykit-upgrade.lock"
```

Fallback precedence:
1. `$XDG_RUNTIME_DIR` (if set)
2. `/var/tmp` (macOS compatible)
3. `$HOME/.mykit/locks/` (user directory fallback)

### Implementation

```bash
readonly LOCK_FILE="${XDG_RUNTIME_DIR:=/var/tmp}/mykit-upgrade.lock"
readonly LOCK_TIMEOUT=10

acquire_lock() {
    mkdir -p "$(dirname "$LOCK_FILE")"

    if ! flock -x -w "$LOCK_TIMEOUT" 9 2>/dev/null; then
        local lock_pid
        lock_pid=$(cat "$LOCK_FILE" 2>/dev/null || echo "unknown")
        echo "Error: Another upgrade in progress (PID: $lock_pid)" >&2
        return 1
    fi

    echo "$$" > "$LOCK_FILE"
    return 0
}

cleanup_lock() {
    trap - INT TERM EXIT
    exec 9>&- 2>/dev/null || true
    rm -f "$LOCK_FILE"
}

# Usage pattern
(
    flock -x -w "$LOCK_TIMEOUT" 9 || {
        echo "Upgrade already in progress" >&2
        exit 1
    }
    echo "$$" > "$LOCK_FILE"

    # Critical section - upgrade operations

) 9>"$LOCK_FILE"
```

---

## 4. Checksum Calculation for Modified File Detection

### Decision

Use SHA-256 with cross-platform wrapper function.

### Rationale

- SHA-256 is NIST recommended, secure, and performant
- Cross-platform support via fallback chain: `sha256sum` → `shasum -a 256` → `openssl sha256`
- Standard manifest format enables `sha256sum -c` verification on Linux

### Manifest Format

```text
# manifest-sha256.txt
# Version: v0.2.0
# Generated: 2025-12-04T10:30:00Z

9f86d081884c7d659ffd60bb51d1c3f9  .claude/commands/mykit.upgrade.md
a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6  .mykit/scripts/upgrade.sh
```

### Implementation

```bash
# Cross-platform checksum calculation
calculate_checksum() {
    local file="$1"

    if command -v sha256sum &>/dev/null; then
        sha256sum "$file" | awk '{print $1}'
    elif command -v shasum &>/dev/null; then
        shasum -a 256 "$file" | awk '{print $1}'
    elif command -v openssl &>/dev/null; then
        openssl sha256 "$file" | awk '{print $NF}'
    else
        echo "Error: No checksum command available" >&2
        return 1
    fi
}

# Detect modified files before upgrade
detect_modified_files() {
    local manifest="$1"
    local base_dir="$2"
    local modified=()

    while IFS='  ' read -r expected_hash filepath; do
        [[ "$expected_hash" =~ ^# ]] && continue
        [[ -z "$expected_hash" ]] && continue

        local full_path="${base_dir}/${filepath}"
        [[ ! -f "$full_path" ]] && continue

        local actual_hash
        actual_hash=$(calculate_checksum "$full_path") || continue

        if [[ "$actual_hash" != "$expected_hash" ]]; then
            modified+=("$filepath")
        fi
    done < "$manifest"

    printf '%s\n' "${modified[@]}"
}

# Generate manifest for a release
generate_manifest() {
    local source_dir="$1"
    local output_file="$2"

    {
        echo "# manifest-sha256.txt"
        echo "# Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
        echo ""
    } > "$output_file"

    find "$source_dir" -type f | sort | while read -r file; do
        local rel_path="${file#$source_dir/}"
        local checksum
        checksum=$(calculate_checksum "$file")
        echo "$checksum  $rel_path"
    done >> "$output_file"
}
```

### Storage Location

```text
.mykit/
└── .manifests/
    ├── manifest-v0.1.0-sha256.txt  # Previous versions (for detection)
    └── manifest-sha256.txt          # Current version
```

---

## 5. Backup Strategy

### Decision

Use timestamped backup directory with single retention.

### Rationale

- Aligns with clarification: "Keep only the most recent backup"
- Simple directory copy is fast and reliable
- Preserves file permissions and structure

### Implementation

```bash
readonly BACKUP_DIR=".mykit/backup/.last-backup"

create_backup() {
    # Remove previous backup
    rm -rf "$BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"

    # Copy current installation
    cp -r .claude/commands/ "$BACKUP_DIR/commands/"
    cp -r .mykit/scripts/ "$BACKUP_DIR/scripts/"
    cp -r .mykit/templates/ "$BACKUP_DIR/templates/"

    # Record backup metadata
    echo "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$BACKUP_DIR/.backup-time"
    get_current_version > "$BACKUP_DIR/.backup-version"
}

restore_backup() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        echo "Error: No backup found" >&2
        return 1
    fi

    cp -r "$BACKUP_DIR/commands/"* .claude/commands/
    cp -r "$BACKUP_DIR/scripts/"* .mykit/scripts/
    cp -r "$BACKUP_DIR/templates/"* .mykit/templates/

    echo "Restored from backup ($(cat "$BACKUP_DIR/.backup-version"))"
}
```

---

## Summary of Decisions

| Unknown | Decision | Key Rationale |
|---------|----------|---------------|
| Version source | `gh release list` | Purpose-built, handles auth/pagination |
| Version comparison | `sort -V` + Bash fallback | Portable, handles semver |
| Lock mechanism | `flock` with timeout | Atomic, auto-cleanup on exit |
| Checksum algorithm | SHA-256 | NIST recommended, cross-platform |
| Manifest format | Standard sha256sum format | Compatible with native tools |
| Backup retention | Single backup (overwrite) | Per clarification session |

---

## Dependencies Summary

All dependencies are already in the project's tech stack:

- **curl**: File downloads (existing in install.sh)
- **git**: Version detection via tags
- **gh**: GitHub API interaction
- **flock**: Lock file management (util-linux)
- **sha256sum/shasum/openssl**: Checksum calculation
