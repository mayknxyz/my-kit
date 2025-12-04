# Quickstart: /mykit.setup - Onboarding Wizard

**Date**: 2025-12-05
**Branch**: `003-setup-wizard`

## Overview

The setup wizard configures My Kit preferences through an interactive CLI flow. It runs automatically on first `/mykit.init` or manually via `/mykit.setup run`.

## Prerequisites

- Bash 4.0+
- git installed and repository initialized
- gh CLI installed (optional, for GitHub features)

## Usage

### Preview Mode (Default)

```bash
/mykit.setup
```

Shows current configuration status and what the wizard would configure.

### Run Wizard

```bash
/mykit.setup run
```

Launches the interactive wizard to configure:
1. GitHub authentication status
2. Default branch
3. PR preferences (auto-assign, draft mode)
4. Validation settings (auto-fix)
5. Release settings (version prefix)

### First-Time Setup

When running `/mykit.init` without an existing `.mykit/config.json`, the wizard launches automatically.

## Configuration Output

The wizard creates `.mykit/config.json`:

```json
{
  "github": {
    "authenticated": true
  },
  "defaults": {
    "branch": "main"
  },
  "pr": {
    "autoAssign": true,
    "draftMode": false
  },
  "validation": {
    "autoFix": true
  },
  "release": {
    "versionPrefix": "v"
  }
}
```

## Wizard Flow

```
┌─────────────────────────────────────┐
│  Step 1: GitHub Auth Check          │
│  (Detects if gh CLI is configured)  │
└──────────────┬──────────────────────┘
               ▼
┌─────────────────────────────────────┐
│  Step 2: Default Branch             │
│  (Auto-detects or prompts)          │
└──────────────┬──────────────────────┘
               ▼
┌─────────────────────────────────────┐
│  Step 3: PR Preferences             │
│  - Auto-assign: Yes/No              │
│  - Draft mode: Yes/No               │
└──────────────┬──────────────────────┘
               ▼
┌─────────────────────────────────────┐
│  Step 4: Validation Settings        │
│  - Auto-fix: Yes/No                 │
└──────────────┬──────────────────────┘
               ▼
┌─────────────────────────────────────┐
│  Step 5: Release Settings           │
│  - Version prefix: "v" or ""        │
└──────────────┬──────────────────────┘
               ▼
┌─────────────────────────────────────┐
│  Write config.json                  │
│  (Atomic write, safe on interrupt)  │
└─────────────────────────────────────┘
```

## Troubleshooting

### "GitHub CLI not authenticated"

Run `gh auth login` to authenticate, then re-run the wizard.

### Wizard interrupted

No partial config is written. Simply run `/mykit.setup run` again.

### Changing settings later

Run `/mykit.setup run` to re-launch the wizard with current values pre-filled.

## Implementation Files

| File | Purpose |
|------|---------|
| `.claude/commands/mykit.setup.md` | Slash command definition |
| `.mykit/scripts/setup-wizard.sh` | Core wizard logic |
| `.mykit/config.json` | Generated configuration |
