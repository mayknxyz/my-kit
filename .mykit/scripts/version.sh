#!/usr/bin/env bash
# My Kit Version Utilities
# Provides version checking and comparison functions

set -euo pipefail

# Guard against multiple sourcing
[[ -n "${_MYKIT_VERSION_SH_LOADED:-}" ]] && return 0
_MYKIT_VERSION_SH_LOADED=1

MYKIT_REPO="${MYKIT_REPO:-mayknxyz/my-kit}"

# Get currently installed version from git tag
get_current_version() {
    local version
    version=$(git describe --tags --abbrev=0 2>/dev/null) || version="v0.1.0"
    echo "$version"
}

# Get latest version from GitHub releases
get_latest_version() {
    gh release list --repo "$MYKIT_REPO" \
        --json tagName --limit 1 \
        --exclude-drafts --exclude-pre-releases \
        --jq '.[0].tagName' 2>/dev/null || {
        echo ""
        return 1
    }
}

# List all available versions with dates
list_all_versions() {
    gh release list --repo "$MYKIT_REPO" \
        --json tagName,publishedAt \
        --exclude-drafts --exclude-pre-releases \
        --jq '.[] | "\(.tagName) \(.publishedAt | split("T")[0])"' 2>/dev/null || {
        return 1
    }
}

# Format version list for display
format_version_list() {
    local current latest
    current=$(get_current_version)
    latest=$(get_latest_version) || latest=""

    while read -r line; do
        local version date
        version=$(echo "$line" | awk '{print $1}')
        date=$(echo "$line" | awk '{print $2}')

        local prefix=" "
        local suffix=""

        if [[ "$version" == "$current" ]]; then
            prefix="*"
        fi

        if [[ -n "$latest" && "$version" == "$latest" ]]; then
            suffix=" <- latest"
        fi

        printf "%s %s  (%s)%s\n" "$prefix" "$version" "$date" "$suffix"
    done
}

# Get changelog for a specific version
get_changelog() {
    local version="${1:-}"
    if [[ -z "$version" ]]; then
        version=$(get_latest_version) || return 1
    fi

    gh release view "$version" --repo "$MYKIT_REPO" \
        --json body --jq '.body' 2>/dev/null || {
        return 1
    }
}

# Check if version exists on remote
version_exists() {
    local version="$1"
    gh release view "$version" --repo "$MYKIT_REPO" \
        --json tagName --jq '.tagName' &>/dev/null
}

# Compare two versions - returns 0 if v1 < v2
is_upgrade_available() {
    local current="$1" latest="$2"

    # Strip 'v' prefix
    current="${current#v}"
    latest="${latest#v}"

    # Same version = no upgrade
    [[ "$current" == "$latest" ]] && return 1

    # Use sort -V if available
    if sort --version-sort </dev/null >/dev/null 2>&1; then
        local sorted
        sorted=$(printf '%s\n%s' "$current" "$latest" | sort -V | head -1)
        [[ "$sorted" == "$current" ]]
    else
        # Fallback: pure bash comparison
        version_compare "$current" "$latest" "lt"
    fi
}

# Check if target is older than current (downgrade)
is_downgrade() {
    local current="$1" target="$2"

    current="${current#v}"
    target="${target#v}"

    [[ "$current" == "$target" ]] && return 1

    if sort --version-sort </dev/null >/dev/null 2>&1; then
        local sorted
        sorted=$(printf '%s\n%s' "$current" "$target" | sort -V | head -1)
        [[ "$sorted" == "$target" ]]
    else
        version_compare "$target" "$current" "lt"
    fi
}

# Pure Bash version comparison fallback
# Returns 0 if comparison is true
version_compare() {
    local v1="$1" v2="$2" op="$3"
    local -a v1_parts v2_parts

    IFS=. read -ra v1_parts <<< "$v1"
    IFS=. read -ra v2_parts <<< "$v2"

    for i in 0 1 2; do
        local p1=${v1_parts[$i]:-0}
        local p2=${v2_parts[$i]:-0}

        if (( p1 < p2 )); then
            [[ "$op" == "lt" ]] && return 0
            return 1
        elif (( p1 > p2 )); then
            [[ "$op" == "gt" ]] && return 0
            return 1
        fi
    done

    [[ "$op" == "eq" ]] && return 0
    return 1
}

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

# Detect modified files by comparing against manifest
detect_modified_files() {
    local manifest="$1"
    local base_dir="$2"
    local -a modified=()

    [[ ! -f "$manifest" ]] && return 0

    while IFS='  ' read -r expected_hash filepath; do
        # Skip comments and empty lines
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

# Generate manifest for current installation
generate_manifest() {
    local source_dir="$1"
    local output_file="$2"
    local version="${3:-unknown}"

    {
        echo "# manifest-sha256.txt"
        echo "# Version: $version"
        echo "# Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
        echo ""
    } > "$output_file"

    find "$source_dir" -type f ! -name '.gitkeep' | sort | while read -r file; do
        local rel_path="${file#$source_dir/}"
        local checksum
        checksum=$(calculate_checksum "$file") || continue
        echo "$checksum  $rel_path"
    done >> "$output_file"
}
