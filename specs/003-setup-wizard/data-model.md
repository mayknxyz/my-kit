# Data Model: /mykit.setup - Onboarding Wizard

**Date**: 2025-12-05
**Branch**: `003-setup-wizard`

## Entities

### Configuration

The primary entity representing user preferences for My Kit.

**Storage**: `.mykit/config.json`

**Schema**:

```json
{
  "github": {
    "authenticated": boolean
  },
  "defaults": {
    "branch": string
  },
  "pr": {
    "autoAssign": boolean,
    "draftMode": boolean
  },
  "validation": {
    "autoFix": boolean
  },
  "release": {
    "versionPrefix": string
  }
}
```

**Fields**:

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `github.authenticated` | boolean | Yes | detected | Whether gh CLI is authenticated |
| `defaults.branch` | string | Yes | detected or "main" | Default branch for PRs |
| `pr.autoAssign` | boolean | Yes | true | Auto-assign PR creator |
| `pr.draftMode` | boolean | Yes | false | Create PRs as drafts by default |
| `validation.autoFix` | boolean | Yes | true | Auto-fix linting issues |
| `release.versionPrefix` | string | Yes | "v" | Prefix for version tags |

**Validation Rules**:

1. `defaults.branch` must be non-empty string
2. `release.versionPrefix` may be empty string (for bare versions like `1.0.0`) or "v" (for `v1.0.0`)
3. All boolean fields must be `true` or `false` (not strings)
4. JSON must be valid and parseable

**State Transitions**:

```
[No Config] ---(wizard complete)---> [Config Exists]
[Config Exists] ---(wizard re-run)---> [Config Updated]
[Wizard Running] ---(cancel/interrupt)---> [No Change]
```

### Setup Step

Represents an individual configuration category in the wizard flow.

**Not persisted** - runtime concept only.

| Step | Order | Fields Collected | Blocking |
|------|-------|------------------|----------|
| GitHub Auth Check | 1 | `github.authenticated` | No (warns only) |
| Default Branch | 2 | `defaults.branch` | No |
| PR Preferences | 3 | `pr.autoAssign`, `pr.draftMode` | No |
| Validation Settings | 4 | `validation.autoFix` | No |
| Release Settings | 5 | `release.versionPrefix` | No |

## Relationships

```
Repository (1) ----has----> (0..1) Configuration
Wizard Run (1) ----produces----> (1) Configuration (on success)
Wizard Run (1) ----reads----> (0..1) Configuration (for pre-population)
```

## File System Layout

```
.mykit/
└── config.json          # Configuration entity storage

# Temporary during wizard execution:
/tmp/mykit-config-XXXXX  # Atomic write staging
```

## API Contracts

**N/A** - This feature is a CLI wizard with file-based storage. No REST/GraphQL endpoints are involved.

The wizard operates via:
1. Bash script execution (`.mykit/scripts/setup-wizard.sh`)
2. Claude Code slash command invocation (`/mykit.setup`)
3. Direct file I/O to `.mykit/config.json`
