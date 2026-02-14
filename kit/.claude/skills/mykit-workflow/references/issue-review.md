<!-- Issue review workflow — loaded by specify step after GitHub issue extraction -->

## Issue Review

Review extracted issue details for completeness, flag gaps, and get user clarification before generating the spec.

### Inputs

Expects these variables from the extraction step:
- `issueTitle` — Issue title
- `issueNumber` — GitHub issue number
- `summary` — Extracted or empty
- `problem` — Extracted or empty
- `acceptanceCriteria` — Extracted or empty
- `contentSource` — `"issue"` or not yet set

### 1. Present Issue Summary

Display a concise review of what was extracted:

```
## Issue #{issueNumber}: {issueTitle}

**Summary**: {summary or "Missing"}
**Problem**: {problem or "Missing"}
**Acceptance Criteria**: {acceptanceCriteria or "Missing"}
```

### 2. Flag Gaps

Identify which sections are missing or vague. A section is **vague** if it:
- Is fewer than 20 characters
- Uses only generic language without specifics (e.g., "make it better", "fix the thing")
- Lacks measurable outcomes or concrete details

Build a list of `gaps[]` — each entry has a `field` name and `reason` (missing or vague).

### 3. Provide Recommendations

For each gap, generate a specific recommendation:

- **Missing summary**: Suggest a one-sentence summary based on the issue title and any available context
- **Missing problem**: Suggest what problem this likely solves based on summary/title
- **Missing acceptance criteria**: Suggest 2-4 concrete criteria based on the summary and problem
- **Vague sections**: Suggest a rewrite with more specific language

Display recommendations:

```
### Recommendations

- **{field}** ({reason}): {recommendation}
```

### 4. Ask for Clarification

Use `AskUserQuestion`:

- header: "Review"
- question: "Review the issue details above. Accept as-is, or clarify the flagged gaps?"
- options:
  1. label: "Accept", description: "Proceed with current details (recommendations will be used for missing sections)"
  2. label: "Clarify", description: "Provide additional details for flagged gaps"
  3. label: "Accept with recommendations", description: "Use the suggested recommendations to fill gaps"

**If "Accept"**: Continue with extracted values as-is. Empty sections will trigger guided conversation prompts.

**If "Accept with recommendations"**: Apply recommendations to fill missing/vague sections. Update `summary`, `problem`, `acceptanceCriteria` with recommended values. Set `contentSource = "issue+recommendations"`.

**If "Clarify"**: For each gap, prompt with `AskUserQuestion`:
- header: "Clarify: {field}"
- question: "{targeted question about the gap}"
- options:
  1. label: "Use recommendation", description: "{the recommendation for this field}"

The user can select the recommendation or provide custom input via "Other". Update the corresponding variable with the response.

After clarification, set `contentSource = "issue+clarified"`.

### 5. Output

Return updated variables: `summary`, `problem`, `acceptanceCriteria`, `contentSource`.
