# Research: Lightweight Spec Command

**Branch**: `009-lightweight-spec` | **Date**: 2025-12-07

## Research Tasks

This research resolves implementation questions and documents best practices for the `/mykit.specify` command.

---

### 1. GitHub Issue Content Extraction

**Task**: Determine the best approach to extract structured content from GitHub issue bodies.

**Decision**: Use `gh issue view` with `--json` flag for structured access

**Rationale**:
- The `gh issue view {number} --json body,title` command returns clean JSON
- Avoids parsing HTML or dealing with GitHub's rendered markdown
- Already used successfully in `/mykit.status` for issue metadata
- Non-blocking on failure (command can fall back to guided conversation)

**Alternatives Considered**:
- GitHub REST API via curl: More complex, requires auth token management
- Scraping issue page: Fragile, HTML parsing issues
- GraphQL API: Overkill for single-issue queries

**Implementation Pattern**:
```bash
# Attempt to get issue body
ISSUE_DATA=$(gh issue view "$ISSUE_NUMBER" --json body,title 2>/dev/null)

if [ $? -eq 0 ]; then
  BODY=$(echo "$ISSUE_DATA" | jq -r '.body // ""')
  if [ ${#BODY} -ge 50 ]; then
    # Extract sections from body
  fi
fi
```

---

### 2. Markdown Section Extraction

**Task**: Define the algorithm for extracting Summary, Problem, and Acceptance Criteria from issue body.

**Decision**: Pattern-based extraction using markdown heading detection

**Rationale**:
- GitHub issues commonly use `## Heading` format
- Simple regex patterns handle most cases
- Graceful degradation: if sections not found, use entire body as context

**Extraction Rules**:
1. Look for headings: `## Summary`, `## Problem`, `## Description`, `## Acceptance Criteria`
2. Extract content between heading and next heading (or EOF)
3. If no headings found but body >= 50 chars, use full body as Summary
4. Map common variations:
   - "Description" → Summary
   - "What" / "Overview" → Summary
   - "Why" / "Motivation" → Problem
   - "Criteria" / "Done when" / "Checklist" → Acceptance Criteria

**Alternatives Considered**:
- AI-based extraction: Adds latency, not needed for structured content
- Strict template enforcement: Too rigid, breaks for informal issues

---

### 3. Guided Conversation Flow

**Task**: Best practices for multi-step conversation using Claude Code tools.

**Decision**: Use `AskUserQuestion` tool with single question per step

**Rationale**:
- Matches pattern used in `/mykit.start`
- Each question waits for response before proceeding
- Allows context-aware follow-up based on previous answers
- Simple implementation with clear state transitions

**Conversation Structure**:
1. Question 1: "What is this feature/change about?" → maps to Summary
2. Question 2: "What problem does it solve?" → maps to Problem
3. Question 3: "What should be true when done? (Enter criteria as bullet points)" → maps to Acceptance Criteria

**Tool Usage Pattern**:
```
Use AskUserQuestion tool with:
- header: "Spec: Summary"
- question: "What is this feature/change about?"
- options: [] (free-form text response)
```

**Alternatives Considered**:
- Single multi-field form: Not supported by AskUserQuestion
- Batch all questions upfront: Loses conversational guidance value

---

### 4. State Persistence Strategy

**Task**: How to persist session progress for recovery via `/mykit.resume`.

**Decision**: Update `.mykit/state.json` with spec creation progress

**Rationale**:
- State file already exists and is used by other commands
- Simple JSON structure allows easy partial updates
- Matches existing state management pattern

**State Fields to Update**:
```json
{
  "current_feature": {
    "issue_number": 42,
    "branch": "042-feature-name",
    "spec_path": "specs/042-feature-name/spec.md"
  },
  "workflow_step": "specification",
  "last_command": "/mykit.specify",
  "last_command_time": "2025-12-07T..."
}
```

**Partial Progress Tracking**:
- During guided conversation: Store answers in memory only
- On successful spec creation: Write to state.json
- On interruption: Answers are lost (acceptable for 3-question flow)

**Alternatives Considered**:
- Draft file for partial progress: Over-engineered for 3 questions
- Session storage: Not available in Claude Code context

---

### 5. Preview Mode Implementation

**Task**: How to implement preview without writing files.

**Decision**: Display formatted spec content to stdout without file writes

**Rationale**:
- Simple: just show what would be written
- Follows explicit execution principle (R6)
- User can review before committing with `create` action

**Implementation**:
1. Extract/gather content same as execution mode
2. Format using lite spec template structure
3. Display with clear "PREVIEW" header
4. Instruct: "Run `/mykit.specify create` to save this spec"

**Alternatives Considered**:
- Write to temp file: Leaves artifacts, cleanup complexity
- Diff view: No existing file to diff against for new specs

---

### 6. Existing File Handling

**Task**: Best practice for handling spec file overwrites.

**Decision**: Prompt with 3 options: Overwrite, Merge, Cancel

**Rationale**:
- Prevents accidental data loss
- Merge option preserves existing clarifications/customizations
- Cancel is safe default
- `--force` flag bypasses for automation

**Options Presented**:
1. **Overwrite**: Replace existing spec entirely
2. **Merge**: Keep existing content, add/update extracted sections
3. **Cancel**: Abort operation

**Merge Strategy**:
- Preserve existing Clarifications section
- Preserve custom sections (anything not in template)
- Update Summary, Problem, Acceptance Criteria only

**Alternatives Considered**:
- Backup before overwrite: Adds complexity, backup management
- Version suffixes (spec.v2.md): Confusing file proliferation

---

## Summary

| Area | Decision | Confidence |
|------|----------|------------|
| Issue extraction | `gh issue view --json` | High |
| Markdown parsing | Pattern-based heading detection | High |
| Conversation | Sequential AskUserQuestion | High |
| State persistence | Update .mykit/state.json | High |
| Preview mode | Display without file write | High |
| File conflicts | Prompt: Overwrite/Merge/Cancel | High |

All decisions align with existing My Kit patterns and the Constitution principles. No blocking unknowns remain.
