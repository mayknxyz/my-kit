# /mykit.commit

Create a commit with conventional format and update CHANGELOG.md.

## Usage

```
/mykit.commit
```

## Description

This command auto-generates a conventional commit from the task context (spec, plan, tasks, changed files) and updates CHANGELOG.md. No interactive prompts — everything is inferred.

## Implementation

When this command is invoked, perform the following steps:

### Step 1: Check Prerequisite

```bash
source $HOME/.claude/skills/mykit/references/scripts/fetch-branch-info.sh
```

Check if tasks.md exists at `TASKS_PATH`. **If not**, display error and stop:

```
**Error**: No tasks file found at `{TASKS_PATH}`.

Run `/mykit.implement` first.
```

Check the `**Status**` field in tasks.md. **If not `Complete`**, display error and stop:

```
**Error**: Implementation not complete.

Run `/mykit.implement` to finish tasks first.
```

### Step 2: Check for Changes

Source scripts and check for uncommitted changes:

```bash
source $HOME/.claude/skills/mykit/references/scripts/git-ops.sh
```

If no uncommitted changes, display and stop:

```
**Info**: No uncommitted changes found. Nothing to commit.
```

Display changed files:

```bash
git status --short
```

### Step 3: Auto-Generate Commit Details

Infer commit details from context — no user prompts needed:

**Type**: Determine from the nature of changes:
- New files added → `feat`
- Existing files modified with bug fix context → `fix`
- Only markdown/doc files changed → `docs`
- Test files changed → `test`
- Config/dependency files changed → `chore`
- Performance-related changes → `perf`
- Code restructuring without behavior change → `refactor`

**Scope**: Derive from the most common directory or component among changed files (e.g., `ui`, `api`, `auth`). Omit if changes span too many areas.

**Description**: Generate a concise summary (< 72 chars) from the spec feature name and completed tasks.

**Issue number**: Extract from branch pattern `^([0-9]+)-`.

**Breaking change**: Default to `false`. Only flag as breaking if the spec or plan explicitly mentions breaking changes.

### Step 4: Auto-Detect Version Bump

Determine version bump from commit type:
- `feat` → minor
- `fix`, `docs`, `test`, `chore`, `perf`, `refactor`, `style` → patch
- Breaking change → major

Calculate next version from latest git tag:

```bash
source $HOME/.claude/skills/mykit/references/scripts/git-ops.sh

LATEST_TAG=$(git describe --tags --abbrev=0 --match 'v[0-9]*.[0-9]*.[0-9]*' 2>/dev/null || echo "v0.0.0")
```

Apply bump to get `CHANGELOG_VERSION`.

**If CHANGELOG already has a version header matching this version** (from a previous commit on this branch), reuse that version instead of bumping again.

### Step 5: Display Summary

Show the generated commit for review:

```
### Commit Summary

**Message**: {type}{(scope)}: {description}
**Version**: {CHANGELOG_VERSION}
**Issue**: Refs #{ISSUE_NUMBER}
**Files**: {changedFileCount} file(s)
```

### Step 6: Pre-Stage Safety Check

Before staging, verify no sensitive or critical files will be committed. Load the `security` skill and perform:

1. **Verify `.gitignore` exists** — If missing, create one with common exclusions (`.env*`, `node_modules/`, `*.pem`, `*.key`, credentials files).

2. **Scan untracked files** — Run `git status --porcelain` and check untracked files (`??`) against known sensitive patterns:
   - `.env`, `.env.*`, `.dev.vars` — environment variables / secrets
   - `*.pem`, `*.key`, `*.p12`, `*.pfx` — private keys / certificates
   - `credentials.json`, `service-account.json` — API credentials
   - `*.sqlite`, `*.db` — local databases
   - `node_modules/`, `.wrangler/`, `dist/` — build artifacts
   - Any file > 1MB — large binaries

3. **If sensitive files found**, display them and ask via `AskUserQuestion`:
   - header: "Sensitive"
   - question: "Sensitive files detected. How should these be handled?"
   - options:
     1. label: "Add to .gitignore", description: "Add all flagged files/patterns to .gitignore"
     2. label: "Ignore and continue", description: "Proceed anyway — I know what I'm doing"

   **If "Add to .gitignore"**: Append the matched patterns to `.gitignore`, then proceed.
   **If "Ignore and continue"**: Proceed without changes.

4. Continue to Step 7.

### Step 7: Update, Stage, and Commit

1. **Update CHANGELOG.md** with the version and entry:

```bash
source $HOME/.claude/skills/mykit/references/scripts/git-ops.sh

update_changelog "$COMMIT_TYPE" "$COMMIT_DESCRIPTION" "$CHANGELOG_VERSION"
```

2. **Update package.json** version (if it exists):

```bash
REPO_ROOT="$(git rev-parse --show-toplevel)"
PKG_FILE="${REPO_ROOT}/package.json"

if [[ -f "$PKG_FILE" ]]; then
  sed -i "s/\"version\": *\"[^\"]*\"/\"version\": \"${CHANGELOG_VERSION}\"/" "$PKG_FILE"
fi
```

3. **Stage all changes** (including CHANGELOG.md and package.json):

```bash
stage_all_changes
```

4. **Create the commit**:

Build subject: `{type}{(scope)}: {description}`
Build body with footers: `Refs #{ISSUE_NUMBER}` (and `BREAKING CHANGE: {description}` if applicable).

```bash
COMMIT_SHA=$(create_commit "$COMMIT_TYPE" "$COMMIT_DESCRIPTION" "$COMMIT_SCOPE" "$COMMIT_BODY")
```

### Step 8: Display Success

```
**Commit created successfully**

**Commit**: {sha}
**Message**: {message}
**Version**: {CHANGELOG_VERSION}

**Next steps**: `/mykit.pr`
```

---

## Error Handling

| Error | Message |
|-------|---------|
| No tasks.md | "No tasks file found. Run `/mykit.implement` first." |
| Tasks not complete | "Implementation not complete. Run `/mykit.implement` first." |
| No changes | "No uncommitted changes found. Nothing to commit." |
| Git commit failure | "Failed to create commit. {error message}" |
| CHANGELOG failure | Warning only — commit still proceeds |

## git-ops.sh Quick Reference

Functions available after `source $HOME/.claude/skills/mykit/references/scripts/git-ops.sh`:

| Function | Arguments | Returns |
|----------|-----------|---------|
| `has_uncommitted_changes` | none | exit 0 if changes exist |
| `get_changed_files` | none | stdout: file list |
| `stage_all_changes` | none | stages all via `git add -A` |
| `stage_files` | `$@ files` | stages specific files |
| `create_commit` | `$1 type` `$2 description` `$3 scope?` `$4 body?` | stdout: commit SHA |
| `update_changelog` | `$1 type` `$2 description` `$3 version?` | updates CHANGELOG.md |
| `calculate_next_version` | `$1 base_tag?` | stdout: `vX.Y.Z` |
| `get_commit_count` | `$1 base_branch?` | stdout: count |
| `get_branch_commits` | `$1 base_branch?` `$2 format?` | stdout: commit list |
| `get_pr_for_branch` | none | stdout: JSON `{number, title, headRefOid}` |

## Notes

- CHANGELOG.md is automatically created if it doesn't exist
- Commit follows conventional commits specification
- Version bump is auto-detected from commit type (feat=minor, fix=patch, breaking=major)
- `package.json` version is updated automatically when CHANGELOG is updated
