# Implementation Plan: /mykit.plan - Lightweight Plan (AI Skill)

**Branch**: `010-lightweight-plan` | **Date**: 2025-12-07 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/010-lightweight-plan/spec.md`

## Summary

Implement the `/mykit.plan` slash command as a lightweight AI skill that generates implementation plans from feature specifications via guided conversation. The command follows the established preview/execute pattern, reads the spec file, asks clarifying technical questions (max 3-5), and outputs a `plan.md` file with Technical Context, Design Decisions, and Implementation Phases sections.

## Technical Context

**Language/Version**: Markdown (Claude Code slash command) + Bash 4.0+ (helper validation)
**Primary Dependencies**: Claude Code conversation context, `git` CLI, `gh` CLI (optional)
**Storage**: File system (`specs/{branch}/plan.md`, `.mykit/state.json`)
**Testing**: Manual testing via command execution
**Target Platform**: Any platform with Claude Code CLI installed
**Project Type**: Single project (CLI slash command)
**Performance Goals**: Plan generation completes in under 2 minutes of interactive time
**Constraints**: No external template files; AI generates structure inline
**Scale/Scope**: Single command file, single helper script (optional)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Spec-First Development | ✅ PASS | Spec exists at `specs/010-lightweight-plan/spec.md` |
| II. Issue-Linked Traceability | ✅ PASS | Branch `010-lightweight-plan` links to Issue #10 |
| III. Explicit Execution | ✅ PASS | Command follows preview/execute pattern with `create` action |
| IV. Validation Gates | ✅ PASS | Command checks for spec file before proceeding |
| V. Simplicity | ✅ PASS | Single command file, no external dependencies, inline plan generation |

**Gate Result**: PASS - Proceed to Phase 0

## Project Structure

### Documentation (this feature)

```text
specs/010-lightweight-plan/
├── spec.md              # Feature specification (complete)
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── checklists/
    └── requirements.md  # Quality checklist (complete)
```

### Source Code (repository root)

```text
.claude/commands/
└── mykit.plan.md        # Main slash command file (to be updated)

.mykit/
├── state.json           # Workflow state (updated by command)
└── scripts/             # Helper scripts (if needed)
```

**Structure Decision**: Single command file pattern, consistent with `/mykit.specify`. No additional helper scripts required as all logic is embedded in the command markdown.

## Complexity Tracking

No violations requiring justification. Implementation uses the simplest approach:
- Single markdown command file (no shell scripts)
- Inline plan generation by AI (no external templates)
- State update via JSON file manipulation

---

## Design Decisions

### DD-001: Command File Structure

**Decision**: Mirror the structure of `/mykit.specify` with step-by-step implementation instructions in markdown.

**Rationale**: Consistency with existing commands ensures predictable behavior and easier maintenance. The `/mykit.specify` pattern is proven and well-documented.

**Alternatives Considered**:
- Shell script wrapper: Rejected (adds complexity, breaks AI skill pattern)
- External template file: Rejected per clarification (lightweight = inline generation)

### DD-002: Plan Output Format

**Decision**: Generate a simplified plan with three mandatory sections:
1. **Technical Context**: Technologies, dependencies, integration points
2. **Design Decisions**: Key architectural choices with rationale
3. **Implementation Phases**: Ordered steps to implement the feature

**Rationale**: These three sections provide sufficient guidance for implementation without the overhead of the full `/speckit.plan` workflow (research.md, data-model.md, contracts/).

**Format**:
```markdown
# Implementation Plan: {feature-name}

**Branch**: `{branch}` | **Created**: {date} | **Spec**: [spec.md](./spec.md)

## Technical Context

- **Technologies**: {list from spec or guided conversation}
- **Dependencies**: {external dependencies}
- **Integration Points**: {what this feature connects to}

## Design Decisions

### {Decision Title}

**Choice**: {what was decided}
**Rationale**: {why this choice}

## Implementation Phases

### Phase 1: {phase-title}

{description and key tasks}

### Phase 2: {phase-title}

{description and key tasks}
```

### DD-003: Guided Conversation Flow

**Decision**: Ask 0-5 technical questions based on spec analysis, focusing on:
1. Technology stack choices (if not obvious from codebase)
2. Integration approach (if external services mentioned)
3. Data persistence strategy (if data entities present)
4. Testing approach (if not specified)

**Rationale**: Questions are only asked when the spec contains ambiguity that affects the plan. Simple features may require no questions.

**Question Format**:
```markdown
**Plan Question {N}**: {topic}

{context from spec}

| Option | Description |
|--------|-------------|
| A | {option} |
| B | {option} |
| C | {option} |

Reply with option letter or provide your own answer.
```

### DD-004: State Management

**Decision**: Update `.mykit/state.json` with:
- `workflow_step`: "planning"
- `plan_path`: path to generated plan.md
- `last_command`: "/mykit.plan"
- `last_command_time`: ISO timestamp

**Rationale**: Enables `/mykit.status` and `/mykit.resume` to track workflow progress.

### DD-005: Mutual Exclusivity Check

**Decision**: Before generating, check for `/speckit.plan` artifacts:
- If `research.md`, `data-model.md`, or `contracts/` exist in specs dir → ERROR
- Error message directs user to continue with speckit workflow

**Rationale**: Per clarification, only one planning workflow per feature.

---

## Implementation Phases

### Phase 1: Prerequisites and Validation

**Objective**: Ensure all preconditions are met before plan generation.

**Tasks**:
1. Verify git repository exists
2. Extract branch name and validate feature branch pattern
3. Check for spec file at `specs/{branch}/spec.md`
4. Check for conflicting `/speckit.plan` artifacts
5. Handle `--force` flag for existing plan overwrite
6. Parse command arguments (create, --force)

**Error Messages**:
| Condition | Message |
|-----------|---------|
| Not in git repo | "Not in a git repository. Run `git init` to initialize." |
| Not on feature branch | "No feature branch detected. Use `/mykit.backlog select` first." |
| No spec file | "No specification found. Run `/mykit.specify create` first." |
| Speckit artifacts exist | "This feature uses /speckit.plan workflow. Continue with `/speckit.tasks` instead." |

### Phase 2: Spec Analysis and Question Generation

**Objective**: Analyze the spec and identify technical decisions needed.

**Tasks**:
1. Read and parse the spec file
2. Extract functional requirements, success criteria, and entities
3. Identify technology choices (explicit or implied)
4. Generate 0-5 questions for ambiguous technical decisions
5. Present questions sequentially using AskUserQuestion tool
6. Record answers for plan generation

**Question Categories**:
- Stack/technology choices
- Integration patterns
- Data persistence
- Testing strategy
- Performance approach

### Phase 3: Plan Generation

**Objective**: Generate the plan content based on spec and answers.

**Tasks**:
1. Format header with branch, date, spec link
2. Generate Technical Context from spec + answers
3. Generate Design Decisions with rationale
4. Generate Implementation Phases with ordered tasks
5. Include success criteria references

### Phase 4: Preview or Execute

**Objective**: Display preview or write file based on action.

**Preview Mode** (no action):
1. Display plan content with preview header
2. Show "No files created" note
3. Suggest `/mykit.plan create` to save

**Execute Mode** (`create` action):
1. Write plan to `specs/{branch}/plan.md`
2. Update `.mykit/state.json`
3. Display success message with file path
4. Suggest next command: `/mykit.tasks generate`

---

## Success Criteria Mapping

| Spec Criterion | Implementation Verification |
|----------------|----------------------------|
| SC-001: Under 2 minutes | Max 5 questions, streamlined flow |
| SC-002: Three sections present | Plan template enforces all three |
| SC-003: 90% first-attempt success | Clear error messages, guided flow |
| SC-004: Actionable error messages | Error table with specific commands |
| SC-005: Preview matches execute | Same generation logic for both modes |
| SC-006: Relevant questions | Questions derived from spec content |
