# /mykit.sync

Install or upgrade My Kit v2 from the source repository.

## Usage

```
/mykit.sync
```

- Executes directly: Shows current vs latest version, prompts to update

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Implementation

This command works from **any directory** — it always operates on `~/my-kit-v2`.

### Step 1: Verify Source Repository

Check that `~/my-kit-v2` exists and is a git repo:

```bash
test -d ~/my-kit-v2/.git
```

**If not found**, display error and stop:

```
**Error**: My Kit v2 source repository not found at `~/my-kit-v2`.

To install:
  git clone git@github.com:mayknxyz/my-kit-v2.git ~/my-kit-v2
  cd ~/my-kit-v2 && stow -t ~ kit
```

### Step 2: Get Current Version

```bash
cd ~/my-kit-v2
CURRENT_SHA=$(git rev-parse --short HEAD)
CURRENT_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "untagged")
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
```

### Step 3: Fetch Latest

```bash
cd ~/my-kit-v2
git fetch origin 2>/dev/null
```

**If fetch fails** (network error), display warning and continue with local info only:

```
**Warning**: Could not fetch from remote. Showing local info only.
```

### Step 4: Check for Updates

```bash
cd ~/my-kit-v2
LOCAL_SHA=$(git rev-parse HEAD)
REMOTE_SHA=$(git rev-parse origin/main 2>/dev/null || echo "")
LATEST_TAG=$(git describe --tags --abbrev=0 origin/main 2>/dev/null || echo "untagged")
```

**If `LOCAL_SHA` equals `REMOTE_SHA`**:

```
**My Kit v2** is up to date.

**Version**: {CURRENT_TAG} ({CURRENT_SHA})
**Branch**: {CURRENT_BRANCH}
```

Stop execution here.

### Step 5: Show What Would Change

```bash
cd ~/my-kit-v2
COMMITS_BEHIND=$(git rev-list HEAD..origin/main --count 2>/dev/null || echo "?")
DIFF_SUMMARY=$(git diff --stat HEAD..origin/main 2>/dev/null || echo "")
```

Display:

```
**My Kit v2** update available.

**Current**: {CURRENT_TAG} ({CURRENT_SHA})
**Latest**: {LATEST_TAG} ({REMOTE_SHA short})
**Behind**: {COMMITS_BEHIND} commit(s)

### Changes

{DIFF_SUMMARY}
```

### Step 6: Prompt to Update

Use `AskUserQuestion`:
- header: "Update"
- question: "Update My Kit v2 to latest?"
- options:
  1. label: "Update to latest (Recommended)", description: "Pull latest from main and re-stow"
  2. label: "Pick a version", description: "Choose a specific tagged version"
  3. label: "Cancel", description: "Do nothing"

**If user selects "Cancel"**: Display "Update cancelled." and stop.

**If user selects "Update to latest"**: Continue to Step 7.

**If user selects "Pick a version"**:

1. List available tags:
   ```bash
   cd ~/my-kit-v2
   git tag --sort=-v:refname | head -10
   ```

2. Use `AskUserQuestion` to let user pick from available tags (show up to 4 most recent).

3. Checkout the selected tag:
   ```bash
   cd ~/my-kit-v2
   git checkout {selected_tag}
   ```

4. Continue to Step 8 (skip the pull).

### Step 7: Pull Latest

```bash
cd ~/my-kit-v2
git pull origin main
```

**If pull fails** (merge conflicts, etc.), display error and stop:

```
**Error**: Failed to pull latest changes.

Git error: {error message}

Try resolving manually:
  cd ~/my-kit-v2 && git status
```

### Step 8: Re-stow

```bash
cd ~/my-kit-v2
stow -R -t ~ kit
```

**If stow fails** (conflicts), display error and stop:

```
**Error**: Stow failed — conflicts detected.

{error output}

Try resolving manually:
  cd ~/my-kit-v2 && stow -R -t ~ kit
```

### Step 9: Display Success

```bash
cd ~/my-kit-v2
NEW_SHA=$(git rev-parse --short HEAD)
NEW_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "untagged")
```

```
**My Kit v2 updated successfully.**

**Version**: {NEW_TAG} ({NEW_SHA})

Symlinks refreshed via `stow -R`.
```

## Error Handling

| Error | Message |
|-------|---------|
| Source repo missing | Install instructions |
| Fetch fails | Warning, continue with local info |
| Pull fails | Show git error, suggest manual resolution |
| Stow conflicts | Show conflict details |

## Related Commands

| Command | Relationship |
|---------|--------------|
| `/mykit.status` | Show current workflow state |
| `/mykit.help` | Show command documentation |
