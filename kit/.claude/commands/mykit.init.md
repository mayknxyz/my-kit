# /mykit.init

Initialize My Kit in the current repository with an interactive onboarding wizard.

## Usage

```
/mykit.init
```

Executes directly: Run the full 3-phase wizard to bootstrap the project.

## Description

The init command runs a continuous 3-phase onboarding wizard that bootstraps a project from zero to ready. It is designed to run once after `install.sh` has copied the My Kit files into the repository.

**Phases**:

1. **Framework Selection** — Choose a framework/stack and install CLAUDE.md + CONVENTIONS.md templates
2. **Tool Preferences** — Configure GitHub auth, default branch, PR prefs, validation, and release settings (same as `/mykit.setup`)
3. **Project Principles** — Define the project constitution with core design principles (same as `/mykit.constitution`)

## Implementation

When this command is invoked, parse the first argument to determine the mode.

### Preview Mode (no argument)

If no argument is provided, display a preview of all 3 phases without writing any files.

Output the following:

```
/mykit.init — Project Onboarding Preview
═════════════════════════════════════════

Phase 1: Framework Selection
─────────────────────────────
  Prompt: Select framework/stack (Vanilla HTML+CSS+JS, Astro, SvelteKit)
  Produces:
    • CLAUDE.md (project root) — framework-specific Claude Code instructions
    • docs/CONVENTIONS.md — coding conventions and patterns

  Templates sourced from: $HOME/.claude/skills/mykit/references/templates/frameworks/{selected}/

Phase 2: Tool Preferences
─────────────────────────
  Interactive wizard (7 steps):
    1. GitHub CLI authentication check
    2. Default branch detection/confirmation
    3. PR preferences (auto-assign, draft mode)
    4. PR title template (format with placeholders)
    5. Auto-branch creation on specify
    6. Validation settings (auto-fix)
    7. Release settings (version prefix)
  Produces:
    • .mykit/config.json

Phase 3: Project Principles
───────────────────────────
  Interactive session to define project design principles.
  Fills the constitution template with concrete values.
  Produces:
    • .mykit/memory/constitution.md

To run the wizard: /mykit.init create
```

Then stop. Do not write any files or prompt for input.

### Create Mode (`create` argument)

If the argument is `create`, execute all 3 phases as a continuous wizard flow.

#### Pre-flight Check

Before starting, check if the project appears already initialized:

1. Check if `CLAUDE.md` exists at the project root
2. Check if `.mykit/config.json` exists
3. Check if `.mykit/memory/constitution.md` has been filled (not just the template)

If any of these exist, use `AskUserQuestion` to warn the user:

- header: "Overwrite"
- question: "This project appears already initialized. Existing files will be overwritten. Continue?"
- options:
  1. label: "Continue", description: "Overwrite existing configuration files"
  2. label: "Cancel", description: "Abort without making changes"

If the user selects "Cancel", stop and output: `Init cancelled. No files were modified.`

#### Phase 1: Framework Selection

**Step 1.1**: Detect available frameworks by listing directories in `$HOME/.claude/skills/mykit/references/templates/frameworks/`. Each subdirectory name is a framework option.

**Step 1.2**: Prompt the user to select a framework using `AskUserQuestion`:

- header: "Framework"
- question: "Which framework/stack is this project using?"
- options: One option per detected framework directory. Use these labels and descriptions:
  - `vanilla` → label: "Vanilla HTML+CSS+JS", description: "No framework — semantic HTML, CSS custom properties, ES modules"
  - `astro` → label: "Astro", description: "Content-focused static site generator with island architecture"
  - `sveltekit` → label: "SvelteKit", description: "Full-stack framework with Svelte 5 runes and SSR"
  - For any other directory name, use the directory name as the label with description: "Custom framework template"

**Step 1.3**: Based on the selection, determine the template directory path:
- `$HOME/.claude/skills/mykit/references/templates/frameworks/{selected}/`

**Step 1.4**: Copy the framework templates to the project:

1. Read `$HOME/.claude/skills/mykit/references/templates/frameworks/{selected}/CLAUDE.md` and write it to `./CLAUDE.md` (project root)
2. Create the `docs/` directory if it does not exist
3. Read `$HOME/.claude/skills/mykit/references/templates/frameworks/{selected}/CONVENTIONS.md` and write it to `./docs/CONVENTIONS.md`

**Step 1.5**: Confirm Phase 1 completion:

```
Phase 1 complete — Framework: {selected label}
  ✓ CLAUDE.md created
  ✓ docs/CONVENTIONS.md created
```

#### Phase 2: Tool Preferences

**Step 2.1**: Output a phase header:

```
Phase 2: Tool Preferences
─────────────────────────
```

**Step 2.2**: Execute the setup wizard by running the following Bash command:

```bash
$HOME/.claude/skills/mykit/references/scripts/setup-wizard.sh run
```

This runs the interactive 7-step setup wizard which writes `.mykit/config.json`.

**Step 2.3**: After the script completes, confirm Phase 2 completion:

```
Phase 2 complete — Tool preferences configured
  ✓ .mykit/config.json created
```

#### Phase 3: Project Principles

**Step 3.1**: Output a phase header:

```
Phase 3: Project Principles
───────────────────────────
```

**Step 3.2**: Execute the constitution wizard. Follow the same logic as the `/mykit.constitution` command:

1. Read the existing constitution template at `.mykit/memory/constitution.md`
2. Identify all placeholder tokens of the form `[ALL_CAPS_IDENTIFIER]`
3. If the constitution is already filled (no placeholder tokens remain), ask the user if they want to keep existing principles or start fresh
4. If placeholders exist or the user wants to start fresh, use `AskUserQuestion` to collect the project name and core principles:
   - header: "Principles"
   - question: "How many core design principles should this project have? (The constitution template defaults to 5)"
   - options:
     1. label: "3 principles", description: "Lightweight — fewer rules, more flexibility"
     2. label: "5 principles", description: "Standard — balanced governance (recommended)"
     3. label: "7 principles", description: "Comprehensive — detailed governance for larger projects"
5. For each principle, ask the user to provide: a name and a brief description of the rule
6. Fill the constitution template with the collected values
7. Write the completed constitution to `.mykit/memory/constitution.md`

**Step 3.3**: Confirm Phase 3 completion:

```
Phase 3 complete — Project principles defined
  ✓ .mykit/memory/constitution.md updated
```

#### Summary

After all 3 phases complete, display a summary:

```
═══════════════════════════════════════
  /mykit.init — Setup Complete
═══════════════════════════════════════

  Framework:    {selected framework label}
  Config:       .mykit/config.json
  Constitution: .mykit/memory/constitution.md
  CLAUDE.md:    ./CLAUDE.md
  Conventions:  ./docs/CONVENTIONS.md

  Next step: Run /mykit.specify to begin your first workflow.
═══════════════════════════════════════
```

## Error Handling

- If `$HOME/.claude/skills/mykit/references/templates/frameworks/` directory does not exist or is empty, output an error: `Error: No framework templates found. Run install.sh first.`
- If a selected framework template is missing CLAUDE.md or CONVENTIONS.md, output an error: `Error: Incomplete template for {framework}. Expected CLAUDE.md and CONVENTIONS.md in $HOME/.claude/skills/mykit/references/templates/frameworks/{framework}/`
- If `setup-wizard.sh` exits with non-zero, report the error but continue to Phase 3
- If the constitution template does not exist, output a warning and skip Phase 3

## Extensibility

Adding a new framework requires only:
1. Create a new directory under `$HOME/.claude/skills/mykit/references/templates/frameworks/{name}/`
2. Add `CLAUDE.md` and `CONVENTIONS.md` to that directory
3. The init wizard will automatically detect and offer it as an option

## Related Commands

| Command | Relationship |
|---------|--------------|
| `/mykit.setup` | Phase 2 runs the same setup wizard (standalone re-configuration) |
| `/mykit.constitution` | Phase 3 runs the same constitution logic (standalone editing) |
| `/mykit.specify` | Recommended next step after init completes |
| `/mykit.status` | Shows current configuration state |
