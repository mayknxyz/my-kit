# Quickstart: Curl-Based Installer

**Feature**: 001-curl-installer
**Date**: 2025-12-04

## Prerequisites

Before installing My Kit, ensure you have:

1. **git** - Version control
   ```bash
   git --version
   ```

2. **GitHub CLI (gh)** - GitHub integration
   ```bash
   gh --version
   ```

   If not installed: https://cli.github.com/

3. **A git repository** - My Kit must be installed in a git repo
   ```bash
   git rev-parse --is-inside-work-tree  # Should output "true"
   ```

## Installation

### One-Line Install

From your project's root directory:

```bash
curl -fsSL https://raw.githubusercontent.com/mayknxyz/my-kit/main/install.sh | bash
```

### What Gets Installed

```
your-project/
├── .claude/
│   └── commands/
│       └── mykit.*.md    # Slash commands for Claude Code
└── .mykit/
    ├── config.json       # Your configuration
    ├── scripts/          # Shell utilities
    └── templates/        # Workflow templates
```

## Verification

After installation, verify it worked:

1. **Check files exist**:
   ```bash
   ls .claude/commands/mykit.*.md
   ls .mykit/scripts/
   ```

2. **Start Claude Code** in your project directory

3. **Run your first command**:
   ```
   /mykit.help
   ```

## First Steps

1. **Initialize My Kit** for your repository:
   ```
   /mykit.init create
   ```

2. **Configure preferences** (optional):
   ```
   /mykit.setup run
   ```

3. **Start a workflow**:
   ```
   /mykit.start run
   ```

## Troubleshooting

### "git is not installed"

Install git for your platform:
- macOS: `brew install git`
- Ubuntu/Debian: `sudo apt install git`
- Windows: https://git-scm.com/downloads

### "gh CLI is not installed"

Install GitHub CLI:
- macOS: `brew install gh`
- Ubuntu/Debian: `sudo apt install gh`
- Windows: `winget install GitHub.cli`

Then authenticate: `gh auth login`

### "Not a git repository"

Initialize a git repository first:
```bash
git init
```

### "Permission denied"

Ensure you have write access to the current directory:
```bash
touch .test && rm .test  # Should succeed without error
```

### Installation Failed Mid-Way

The installer is atomic. If it failed, no partial files remain. Simply fix the issue (e.g., network) and re-run the install command.

## Upgrading

To upgrade to the latest version:

```
/mykit.upgrade run
```

Or re-run the installation command - it will update existing files while preserving your configuration.

## Uninstalling

To remove My Kit:

```bash
rm -rf .claude/commands/mykit.*.md
rm -rf .mykit/
```

Note: This preserves any non-My Kit files you may have added to `.claude/commands/`.
