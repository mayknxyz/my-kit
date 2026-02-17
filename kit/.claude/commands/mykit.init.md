# /mykit.init

Initialize My Kit in the current repository. Produces a single CLAUDE.md file with framework template and project principles.

## Usage

```
/mykit.init
```

## Description

The init command runs a 2-phase Claude-driven flow that bootstraps a project from zero to ready. No external scripts — everything is handled through Claude's tools.

**Output**: A single `CLAUDE.md` file at the project root containing framework instructions, project principles, and default workflow configuration.

## Implementation

### Pre-flight Check

Check if `CLAUDE.md` already exists at the project root.

**If it exists**, use `AskUserQuestion`:

- header: "Existing"
- question: "CLAUDE.md already exists. What would you like to do?"
- options:
  1. label: "Update principles", description: "Update the Project Principles section only"
  2. label: "Start fresh", description: "Overwrite CLAUDE.md with a new framework template"
  3. label: "Cancel", description: "Abort without making changes"

If "Cancel", display `Init cancelled. No files were modified.` and stop.

If "Update principles", skip to Phase 2 (read existing CLAUDE.md as the base instead of a template).

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

Use `AskUserQuestion`:

- header: "Principles"
- question: "What are the core principles for this project? (3-7 principles, e.g. 'Ship fast, type-safe, accessible')"
- options:
  1. label: "Performance-first", description: "Fast builds, minimal JS, optimized assets, Core Web Vitals"
  2. label: "Type-safe & accessible", description: "Strict TypeScript, WCAG 2.2 AA, semantic HTML"
  3. label: "Ship fast", description: "Minimal abstraction, convention over configuration, iterate quickly"
  4. label: "Skip", description: "Leave the principles section empty for now"

The user can select a preset or use "Other" to provide custom principles as free-text.

**If "Skip"**: Leave the `## Project Principles` section with the placeholder comment.

**Otherwise**: Parse the response (preset or custom) into a bulleted list of 3-7 principles and fill the `## Project Principles` section:

```markdown
## Project Principles

- **Principle Name**: Brief description of the principle
- **Principle Name**: Brief description of the principle
```

### Output

Write the completed CLAUDE.md to the project root. Keep the `## Workflow` section as-is from the template defaults (branch=main, PR format={version}: {title} (#{issue}), auto-assign=yes, draft=no). Nothing else.

### Summary

Display:

```
/mykit.init complete
  Framework:  {selected framework label}
  CLAUDE.md:  ./CLAUDE.md ({created|updated})
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
