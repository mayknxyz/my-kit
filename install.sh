#!/usr/bin/env bash
#
# My Kit Installer
# Install My Kit via: curl -fsSL https://raw.githubusercontent.com/mayknxyz/my-kit/main/install.sh | bash
#
# This script downloads and installs My Kit slash commands and utilities
# into the current git repository.
#

set -euo pipefail

# =============================================================================
# Constants
# =============================================================================

readonly SCRIPT_VERSION="1.0.0"

# Exit codes (per CLI interface contract)
readonly EXIT_SUCCESS=0
readonly EXIT_ERROR=1
readonly EXIT_PREREQ=2
readonly EXIT_NETWORK=3
readonly EXIT_FILESYSTEM=4

# Repository configuration (can be overridden via environment)
readonly REPO="${MYKIT_REPO:-mayknxyz/my-kit}"
readonly BRANCH="${MYKIT_BRANCH:-main}"
readonly REPO_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}"

# =============================================================================
# File Manifests
# =============================================================================

# Commands to install in .claude/commands/
readonly COMMAND_FILES=(
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
readonly SCRIPT_FILES=(
    "utils.sh"
    "github-api.sh"
    "git-ops.sh"
    "validation.sh"
)

# Templates to install in .mykit/templates/
readonly TEMPLATE_FILES=(
    "lite/spec.md"
    "lite/plan.md"
    "lite/tasks.md"
)

# =============================================================================
# State Variables
# =============================================================================

TEMP_DIR=""
BACKUP_DIR=""
INSTALL_COMPLETE="false"

# =============================================================================
# Output Functions (T023-T025)
# =============================================================================

# T023: Informational message
info() {
    echo "$*"
}

# T024: Success message with checkmark
success() {
    echo "  ✓ $*"
}

# T025: Error message to stderr
error() {
    echo "✗ $*" >&2
}

# =============================================================================
# Utility Functions (T004-T010)
# =============================================================================

# T004: Cleanup function for temp directory removal
cleanup() {
    if [[ -n "${TEMP_DIR}" && -d "${TEMP_DIR}" ]]; then
        rm -rf "${TEMP_DIR}" 2>/dev/null || true
    fi

    # Restore backup if installation was incomplete
    if [[ "${INSTALL_COMPLETE}" != "true" && -n "${BACKUP_DIR}" && -d "${BACKUP_DIR}" ]]; then
        restore_backup
    fi
}

# T005: Signal trap setup
setup_traps() {
    trap cleanup EXIT INT TERM
}

# T006: Create temporary directory
create_temp_dir() {
    TEMP_DIR=$(mktemp -d 2>/dev/null || mktemp -d -t 'mykit')
    BACKUP_DIR="${TEMP_DIR}/backup"
    mkdir -p "${TEMP_DIR}/commands"
    mkdir -p "${TEMP_DIR}/scripts"
    mkdir -p "${TEMP_DIR}/templates/lite"
    mkdir -p "${BACKUP_DIR}"
}

# T007: Download a single file from GitHub
download_file() {
    local remote_path="$1"
    local local_path="$2"

    if ! curl -fsSL "${REPO_URL}/${remote_path}" -o "${local_path}" 2>/dev/null; then
        return 1
    fi

    # Verify file is not empty
    if [[ ! -s "${local_path}" ]]; then
        return 1
    fi

    return 0
}

# T008: Backup existing My Kit files before overwrite
backup_existing() {
    local file="$1"
    local backup_path="${BACKUP_DIR}/${file}"

    if [[ -f "${file}" ]]; then
        mkdir -p "$(dirname "${backup_path}")"
        cp "${file}" "${backup_path}"
    fi
}

# T009: Restore backup on failure
restore_backup() {
    if [[ ! -d "${BACKUP_DIR}" ]]; then
        return 0
    fi

    # Restore command files
    if [[ -d "${BACKUP_DIR}/.claude/commands" ]]; then
        for file in "${BACKUP_DIR}/.claude/commands"/*; do
            if [[ -f "${file}" ]]; then
                cp "${file}" ".claude/commands/"
            fi
        done
    fi

    # Restore script files
    if [[ -d "${BACKUP_DIR}/.mykit/scripts" ]]; then
        for file in "${BACKUP_DIR}/.mykit/scripts"/*; do
            if [[ -f "${file}" ]]; then
                cp "${file}" ".mykit/scripts/"
            fi
        done
    fi

    # Restore template files
    if [[ -d "${BACKUP_DIR}/.mykit/templates" ]]; then
        cp -r "${BACKUP_DIR}/.mykit/templates"/* ".mykit/templates/" 2>/dev/null || true
    fi
}

# T010: Atomically move files from temp to final locations
atomic_move() {
    local src_dir="$1"
    local dest_dir="$2"

    # Ensure destination directory exists
    mkdir -p "${dest_dir}"

    # Move files (overwrite existing)
    for file in "${src_dir}"/*; do
        if [[ -f "${file}" ]]; then
            local filename
            filename=$(basename "${file}")
            # Backup existing file before overwrite
            backup_existing "${dest_dir}/${filename}"
            cp "${file}" "${dest_dir}/${filename}"
        elif [[ -d "${file}" ]]; then
            local dirname
            dirname=$(basename "${file}")
            cp -r "${file}" "${dest_dir}/${dirname}"
        fi
    done
}

# =============================================================================
# Prerequisite Validation Functions (T017-T022)
# =============================================================================

# T017: Check if a command exists
check_command() {
    local cmd="$1"
    command -v "${cmd}" &>/dev/null
}

# T018: Check if current directory is a git repository
check_git_repo() {
    git rev-parse --is-inside-work-tree &>/dev/null
}

# T019: Check write permission in current directory
check_write_permission() {
    local test_file=".mykit/.write_test_$$"
    mkdir -p ".mykit" 2>/dev/null || return 1
    if touch "${test_file}" 2>/dev/null; then
        rm -f "${test_file}"
        return 0
    fi
    return 1
}

# T020: Print prerequisite error with platform-specific guidance
print_prereq_error() {
    local prereq="$1"

    case "${prereq}" in
        git)
            echo "Please install git:" >&2
            echo "  - macOS: brew install git" >&2
            echo "  - Ubuntu/Debian: sudo apt install git" >&2
            echo "  - Windows: https://git-scm.com/downloads" >&2
            ;;
        gh)
            echo "Please install GitHub CLI:" >&2
            echo "  - macOS: brew install gh" >&2
            echo "  - Ubuntu/Debian: sudo apt install gh" >&2
            echo "  - Windows: winget install GitHub.cli" >&2
            echo "" >&2
            echo "Then authenticate: gh auth login" >&2
            ;;
        git-repo)
            echo "This directory is not a git repository." >&2
            echo "" >&2
            echo "Initialize a git repository first:" >&2
            echo "  git init" >&2
            ;;
        write-permission)
            echo "Cannot write to this directory." >&2
            echo "" >&2
            echo "Ensure you have write access:" >&2
            echo "  touch .test && rm .test  # Should succeed without error" >&2
            ;;
    esac
}

# T021: Check all prerequisites and collect errors (T026: with progress messages)
check_all_prerequisites() {
    local errors=0

    info ""
    info "Checking prerequisites..."

    # Check git
    if check_command git; then
        success "git found"
    else
        error "Error: git is not installed"
        echo "" >&2
        print_prereq_error "git"
        echo "" >&2
        errors=$((errors + 1))
    fi

    # Check gh CLI
    if check_command gh; then
        success "gh CLI found"
    else
        error "Error: gh CLI is not installed"
        echo "" >&2
        print_prereq_error "gh"
        echo "" >&2
        errors=$((errors + 1))
    fi

    # Check git repository
    if check_git_repo; then
        success "In git repository"
    else
        error "Error: Not a git repository"
        echo "" >&2
        print_prereq_error "git-repo"
        echo "" >&2
        errors=$((errors + 1))
    fi

    # Check write permission (silent success)
    if ! check_write_permission; then
        error "Error: Permission denied"
        echo "" >&2
        print_prereq_error "write-permission"
        echo "" >&2
        errors=$((errors + 1))
    fi

    return ${errors}
}

# =============================================================================
# Installation Functions (T011-T016)
# =============================================================================

# T011: Download all files to temp directory (T027: with progress messages)
download_all_files() {
    local failed=0
    local cmd_count=0
    local script_count=0
    local template_count=0

    info ""
    info "Downloading files..."

    # Download command files
    for file in "${COMMAND_FILES[@]}"; do
        if download_file ".claude/commands/${file}" "${TEMP_DIR}/commands/${file}"; then
            cmd_count=$((cmd_count + 1))
        else
            failed=$((failed + 1))
        fi
    done
    success "Commands (${cmd_count} files)"

    # Download script files
    for file in "${SCRIPT_FILES[@]}"; do
        if download_file ".mykit/scripts/${file}" "${TEMP_DIR}/scripts/${file}"; then
            script_count=$((script_count + 1))
        else
            failed=$((failed + 1))
        fi
    done
    success "Scripts (${script_count} files)"

    # Download template files
    for file in "${TEMPLATE_FILES[@]}"; do
        if download_file ".mykit/templates/${file}" "${TEMP_DIR}/templates/${file}"; then
            template_count=$((template_count + 1))
        else
            failed=$((failed + 1))
        fi
    done
    success "Templates (${template_count} files)"

    if [[ ${failed} -gt 0 ]]; then
        error "Failed to download ${failed} file(s)"
        return 1
    fi

    return 0
}

# T012: Create target directories
create_directories() {
    mkdir -p ".claude/commands"
    mkdir -p ".mykit/scripts"
    mkdir -p ".mykit/templates/lite"
}

# T013: Install files from temp to final locations
install_files() {
    # Install command files
    atomic_move "${TEMP_DIR}/commands" ".claude/commands"

    # Install script files
    atomic_move "${TEMP_DIR}/scripts" ".mykit/scripts"

    # Install template files (including subdirectories)
    atomic_move "${TEMP_DIR}/templates" ".mykit/templates"
}

# T014: Create default configuration if not exists (T028: with progress message)
create_default_config() {
    local config_file=".mykit/config.json"

    if [[ -f "${config_file}" ]]; then
        return 0
    fi

    cat > "${config_file}" << 'EOF'
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
EOF

    success ".mykit/config.json created"
}

# T015: Display post-installation next steps (T029: with component summary)
print_next_steps() {
    info ""
    info "Installation complete!"
    info ""
    info "Installed components:"
    info "  - Commands:   .claude/commands/mykit.*.md"
    info "  - Scripts:    .mykit/scripts/*.sh"
    info "  - Templates:  .mykit/templates/lite/"
    info "  - Config:     .mykit/config.json"
    info ""
    info "Next steps:"
    info "  1. Start Claude Code in this directory"
    info "  2. Run /mykit.init to initialize"
    info "  3. Run /mykit.help for available commands"
}

# T016: Main execution flow (T022: integrated prerequisite checks, T028: with progress)
main() {
    info "Installing My Kit..."

    setup_traps

    # T022: Check prerequisites before any file operations
    if ! check_all_prerequisites; then
        exit ${EXIT_PREREQ}
    fi

    create_temp_dir

    # Download all files to temp directory
    if ! download_all_files; then
        error "Download failed. Please check your internet connection."
        exit ${EXIT_NETWORK}
    fi

    # Create target directories
    if ! create_directories; then
        error "Failed to create directories."
        exit ${EXIT_FILESYSTEM}
    fi

    # T028: Installation phase progress
    info ""
    info "Installing files..."

    # Install files atomically
    if ! install_files; then
        error "Failed to install files."
        exit ${EXIT_FILESYSTEM}
    fi
    success "Files installed"

    # Create default config if needed
    info ""
    info "Creating configuration..."
    create_default_config

    # Mark installation as complete (prevents rollback on normal exit)
    INSTALL_COMPLETE="true"

    print_next_steps

    exit ${EXIT_SUCCESS}
}

# Run main
main "$@"
