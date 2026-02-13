---
name: biome
description: >
  Biome linter/formatter for Astro + Tailwind projects. Use when configuring Biome, setting up
  linting rules, formatting, or CI integration. Triggers: Biome, linting, formatting, lint,
  format, biome.json, biome.jsonc, code quality, ESLint replacement, Prettier replacement.
---

# Biome

Senior Biome engineer. Unified linter + formatter. Replaces ESLint + Prettier. See `ci-cd` skill for CI integration, `astro` skill for Astro project setup.

## Configuration (Biome v2)

Use `biome.json` or `biome.jsonc` at project root. Schema version must match installed version.

```jsonc
// biome.json
{
  "$schema": "https://biomejs.dev/schemas/2.3.14/schema.json",
  "vcs": {
    "enabled": true,
    "clientKind": "git",
    "useIgnoreFile": true
  },
  "files": {
    // v2 uses "includes" with negation patterns (!!prefix) instead of v1 "ignore"
    "includes": ["**", "!!**/dist", "!!**/.wrangler", "!!**/.astro", "!!**/node_modules"]
  },
  "formatter": {
    "enabled": true,
    "indentStyle": "space",
    "indentWidth": 2,
    "lineWidth": 100
  },
  "javascript": {
    "formatter": {
      "quoteStyle": "double",
      "trailingCommas": "all",
      "semicolons": "always"
    }
  },
  "css": {
    "parser": {
      // Required for Tailwind v4 — prevents false errors on @theme, @utility, etc.
      "tailwindDirectives": true
    }
  },
  "linter": {
    "enabled": true,
    "rules": {
      "recommended": true,
      "suspicious": {
        "noExplicitAny": "warn"
      }
    }
  },
  // v2: organizeImports moved here from top-level
  "assist": {
    "enabled": true,
    "actions": {
      "source": {
        "organizeImports": "on"
      }
    }
  },
  "overrides": [
    {
      "includes": ["**/*.astro"],
      "linter": {
        "rules": {
          "correctness": {
            "noUnusedVariables": "off",
            "noUnusedImports": "off"
          },
          "style": {
            "useConst": "off",
            "useImportType": "off"
          },
          "suspicious": {
            "noImplicitAnyLet": "off"
          }
        }
      }
    },
    {
      "includes": ["**/*.svelte"],
      "linter": {
        "rules": {
          "style": { "useConst": "off" }
        }
      }
    }
  ]
}
```

### v1 → v2 Migration Notes

| v1 | v2 |
|---|---|
| `"organizeImports": { "enabled": true }` | `"assist": { "actions": { "source": { "organizeImports": "on" } } }` |
| `"files": { "ignore": ["dist"] }` | `"files": { "includes": ["**", "!!**/dist"] }` |
| `"include": ["*.astro"]` (in overrides) | `"includes": ["**/*.astro"]` (in overrides) |

## CLI Commands

```bash
# Direct
bun biome check .              # lint + format check
bun biome check --write .      # lint + format + fix
bun biome format --write .     # format only
bun biome lint .               # lint only
bun biome ci .                 # CI mode (no fixes, exit code on errors)
```

### Package.json Scripts

```json
{
  "scripts": {
    "lint": "biome check .",
    "lint:fix": "biome check --fix .",
    "format": "biome format .",
    "format:fix": "biome format --fix ."
  }
}
```

## CI Integration

```yaml
# In GitHub Actions workflow
- name: Lint & Format
  run: bun biome ci .
```

## Astro File Overrides

Astro files need special handling because:
- `useImportType` conflicts with Astro's component imports (needs runtime value)
- `useConst` conflicts with Astro's frontmatter variable patterns
- `noUnusedVariables` / `noUnusedImports` false-positive on frontmatter exports consumed by Astro
- `noImplicitAnyLet` false-positive on Astro's frontmatter `let` patterns
- Svelte files similarly need `useConst` off for rune declarations

## Companion Code Quality Tools

```bash
# Dead code detection — unused files, exports, dependencies
bunx knip
bunx knip --include files,exports,dependencies

# Copy-paste / duplicate code detection
jscpd ./src
jscpd ./src --format json --output report.json
```

## MUST DO

- Use `biome.json` or `biome.jsonc` at project root
- Match `$schema` version to installed Biome version
- Add overrides for `.astro` and `.svelte` files (all 5 rules listed above)
- Use `biome ci` in CI pipelines (fails on errors, no auto-fix)
- Exclude build output directories: `dist`, `.wrangler`, `.astro`, `node_modules`
- Enable `css.parser.tailwindDirectives` for Tailwind v4 projects
- Enable `vcs.useIgnoreFile` to respect `.gitignore`

## MUST NOT

- Mix Biome with ESLint or Prettier — Biome replaces both
- Skip `.astro` file overrides — some rules break Astro files
- Use `biome check --write` in CI — use `biome ci` (read-only)
- Forget to ignore `.wrangler` — wrangler generates minified build artifacts that produce thousands of false lint errors
- Use v1 config syntax (`"ignore"`, `"include"`, top-level `"organizeImports"`) with v2

Docs: https://biomejs.dev
