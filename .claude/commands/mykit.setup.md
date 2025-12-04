# /mykit.setup

Configure My Kit preferences through an interactive setup wizard.

## Usage

```
/mykit.setup [run]
```

## Arguments

- **(none)**: Preview current configuration and wizard steps
- **run**: Launch the interactive wizard to configure settings

## Description

The setup wizard guides users through configuring My Kit preferences:

1. **GitHub Authentication** - Checks if `gh` CLI is authenticated
2. **Default Branch** - Auto-detects or prompts for the default PR branch
3. **PR Preferences** - Configure auto-assign and draft mode settings
4. **Validation Settings** - Configure auto-fix behavior
5. **Release Settings** - Set version prefix (e.g., "v" for v1.0.0)

Configuration is saved to `.mykit/config.json`.

## Examples

```bash
# Preview current configuration
/mykit.setup

# Run the interactive wizard
/mykit.setup run
```

## Implementation

Execute the setup wizard script based on the provided action:

```bash
ACTION="${1:-preview}"

.mykit/scripts/setup-wizard.sh "$ACTION"
```
