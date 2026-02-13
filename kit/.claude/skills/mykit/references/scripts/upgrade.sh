#!/usr/bin/env bash
# My Kit Upgrade Utilities
# Provides backup, restore, download, and installation functions

set -euo pipefail

# Load version utilities
if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
fi
# shellcheck source=version.sh
source "$SCRIPT_DIR/version.sh"

# Guard against multiple sourcing
[[ -n "${_MYKIT_UPGRADE_SH_LOADED:-}" ]] && return 0
_MYKIT_UPGRADE_SH_LOADED=1

# Configuration
MYKIT_REPO="${MYKIT_REPO:-mayknxyz/my-kit-v2}"
BACKUP_DIR="${BACKUP_DIR:-.mykit/backup/.last-backup}"
MANIFESTS_DIR="${MANIFESTS_DIR:-.mykit/.manifests}"
LOCK_FILE="${LOCK_FILE:-${XDG_RUNTIME_DIR:-/var/tmp}/mykit-upgrade.lock}"
LOCK_TIMEOUT="${LOCK_TIMEOUT:-10}"

# Managed .mykit/ subdirectories — cleared before install to remove stale files.
# Add new directories here as they are introduced.
MANAGED_MYKIT_DIRS=(
    scripts
    templates
    modes
    upstream
    subagents
    skills
    hooks
)

# Exit codes
EXIT_SUCCESS="${EXIT_SUCCESS:-0}"
EXIT_GENERAL_ERROR="${EXIT_GENERAL_ERROR:-1}"
EXIT_PRECONDITION_FAILURE="${EXIT_PRECONDITION_FAILURE:-2}"
EXIT_NETWORK_ERROR="${EXIT_NETWORK_ERROR:-3}"
EXIT_FILESYSTEM_ERROR="${EXIT_FILESYSTEM_ERROR:-4}"

# Lock file descriptor
exec 9>/dev/null

# Acquire exclusive lock for upgrade operations
acquire_lock() {
    local lock_dir
    lock_dir=$(dirname "$LOCK_FILE")
    mkdir -p "$lock_dir" 2>/dev/null || true

    exec 9>"$LOCK_FILE"

    # If flock is not available, skip locking with a warning
    if ! command -v flock >/dev/null 2>&1; then
        echo "Warning: flock not available; skipping upgrade lock" >&2
        echo "$$" > "$LOCK_FILE"
        return 0
    fi

    if ! flock -x -w "$LOCK_TIMEOUT" 9 2>/dev/null; then
        local lock_pid
        lock_pid=$(cat "$LOCK_FILE" 2>/dev/null || echo "unknown")
        echo "Error: Another upgrade is in progress (PID: $lock_pid)" >&2
        echo "" >&2
        echo "Wait for the current upgrade to complete, or remove the lock file:" >&2
        echo "  rm $LOCK_FILE" >&2
        return "$EXIT_GENERAL_ERROR"
    fi

    echo "$$" > "$LOCK_FILE"
    return 0
}

# Release lock and clean up
cleanup_lock() {
    trap - INT TERM EXIT
    exec 9>&- 2>/dev/null || true
    rm -f "$LOCK_FILE" 2>/dev/null || true
}

# Validate required dependencies
validate_dependencies() {
    local missing=()

    if ! command -v git &>/dev/null; then
        missing+=("git")
    fi

    if ! command -v gh &>/dev/null; then
        missing+=("gh (GitHub CLI)")
    fi

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "Error: Missing required dependencies:" >&2
        for dep in "${missing[@]}"; do
            echo "  - $dep" >&2
        done
        return "$EXIT_PRECONDITION_FAILURE"
    fi

    # Check gh authentication
    if ! gh auth status &>/dev/null; then
        echo "Error: GitHub CLI not authenticated" >&2
        echo "Run: gh auth login" >&2
        return "$EXIT_PRECONDITION_FAILURE"
    fi

    # Check write permissions
    local install_dir="${MYKIT_INSTALL_DIR:-.}"
    if [[ ! -w "$install_dir/.mykit" ]]; then
        echo "Error: No write permission to installation directory" >&2
        return "$EXIT_FILESYSTEM_ERROR"
    fi

    return 0
}

# Create backup of current installation
create_backup() {
    local install_dir="${MYKIT_INSTALL_DIR:-.}"
    local backup_path="$install_dir/$BACKUP_DIR"

    # Remove previous backup
    rm -rf "$backup_path"
    mkdir -p "$backup_path"

    # Backup commands
    if [[ -d "$install_dir/.claude/commands" ]]; then
        cp -r "$install_dir/.claude/commands" "$backup_path/commands/"
    fi

    # Backup managed .mykit/ subdirectories
    for dir in "${MANAGED_MYKIT_DIRS[@]}"; do
        if [[ -d "$install_dir/.mykit/$dir" ]]; then
            cp -r "$install_dir/.mykit/$dir" "$backup_path/$dir/"
        fi
    done

    # Record backup metadata
    date -u +%Y-%m-%dT%H:%M:%SZ > "$backup_path/.backup-time"
    get_current_version > "$backup_path/.backup-version"

    return 0
}

# Restore from backup
restore_backup() {
    local install_dir="${MYKIT_INSTALL_DIR:-.}"
    local backup_path="$install_dir/$BACKUP_DIR"

    if [[ ! -d "$backup_path" ]]; then
        echo "Error: No backup found at $backup_path" >&2
        return "$EXIT_FILESYSTEM_ERROR"
    fi

    # Restore commands
    if [[ -d "$backup_path/commands" ]]; then
        rm -rf "$install_dir/.claude/commands"
        cp -r "$backup_path/commands" "$install_dir/.claude/commands"
    fi

    # Restore managed .mykit/ subdirectories
    for dir in "${MANAGED_MYKIT_DIRS[@]}"; do
        if [[ -d "$backup_path/$dir" ]]; then
            rm -rf "$install_dir/.mykit/$dir"
            cp -r "$backup_path/$dir" "$install_dir/.mykit/$dir"
        fi
    done

    local backup_version
    backup_version=$(cat "$backup_path/.backup-version" 2>/dev/null || echo "unknown")
    echo "Restored from backup ($backup_version)"

    return 0
}

# Download files from GitHub release
download_files() {
    local version="$1"
    local temp_dir="$2"

    # Download release tarball via gh CLI (works with private repos)
    if ! gh release download "$version" \
        --repo "$MYKIT_REPO" \
        --archive tar.gz \
        --dir "$temp_dir" 2>/dev/null; then
        echo "Error: Failed to download release $version" >&2
        return "$EXIT_NETWORK_ERROR"
    fi

    # Find the downloaded tarball
    local tarball
    tarball=$(find "$temp_dir" -maxdepth 1 -name "*.tar.gz" | head -1)

    if [[ -z "$tarball" || ! -f "$tarball" ]]; then
        echo "Error: Downloaded tarball not found" >&2
        return "$EXIT_FILESYSTEM_ERROR"
    fi

    # Extract tarball
    if ! tar -xzf "$tarball" -C "$temp_dir" 2>/dev/null; then
        echo "Error: Failed to extract release archive" >&2
        return "$EXIT_FILESYSTEM_ERROR"
    fi

    # Find extracted directory
    local extracted_dir
    extracted_dir=$(find "$temp_dir" -maxdepth 1 -type d -name "my-kit-*" | head -1)

    if [[ -z "$extracted_dir" || ! -d "$extracted_dir" ]]; then
        echo "Error: Could not find extracted release files" >&2
        return "$EXIT_FILESYSTEM_ERROR"
    fi

    echo "$extracted_dir"
    return 0
}

# Verify downloaded files against manifest (if available)
verify_checksums() {
    local source_dir="$1"
    local manifest="$source_dir/.mykit/.manifests/manifest-sha256.txt"

    # If no manifest exists in release, skip verification
    if [[ ! -f "$manifest" ]]; then
        return 0
    fi

    while IFS='  ' read -r expected_hash filepath; do
        [[ "$expected_hash" =~ ^# ]] && continue
        [[ -z "$expected_hash" ]] && continue

        local full_path="$source_dir/$filepath"
        [[ ! -f "$full_path" ]] && continue

        local actual_hash
        actual_hash=$(calculate_checksum "$full_path") || continue

        if [[ "$actual_hash" != "$expected_hash" ]]; then
            echo "Error: Checksum mismatch for $filepath" >&2
            return "$EXIT_FILESYSTEM_ERROR"
        fi
    done < "$manifest"

    return 0
}

# Install files from downloaded release
install_files() {
    local source_dir="$1"
    local install_dir="${MYKIT_INSTALL_DIR:-.}"

    # Install commands (preserve config.json!)
    if [[ -d "$source_dir/.claude/commands" ]]; then
        # Remove old mykit commands before installing fresh copies
        find "$install_dir/.claude/commands" -name "mykit.*.md" -delete 2>/dev/null || true
        cp -r "$source_dir/.claude/commands"/mykit.*.md "$install_dir/.claude/commands/" 2>/dev/null || true
    fi

    # Install managed .mykit/ subdirectories (clear before copy to remove stale files)
    for dir in "${MANAGED_MYKIT_DIRS[@]}"; do
        if [[ -d "$source_dir/.mykit/$dir" ]]; then
            rm -rf "$install_dir/.mykit/$dir"
            mkdir -p "$install_dir/.mykit/$dir"
            cp -r "$source_dir/.mykit/$dir"/* "$install_dir/.mykit/$dir/"
        fi
    done

    # Note: config.json is intentionally NOT touched
    return 0
}

# Show preview of available upgrade
show_preview() {
    local current latest

    current=$(get_current_version)

    if ! latest=$(get_latest_version); then
        echo "Error: Could not connect to GitHub" >&2
        echo "" >&2
        echo "Please check:" >&2
        echo "- Network connectivity" >&2
        echo "- GitHub status (https://www.githubstatus.com/)" >&2
        echo "- gh CLI authentication (gh auth status)" >&2
        return "$EXIT_NETWORK_ERROR"
    fi

    echo "My Kit Upgrade"
    echo ""
    echo "Current version: $current"
    echo "Latest version:  $latest"

    if ! is_upgrade_available "$current" "$latest"; then
        echo ""
        echo "Already running the latest version!"
        return 0
    fi

    echo ""
    echo "Changes in $latest:"

    local changelog
    if changelog=$(get_changelog "$latest"); then
        # Show first few lines of changelog
        echo "$changelog" | head -10
        local lines
        lines=$(echo "$changelog" | wc -l)
        if [[ $lines -gt 10 ]]; then
            echo "... ($(( lines - 10 )) more lines)"
        fi
    else
        echo "(Changelog not available)"
    fi

    echo ""
    echo "To upgrade, run: /mykit.upgrade --run"

    return 0
}

# Run the full upgrade workflow
run_upgrade() {
    local target_version="${1:-}"
    local install_dir="${MYKIT_INSTALL_DIR:-.}"
    local current temp_dir source_dir

    # Refuse to upgrade when inside the my-kit source repo,
    # but still update VERSION to the latest release tag
    if is_mykit_source_repo 2>/dev/null; then
        local latest
        if latest=$(get_latest_version) && [[ -n "$latest" ]]; then
            echo "$latest" > "${install_dir}/.mykit/VERSION"
            echo "Skipping upgrade (my-kit source repo) — VERSION updated to $latest"
        else
            echo "Skipping upgrade: running inside the my-kit source repo"
        fi
        return 0
    fi

    current=$(get_current_version)

    # Determine target version
    if [[ -z "$target_version" ]]; then
        if ! target_version=$(get_latest_version); then
            echo "Error: Could not connect to GitHub" >&2
            echo "" >&2
            echo "Please check:" >&2
            echo "- Network connectivity" >&2
            echo "- GitHub status (https://www.githubstatus.com/)" >&2
            echo "- gh CLI authentication (gh auth status)" >&2
            return "$EXIT_NETWORK_ERROR"
        fi
    fi

    # Check if version exists
    if ! version_exists "$target_version"; then
        echo "Error: Version $target_version does not exist" >&2
        echo "" >&2
        echo "Available versions:" >&2
        list_all_versions | while read -r line; do
            echo "  $line" >&2
        done
        return "$EXIT_GENERAL_ERROR"
    fi

    # Check if already at target version
    if [[ "$current" == "$target_version" ]]; then
        echo "Already running $target_version"
        return 0
    fi

    # Check for downgrade
    if is_downgrade "$current" "$target_version"; then
        echo "Warning: Downgrading from $current to $target_version" >&2
        echo "" >&2
        echo "Downgrading may cause:" >&2
        echo "- Loss of newer command features" >&2
        echo "- Configuration compatibility issues" >&2
        echo "" >&2
    fi

    echo "Upgrading My Kit from $current to $target_version..."
    echo ""

    # Trap for cleanup on error
    trap 'cleanup_on_error' ERR

    # Step 1: Validate dependencies
    echo -n "Validating dependencies... "
    validate_dependencies
    echo "done"

    # Step 2: Acquire lock
    echo -n "Acquiring lock... "
    acquire_lock
    trap 'cleanup_lock; cleanup_on_error' ERR INT TERM
    echo "done"

    # Step 3: Check for modified files
    local manifest="$install_dir/$MANIFESTS_DIR/manifest-sha256.txt"
    if [[ -f "$manifest" ]]; then
        local modified
        modified=$(detect_modified_files "$manifest" "$install_dir")
        if [[ -n "$modified" ]]; then
            echo ""
            echo "Warning: Locally modified files detected:" >&2
            echo "$modified" | while read -r file; do
                echo "  $file" >&2
            done
            echo ""
            echo "These files will be backed up before overwriting."
        fi
    fi

    # Step 4: Create backup
    echo -n "Creating backup... "
    create_backup
    echo "done"

    # Step 5: Download files
    echo -n "Downloading files... "
    temp_dir=$(mktemp -d)
    trap 'rm -rf "$temp_dir"; cleanup_lock; cleanup_on_error' ERR INT TERM

    source_dir=$(download_files "$target_version" "$temp_dir")
    echo "done"

    # Step 6: Verify checksums
    echo -n "Verifying checksums... "
    verify_checksums "$source_dir"
    echo "done"

    # Step 7: Install files
    echo -n "Installing files... "
    install_files "$source_dir"
    echo "done"

    # Step 8: Ensure .mykit is gitignored
    local gitignore="$install_dir/.gitignore"
    if [[ -f "$gitignore" ]]; then
        if ! grep -qxF ".mykit/" "$gitignore"; then
            echo "" >> "$gitignore"
            echo ".mykit/" >> "$gitignore"
        fi
    else
        echo ".mykit/" > "$gitignore"
    fi

    # Step 9: Write version files
    echo -n "Writing version files... "
    echo "$target_version" > "$install_dir/.mykit/VERSION"
    # Preserve existing SPEC_KIT_VERSION (spec-kit version is baked in at release time)
    if [[ -f "$source_dir/.mykit/SPEC_KIT_VERSION" ]]; then
        cp "$source_dir/.mykit/SPEC_KIT_VERSION" "$install_dir/.mykit/SPEC_KIT_VERSION"
    fi
    echo "done"

    # Cleanup temp directory
    rm -rf "$temp_dir"

    # Release lock
    cleanup_lock

    echo ""
    echo "Upgrade complete! Now running $target_version"

    return 0
}

# Cleanup on error - restore backup if needed
cleanup_on_error() {
    echo "" >&2
    echo "Error during upgrade. Restoring from backup..." >&2

    if restore_backup; then
        echo "Backup restored successfully." >&2
    else
        echo "Warning: Could not restore backup." >&2
    fi

    cleanup_lock

    exit "$EXIT_GENERAL_ERROR"
}

# Show all available versions
show_versions() {
    echo "Available versions:"
    echo ""

    if ! list_all_versions | format_version_list; then
        echo "Error: Could not fetch version list" >&2
        return "$EXIT_NETWORK_ERROR"
    fi

    echo ""
    echo "Use --version to upgrade to a specific version."
}
