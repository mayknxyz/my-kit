# Audit Subagent: Accessibility

Analyze the codebase for accessibility issues in UI code using AI-driven review, then write a structured audit report.

## Inputs

You will receive these variables from the orchestrator:
- `REPO_ROOT`: Absolute path to the repository root
- `REPORT_PATH`: Absolute path where the report should be written (e.g., `specs/{branch}/audit/a11y.md`)

## Execution

### 1. Discover UI Code

Search the repository for UI-related files:
- HTML files: `**/*.html`, `**/*.htm`
- React/JSX: `**/*.jsx`, `**/*.tsx`
- Vue: `**/*.vue`
- Svelte: `**/*.svelte`
- Angular templates: `**/*.component.html`
- CSS/styling: `**/*.css`, `**/*.scss`, `**/*.sass`, `**/*.less`
- Template files: `**/*.ejs`, `**/*.hbs`, `**/*.pug`

Use Glob to search. If no UI files are found, also check for:
- CLI output formatting (terminal accessibility — color contrast, screen reader compatibility)
- Markdown documentation (structural accessibility — heading hierarchy, alt text in images, link text quality)

### 2. Analyze for Accessibility Issues

**If UI code exists**, check for:

**WCAG 2.1 Level A (Critical)**:
- Missing `alt` attributes on `<img>` tags
- Missing form `<label>` elements or `aria-label`/`aria-labelledby`
- Missing `lang` attribute on `<html>`
- Empty links or buttons (no accessible text)
- Missing document title
- Color used as the only visual means of conveying information

**WCAG 2.1 Level AA (Important)**:
- Missing ARIA landmarks (`<main>`, `<nav>`, `<header>`, `<footer>`)
- Missing `aria-live` regions for dynamic content
- Insufficient color contrast (check hardcoded color values)
- Missing keyboard navigation support (`tabIndex`, focus management)
- Missing skip navigation links
- Autoplaying media without controls

**Semantic HTML**:
- Using `<div>` or `<span>` for interactive elements instead of `<button>` or `<a>`
- Incorrect heading hierarchy (skipping levels)
- Missing list semantics for list-like content

**If no UI code exists**, check for:
- Markdown documents: heading hierarchy, alt text in images, descriptive link text
- CLI scripts: whether output relies solely on color (no text fallback)
- If nothing applicable, report "No UI code found — a11y checks not applicable" with status "passed"

### 3. Assess Severity

- **high**: WCAG Level A violation — prevents access for assistive technology users
- **medium**: WCAG Level AA violation — degrades experience for users with disabilities
- **low**: Best practice violation — improves usability but not a standards failure

### 4. Generate Proposed Fixes

For each finding:
- Show the current code
- Show the corrected code with the accessibility fix
- Reference the WCAG criterion where applicable

### 5. Write Report

Write the report to `{REPORT_PATH}` using this format:

```markdown
# Audit Report: Accessibility

**Domain**: a11y
**Date**: {YYYY-MM-DD}
**Tools**: AI analysis
**Status**: {passed|failed|not-applicable}

## Summary

- **Files analyzed**: {count}
- **Issues found**: {count}
- **Severity**: {none|low|medium|high}
- **WCAG Level A violations**: {count}
- **WCAG Level AA violations**: {count}

## Findings

### {Finding title, e.g., "Missing alt text on hero image"}

- **File**: {file path relative to repo root}
- **Line**: {line number}
- **Severity**: {low|medium|high}
- **WCAG Criterion**: {e.g., "1.1.1 Non-text Content" or "N/A"}
- **Description**: {what's wrong and who it affects}
- **Current Code**:
  ```html
  {problematic code snippet}
  ```
- **Proposed Fix**:
  ```html
  {corrected code snippet}
  ```

---

{Repeat for each finding. If no findings, write: "No accessibility issues found." or "No UI code found — a11y checks not applicable."}
```

## Return Value

Return a one-line summary: `"{status}: {issue_count} accessibility issues found in {files_analyzed} files"`
