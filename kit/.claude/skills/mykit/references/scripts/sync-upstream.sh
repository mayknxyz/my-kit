#!/usr/bin/env bash
#
# sync-upstream.sh - Sync spec-kit upstream into my-kit
#
# DESCRIPTION:
#   Copies spec-kit files into $HOME/.claude/skills/mykit/references/upstream/ (verbatim) and generates
#   $HOME/.claude/skills/mykit-workflow/references/major/ files with path substitutions applied.
#   Also syncs $HOME/.claude/skills/mykit/references/templates/major/ from upstream templates.
#
# USAGE:
#   $HOME/.claude/skills/mykit/references/scripts/sync-upstream.sh [--source /path/to/spec-kit] [--remote] [--dry-run]
#
# OPTIONS:
#   --source PATH   Use a local spec-kit clone (recommended)
#   --remote        Clone from GitHub to a temp dir
#   --dry-run       Show what would change without applying
#
# If neither --source nor --remote is specified:
#   1. Checks ~/spec-kit first
#   2. Falls back to --remote
#
# EXIT CODES:
#   0  Success
#   1  Error
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# Directories
UPSTREAM_DIR="$HOME/.claude/skills/mykit/references/upstream"
MODES_FULL_DIR="$HOME/.claude/skills/mykit-workflow/references/major"
TEMPLATES_FULL_DIR="$HOME/.claude/skills/mykit/references/templates/major"

# Parse arguments
SOURCE_PATH=""
USE_REMOTE=false
DRY_RUN=false
TEMP_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --source)
      if [[ $# -lt 2 ]]; then
        echo "Error: --source requires a path argument" >&2
        exit 1
      fi
      SOURCE_PATH="$2"
      shift 2
      ;;
    --remote)
      USE_REMOTE=true
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --help|-h)
      echo "Usage: $0 [--source /path/to/spec-kit] [--remote] [--dry-run]"
      echo ""
      echo "Options:"
      echo "  --source PATH   Use a local spec-kit clone"
      echo "  --remote        Clone from GitHub to a temp dir"
      echo "  --dry-run       Show what would change without applying"
      exit 0
      ;;
    *)
      echo "Error: Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

# Cleanup function for temp directory
cleanup() {
  if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
    rm -rf "$TEMP_DIR"
  fi
}
trap cleanup EXIT

# Determine source
if [[ -z "$SOURCE_PATH" && "$USE_REMOTE" == false ]]; then
  # Auto-detect: try ~/spec-kit first
  if [[ -d "$HOME/spec-kit/templates/commands" ]]; then
    SOURCE_PATH="$HOME/spec-kit"
    echo "[sync] Using local spec-kit at $SOURCE_PATH"
  else
    USE_REMOTE=true
    echo "[sync] No local spec-kit found, falling back to --remote"
  fi
fi

if [[ "$USE_REMOTE" == true ]]; then
  TEMP_DIR=$(mktemp -d)
  echo "[sync] Cloning spec-kit from GitHub..."
  if ! git clone --depth 1 https://github.com/github/spec-kit.git "$TEMP_DIR" 2>/dev/null; then
    echo "Error: Failed to clone spec-kit from GitHub" >&2
    exit 1
  fi
  SOURCE_PATH="$TEMP_DIR"
fi

# Validate source
if [[ ! -d "$SOURCE_PATH/templates/commands" ]]; then
  echo "Error: Invalid spec-kit source: $SOURCE_PATH" >&2
  echo "Expected directory structure: templates/commands/, templates/*.md, scripts/bash/" >&2
  exit 1
fi

# Get spec-kit version info
SPECKIT_SHA=""
SPECKIT_DATE=""
SPECKIT_TAG=""

if [[ -d "$SOURCE_PATH/.git" ]]; then
  SPECKIT_SHA=$(git -C "$SOURCE_PATH" rev-parse HEAD 2>/dev/null || echo "unknown")
  SPECKIT_DATE=$(git -C "$SOURCE_PATH" log -1 --format=%Y-%m-%d 2>/dev/null || echo "unknown")
  SPECKIT_TAG=$(git -C "$SOURCE_PATH" describe --tags --always 2>/dev/null || echo "unknown")
fi

SYNC_DATE=$(date +%Y-%m-%d)

echo "[sync] spec-kit version: $SPECKIT_TAG (${SPECKIT_SHA:0:7})"
echo "[sync] sync date: $SYNC_DATE"

if [[ "$DRY_RUN" == true ]]; then
  echo ""
  echo "=== DRY RUN — no files will be modified ==="
  echo ""
fi

#######################################
# Apply path substitutions for Major mode
# Arguments:
#   $1 - Input file path
#   $2 - Output file path
#######################################
apply_path_substitutions() {
  local input="$1"
  local output="$2"

  sed \
    -e 's|\.specify/templates/|$HOME/.claude/skills/mykit/references/templates/major/|g' \
    -e 's|\.specify/|.mykit/|g' \
    -e 's|scripts/bash/|$HOME/.claude/skills/mykit/references/scripts/|g' \
    -e 's|templates/spec-template\.md|$HOME/.claude/skills/mykit/references/templates/major/spec-template.md|g' \
    -e 's|templates/plan-template\.md|$HOME/.claude/skills/mykit/references/templates/major/plan-template.md|g' \
    -e 's|templates/tasks-template\.md|$HOME/.claude/skills/mykit/references/templates/major/tasks-template.md|g' \
    -e 's|templates/checklist-template\.md|$HOME/.claude/skills/mykit/references/templates/major/checklist-template.md|g' \
    -e 's|templates/agent-file-template\.md|$HOME/.claude/skills/mykit/references/templates/major/agent-file-template.md|g' \
    -e 's|/speckit\.|/mykit.|g' \
    -e 's|speckit\.|mykit.|g' \
    -e 's|`/memory/|`.mykit/memory/|g' \
    -e 's| /memory/| .mykit/memory/|g' \
    "$input" > "$output"
}

#######################################
# Strip YAML frontmatter and User Input section for mode files
# Arguments:
#   $1 - Input file path
#   $2 - Output file path
#######################################
strip_frontmatter_and_input() {
  local input="$1"
  local output="$2"
  local in_frontmatter=false
  local frontmatter_ended=false
  local skip_input_section=false
  local content=""

  while IFS= read -r line || [[ -n "$line" ]]; do
    # Handle YAML frontmatter
    if [[ "$line" == "---" && "$frontmatter_ended" == false ]]; then
      if [[ "$in_frontmatter" == false ]]; then
        in_frontmatter=true
        continue
      else
        in_frontmatter=false
        frontmatter_ended=true
        continue
      fi
    fi

    if [[ "$in_frontmatter" == true ]]; then
      continue
    fi

    # Skip ## User Input section (including the code block after it)
    if [[ "$line" =~ ^##\ User\ Input ]]; then
      skip_input_section=true
      continue
    fi

    if [[ "$skip_input_section" == true ]]; then
      # Skip until we hit the next ## heading or end of the input block
      if [[ "$line" =~ ^## && ! "$line" =~ ^##\ User\ Input ]]; then
        skip_input_section=false
      else
        continue
      fi
    fi

    content+="$line"$'\n'
  done < "$input"

  # Remove leading blank lines
  echo "$content" | sed '/./,$!d' > "$output"
}

#######################################
# Sync a single command file
# Arguments:
#   $1 - Source command name (e.g., "specify")
#   $2 - Source path
#######################################
sync_command() {
  local cmd_name="$1"
  local src_file="$SOURCE_PATH/templates/commands/${cmd_name}.md"

  if [[ ! -f "$src_file" ]]; then
    echo "  [skip] $cmd_name.md (not found in source)"
    return
  fi

  local upstream_file="$UPSTREAM_DIR/commands/speckit.${cmd_name}.md"
  local full_mode_file="$MODES_FULL_DIR/${cmd_name}.md"

  if [[ "$DRY_RUN" == true ]]; then
    echo "  [would copy] $src_file → $upstream_file"
    if [[ -f "$upstream_file" ]]; then
      local diff_output
      diff_output=$(diff "$upstream_file" "$src_file" 2>/dev/null || true)
      if [[ -n "$diff_output" ]]; then
        echo "    Changes detected"
      else
        echo "    No changes"
      fi
    else
      echo "    New file"
    fi
    echo "  [would generate] $full_mode_file (with path substitutions)"
    return
  fi

  # Copy verbatim to upstream
  cp "$src_file" "$upstream_file"
  echo "  [copied] speckit.${cmd_name}.md → upstream/"

  # Generate full mode file with substitutions
  local temp_file
  temp_file=$(mktemp)
  strip_frontmatter_and_input "$src_file" "$temp_file"
  apply_path_substitutions "$temp_file" "$full_mode_file"
  rm -f "$temp_file"
  echo "  [generated] ${cmd_name}.md → modes/major/"
}

#######################################
# Sync a single template file
# Arguments:
#   $1 - Template filename (e.g., "spec-template.md")
#######################################
sync_template() {
  local template_name="$1"
  local src_file="$SOURCE_PATH/templates/${template_name}"

  if [[ ! -f "$src_file" ]]; then
    echo "  [skip] $template_name (not found in source)"
    return
  fi

  local upstream_file="$UPSTREAM_DIR/templates/${template_name}"
  local full_template_file="$TEMPLATES_FULL_DIR/${template_name}"

  if [[ "$DRY_RUN" == true ]]; then
    echo "  [would copy] $src_file → $upstream_file"
    echo "  [would copy] $src_file → $full_template_file (with path adjustments)"
    return
  fi

  # Copy verbatim to upstream
  cp "$src_file" "$upstream_file"
  echo "  [copied] $template_name → upstream/templates/"

  # Copy to full templates with path adjustments
  apply_path_substitutions "$src_file" "$full_template_file"
  echo "  [generated] $template_name → templates/major/"
}

#######################################
# Sync a single script file
# Arguments:
#   $1 - Script filename (e.g., "common.sh")
#######################################
sync_script() {
  local script_name="$1"
  local src_file="$SOURCE_PATH/scripts/bash/${script_name}"

  if [[ ! -f "$src_file" ]]; then
    echo "  [skip] $script_name (not found in source)"
    return
  fi

  local upstream_file="$UPSTREAM_DIR/scripts/${script_name}"

  if [[ "$DRY_RUN" == true ]]; then
    echo "  [would copy] $src_file → $upstream_file"
    return
  fi

  cp "$src_file" "$upstream_file"
  echo "  [copied] $script_name → upstream/scripts/"
}

# =========================================================================
# Main sync logic
# =========================================================================

echo ""
echo "=== Syncing Commands ==="

# Ensure directories exist
if [[ "$DRY_RUN" == false ]]; then
  mkdir -p "$UPSTREAM_DIR/commands" "$UPSTREAM_DIR/templates" "$UPSTREAM_DIR/scripts"
  mkdir -p "$MODES_FULL_DIR"
  mkdir -p "$TEMPLATES_FULL_DIR"
fi

# Sync all spec-kit commands
COMMANDS=(specify clarify plan tasks implement analyze checklist constitution taskstoissues)
for cmd in "${COMMANDS[@]}"; do
  sync_command "$cmd"
done

echo ""
echo "=== Syncing Templates ==="

TEMPLATES=(spec-template.md plan-template.md tasks-template.md checklist-template.md agent-file-template.md)
for tmpl in "${TEMPLATES[@]}"; do
  sync_template "$tmpl"
done

echo ""
echo "=== Syncing Scripts ==="

SCRIPTS=(common.sh check-prerequisites.sh create-new-feature.sh setup-plan.sh update-agent-context.sh)
for script in "${SCRIPTS[@]}"; do
  sync_script "$script"
done

echo ""
echo "=== Writing VERSION ==="

VERSION_CONTENT="spec-kit $SPECKIT_TAG
commit: $SPECKIT_SHA
date: $SPECKIT_DATE
synced: $SYNC_DATE"

if [[ "$DRY_RUN" == true ]]; then
  echo "  [would write] $UPSTREAM_DIR/VERSION"
  echo "  Content:"
  # shellcheck disable=SC2001
  echo "$VERSION_CONTENT" | sed 's/^/    /'
else
  echo "$VERSION_CONTENT" > "$UPSTREAM_DIR/VERSION"
  echo "  [written] VERSION"
fi

echo ""
echo "=== Updating SPEC_KIT_VERSION ==="

SPEC_KIT_VERSION_FILE="$REPO_ROOT/.mykit/SPEC_KIT_VERSION"

if [[ "$DRY_RUN" == true ]]; then
  echo "  [would write] $SPEC_KIT_VERSION_FILE"
  echo "  Content: $SPECKIT_TAG"
else
  # Validate version tag
  if [[ -z "$SPECKIT_TAG" || "$SPECKIT_TAG" == "unknown" ]]; then
    echo "  [warning] Could not extract spec-kit version, skipping SPEC_KIT_VERSION update" >&2
  else
    # Atomic write: write to temp file, then move
    TEMP_VERSION_FILE=$(mktemp)
    if echo "$SPECKIT_TAG" > "$TEMP_VERSION_FILE" 2>/dev/null; then
      if mv "$TEMP_VERSION_FILE" "$SPEC_KIT_VERSION_FILE" 2>/dev/null; then
        echo "  [written] SPEC_KIT_VERSION ($SPECKIT_TAG)"
      else
        echo "  [error] Failed to update SPEC_KIT_VERSION file" >&2
        rm -f "$TEMP_VERSION_FILE"
      fi
    else
      echo "  [error] Failed to write version to temp file" >&2
      rm -f "$TEMP_VERSION_FILE"
    fi
  fi
fi

echo ""
if [[ "$DRY_RUN" == true ]]; then
  echo "=== DRY RUN complete — no files were modified ==="
else
  echo "=== Sync complete ==="
  echo ""
  echo "spec-kit $SPECKIT_TAG → my-kit"
  echo "  Upstream mirror: $HOME/.claude/skills/mykit/references/upstream/"
  echo "  Major mode files: $HOME/.claude/skills/mykit-workflow/references/major/"
  echo "  Major templates:  $HOME/.claude/skills/mykit/references/templates/major/"
  echo ""
  echo "Next steps:"
  echo "  1. Review changes: git diff"
  echo "  2. Check drift: $HOME/.claude/skills/mykit/references/scripts/check-upstream-drift.sh"
  echo "  3. Test Major mode workflow end-to-end"
  echo "  4. Commit and release"
fi
