# /mykit.init

Initialize My Kit in the current repository. Produces a single CLAUDE.md file with framework template, project principles, and workflow preferences.

## Usage

```
/mykit.init
```

## Description

The init command runs a 3-phase Claude-driven flow that bootstraps a project from zero to ready. No external scripts — everything is handled through Claude's tools.

**Output**: A single `CLAUDE.md` file at the project root containing framework instructions, project principles, and workflow configuration.

## Implementation

### Pre-flight Check

Check if `CLAUDE.md` already exists at the project root.

**If it exists**, use `AskUserQuestion`:

- header: "Existing"
- question: "CLAUDE.md already exists. What would you like to do?"
- options:
  1. label: "Update sections", description: "Update Project Principles and/or Workflow sections only"
  2. label: "Start fresh", description: "Overwrite CLAUDE.md with a new framework template"
  3. label: "Cancel", description: "Abort without making changes"

If "Cancel", display `Init cancelled. No files were modified.` and stop.

If "Update sections", skip to Phase 2 (read existing CLAUDE.md as the base instead of a template).

If "Start fresh", continue to Phase 1.

### Phase 1: Framework Selection

**Step 1.1**: Detect available frameworks by listing directories in `$HOME/.claude/skills/mykit/references/templates/frameworks/`. Each subdirectory name is a framework option.

**Step 1.2**: Prompt the user to select a framework using `AskUserQuestion`:

- header: "Framework"
- question: "Which framework/stack is this project using?"
- options: One option per detected framework directory. Use these labels and descriptions:
  - `vanilla` → label: "Vanilla HTML+CSS+JS", description: "No framework — semantic HTML, CSS custom properties, ES modules"
  - `astro` → label: "Astro", description: "Content-focused static site generator with island architecture"
  - `sveltekit` → label: "SvelteKit", description: "Full-stack framework with Svelte 5 runes and SSR"
  - For any other directory name, use the directory name as the label with description: "Custom framework template"

**Step 1.3**: Read the selected framework's CLAUDE.md template:
- `$HOME/.claude/skills/mykit/references/templates/frameworks/{selected}/CLAUDE.md`

This becomes the base content for the project's CLAUDE.md.

### Phase 2: Project Principles

**Step 2.1**: Use `AskUserQuestion`:

- header: "Principles"
- question: "What are the core principles for this project? (describe 3-5 principles, e.g. 'Ship fast, type-safe, accessible')"
- options:
  1. label: "Enter principles", description: "Define project-specific design principles"
  2. label: "Skip", description: "Leave the principles section empty for now"

**If "Skip"**: Leave the `## Project Principles` section with the placeholder comment.

**If "Enter principles"**: Ask for the principles as free-form text. The user can describe them in natural language. Parse the response into a bulleted list and fill the `## Project Principles` section:

```markdown
## Project Principles

- **Principle Name**: Brief description of the principle
- **Principle Name**: Brief description of the principle
```

### Phase 3: Workflow Preferences

**Step 3.1**: Show the default workflow values from the template and ask:

Use `AskUserQuestion`:

- header: "Workflow"
- question: "Customize workflow preferences? Defaults: branch=main, PR format={version}: {title} (#{issue}), auto-assign=yes, draft=no"
- options:
  1. label: "Use defaults", description: "Keep the default workflow settings"
  2. label: "Customize", description: "Change branch, PR format, or other preferences"

**If "Use defaults"**: Keep the `## Workflow` section as-is from the template.

**If "Customize"**: Ask about each preference and update the `## Workflow` section accordingly.

### Output

Write the completed CLAUDE.md to the project root. Nothing else.

### Summary

Display:

```
/mykit.init complete
  Framework:  {selected framework label}
  CLAUDE.md:  ./CLAUDE.md (created)
  Next step:  /mykit.specify
```

## Error Handling

- If `$HOME/.claude/skills/mykit/references/templates/frameworks/` directory does not exist or is empty, output: `Error: No framework templates found. Ensure My Kit is installed.`
- If a selected framework template is missing CLAUDE.md, output: `Error: Incomplete template for {framework}. Expected CLAUDE.md in $HOME/.claude/skills/mykit/references/templates/frameworks/{framework}/`

## Extensibility

Adding a new framework requires only:
1. Create a new directory under `$HOME/.claude/skills/mykit/references/templates/frameworks/{name}/`
2. Add `CLAUDE.md` with Project Principles and Workflow sections
3. The init wizard will automatically detect and offer it as an option

## Related Commands

| Command | Relationship |
|---------|--------------|
| `/mykit.specify` | Recommended next step after init completes |
| `/mykit.status` | Shows current configuration state |
