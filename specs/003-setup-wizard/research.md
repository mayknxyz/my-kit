# Research: /mykit.setup - Onboarding Wizard

**Date**: 2025-12-05
**Branch**: `003-setup-wizard`

## Research Topics

### 1. Bash Interactive Input Patterns

**Decision**: Use `read` builtin with `-p` for prompts and `-r` to handle backslashes correctly.

**Rationale**: Standard Bash approach that works across all target platforms without external dependencies. The `-p` flag provides inline prompts, and `-r` prevents backslash interpretation which could corrupt user input.

**Alternatives considered**:
- `dialog`/`whiptail` TUI libraries: Rejected - adds external dependency, not universally available
- `select` builtin for menus: Accepted for boolean choices (yes/no selections)
- `fzf` for fuzzy selection: Rejected - external dependency

**Pattern to use**:
```bash
# Text input
read -rp "Enter value: " variable

# Boolean selection
select choice in "Yes" "No"; do
  case $choice in
    Yes) variable=true; break;;
    No) variable=false; break;;
  esac
done
```

### 2. JSON Generation in Bash

**Decision**: Use `printf` with heredoc for JSON generation, with proper escaping.

**Rationale**: No external dependencies (like `jq`) required. The config structure is simple and predictable, making manual JSON construction safe.

**Alternatives considered**:
- `jq` for JSON manipulation: Rejected - external dependency not guaranteed
- `python -c` for JSON: Rejected - external dependency
- Template file with sed substitution: Considered but adds complexity for simple structure

**Pattern to use**:
```bash
cat > .mykit/config.json << EOF
{
  "github": {
    "authenticated": $gh_authenticated
  },
  "defaults": {
    "branch": "$default_branch"
  },
  "pr": {
    "autoAssign": $auto_assign,
    "draftMode": $draft_mode
  },
  "validation": {
    "autoFix": $auto_fix
  },
  "release": {
    "versionPrefix": "$version_prefix"
  }
}
EOF
```

### 3. GitHub CLI Authentication Check

**Decision**: Use `gh auth status` exit code to check authentication.

**Rationale**: Official gh CLI method. Exit code 0 means authenticated, non-zero means not authenticated or gh not installed.

**Alternatives considered**:
- Parse `gh auth status` output: Fragile, output format may change
- Check for `~/.config/gh/hosts.yml`: Platform-specific path, less reliable

**Pattern to use**:
```bash
if gh auth status &>/dev/null; then
  gh_authenticated=true
else
  gh_authenticated=false
  echo "Warning: GitHub CLI not authenticated. Some features will be limited."
fi
```

### 4. Default Branch Detection

**Decision**: Use `git symbolic-ref refs/remotes/origin/HEAD` or fall back to common defaults.

**Rationale**: Git's symbolic-ref accurately identifies the remote's default branch. Fallback chain handles repos without remote or new repos.

**Alternatives considered**:
- Parse `.git/config`: Less reliable, may not have default branch info
- GitHub API call: Requires authentication, adds network dependency
- Hardcode "main": Doesn't support legacy repos with "master"

**Pattern to use**:
```bash
default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
if [[ -z "$default_branch" ]]; then
  # Fallback: check if main or master exists
  if git show-ref --verify --quiet refs/heads/main; then
    default_branch="main"
  elif git show-ref --verify --quiet refs/heads/master; then
    default_branch="master"
  else
    default_branch="main"  # Default for new repos
  fi
fi
```

### 5. Atomic Config Write (Interruption Safety)

**Decision**: Write to temporary file first, then atomic move.

**Rationale**: Prevents partial config writes if user interrupts (Ctrl+C) or terminal closes. Satisfies FR-012.

**Alternatives considered**:
- Direct write to config.json: Risk of partial file on interrupt
- In-memory accumulation with single write: Same risk without atomic move
- Lock file mechanism: Over-engineering for single-user CLI

**Pattern to use**:
```bash
trap 'rm -f "$temp_config"; exit 1' INT TERM

temp_config=$(mktemp)
# ... write JSON to $temp_config ...
mv "$temp_config" .mykit/config.json
```

### 6. Existing Config Handling (Pre-population)

**Decision**: Parse existing config.json with `grep` and `sed` for simple value extraction.

**Rationale**: Avoids jq dependency. Config structure is known and simple.

**Alternatives considered**:
- `jq` parsing: External dependency
- Source as shell variables: JSON not valid shell syntax
- Python/Node parsing: External dependencies

**Pattern to use**:
```bash
if [[ -f .mykit/config.json ]]; then
  # Extract existing values (simple patterns for known structure)
  existing_branch=$(grep -o '"branch": *"[^"]*"' .mykit/config.json | cut -d'"' -f4)
  # ... similar for other fields
fi
```

## Resolved Unknowns

All technical context items resolved. No NEEDS CLARIFICATION remains.

| Item | Resolution |
|------|------------|
| Interactive input | `read -rp` and `select` builtins |
| JSON generation | `printf` with heredoc, no jq |
| gh auth check | `gh auth status` exit code |
| Default branch | `git symbolic-ref` with fallbacks |
| Atomicity | temp file + mv pattern |
| Config parsing | grep/sed for known structure |
