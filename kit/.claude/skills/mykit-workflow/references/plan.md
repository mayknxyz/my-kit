<!-- Plan workflow -->

## Plan

Create a lightweight implementation plan from a feature specification via guided conversation.

**Important**: When a spec file exists for the current branch, always use this custom plan skill (`/mykit.plan`) instead of Claude Code's native `EnterPlanMode`. `EnterPlanMode` is only appropriate for exploration and research when no spec file exists yet.

### Step 1: Check Prerequisite

```bash
source $HOME/.claude/skills/mykit/references/scripts/fetch-branch-info.sh
```

Check if the spec file exists at `SPEC_PATH`. **If not**, display error and stop:

```
**Error**: No specification found at `{SPEC_PATH}`.

Run `/mykit.specify` first.
```

### Step 2: Check for Existing Plan

**If plan file exists at `planPath`**:

Use `AskUserQuestion` tool to prompt:

- header: "Existing Plan"
- question: "A plan file already exists at this location. What would you like to do?"
- options:
    1. label: "Overwrite", description: "Replace the existing plan entirely"
    2. label: "Cancel", description: "Abort and keep the existing plan"

- If user selects "Cancel", display message and stop:

  ```
  Operation cancelled. Existing plan preserved.
  ```

### Step 3: Read and Analyze Spec File

Read the spec file content from `specPath`.

Extract the following information from the spec:

- **Feature name**: From the `# Feature Specification:` heading
- **User Stories**: All sections matching `### User Story N -`
- **Functional Requirements**: All items under `### Functional Requirements`
- **Key Entities**: All items under `### Key Entities` (if present)
- **Success Criteria**: All items under `### Measurable Outcomes`
- **Clarifications**: Any recorded clarifications from `## Clarifications` section

### Step 4: Identify Technical Decisions (Guided Conversation)

Analyze the spec content to identify areas that may need technical clarification.

**Question triggers** (ask only if relevant to the spec):

1. **Technology stack**: If spec mentions features requiring specific tech choices (e.g., authentication, data storage, APIs)
2. **Integration approach**: If spec mentions external services or integrations
3. **Performance approach**: If spec has specific performance requirements
4. **Testing strategy**: If spec mentions testing requirements without specifying approach

**For each identified ambiguity** (maximum 3-5 questions total):

Use `AskUserQuestion` tool with:

- header: "Plan: {topic}"
- question: "{specific question about the technical decision}"
- multiSelect: false
- options: 2-4 relevant options with descriptions

Record each answer for use in plan generation.

**If no ambiguities detected**: Skip to Step 5 without asking questions.

### Step 5: Detect Relevant Skills

Scan the spec content and technical decisions for keywords that map to domain skills. Match against the 23 available skills using their trigger keywords:

| Skill | Match keywords |
|-------|---------------|
| a11y | accessibility, ARIA, keyboard navigation, screen reader, WCAG, contrast |
| analytics | analytics, tracking, events, page views, Umami |
| animation | animation, transition, scroll effect, motion, fade, slide |
| api-design | API, REST, endpoint, HTTP, status codes, pagination |
| astro | Astro, .astro, content collections, islands |
| biome | Biome, linting, formatting, lint, format |
| ci-cd | CI/CD, GitHub Actions, workflow, deploy, pipeline |
| cloudflare | Cloudflare, Workers, Pages, KV, D1, R2, wrangler |
| copywriting | copywriting, microcopy, CTA, error message, empty state |
| database | database, D1, SQLite, SQL, schema, migration |
| design-system | design tokens, color scale, typography, spacing, theming |
| git | git, commit, branch, PR, merge |
| performance | performance, Core Web Vitals, LCP, CLS, font loading, lazy loading |
| responsive | responsive, mobile-first, breakpoints, container queries, fluid |
| security | security, CSP, XSS, CORS, validation, secrets |
| seo | SEO, meta tags, JSON-LD, Open Graph, sitemap, structured data |
| svelte | Svelte, .svelte, runes, $state, $props, SvelteKit |
| tailwind | Tailwind, utility classes, @theme, dark mode |
| testing | test, Vitest, Playwright, Testing Library, coverage |
| typescript | TypeScript, .ts, types, interfaces, generics, strict |
| web-core | semantic HTML, CSS nesting, container queries, custom elements |
| zod | Zod, schema validation, safeParse, z.object |

Collect all matched skills into a `relevantSkills[]` list. Each entry has a `name` and a brief `reason` (why it was matched).

### Step 6: Generate Plan Content

Generate the plan content using this structure:

```markdown
# Implementation Plan: {featureName}

**Branch**: `{branch}` | **Created**: {currentDate} | **Spec**: [spec.md](./spec.md)

## Technical Context

- **Technologies**: {list technologies from spec, codebase context, or guided conversation answers}
- **Dependencies**: {list external dependencies identified}
- **Integration Points**: {list what this feature connects to}

## Design Decisions

### {Decision Title from guided conversation or spec}

**Choice**: {what was decided}
**Rationale**: {why this choice makes sense}

{Repeat for each significant design decision}

## Skills

{For each skill in relevantSkills[]:}
- **{name}** — {reason}

## Implementation Phases

### Phase 1: {phase-title}

{description of what this phase accomplishes}

**Key Tasks**:
- {task 1}
- {task 2}
- {task 3}

### Phase 2: {phase-title}

{description of what this phase accomplishes}

**Key Tasks**:
- {task 1}
- {task 2}

{Continue for additional phases as needed}

## Success Criteria Reference

{Reference the success criteria from the spec that this plan addresses}
```

Where:

- `featureName` = extracted from spec header
- `branch` = current git branch
- `currentDate` = today's date in YYYY-MM-DD format

### Step 7: Write Plan

1. Create the specs directory if it doesn't exist
2. Write the plan content to `planPath`
3. Display confirmation:

```
**Plan created successfully!**

**File**: {planPath}
**Source**: {questionCount > 0 ? "Spec analysis + guided conversation" : "Spec analysis"}

Next step: `/mykit.tasks` to create the task breakdown.
```
