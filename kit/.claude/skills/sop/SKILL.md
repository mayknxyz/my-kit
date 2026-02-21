---
name: sop
description: >
  Standard operating procedures — runbooks, checklists, escalation paths, repeatable processes.
  Use when creating operational procedures, deployment runbooks, incident response plans, or
  business process documentation. Triggers: SOP, standard operating procedure, runbook, checklist,
  playbook, incident response, escalation, deployment procedure, operations, process documentation.
---

# Standard Operating Procedures

Senior operations writer. Repeatable, verifiable steps. Zero ambiguity. See `docs` skill for general documentation, `diagrams` skill for process flowcharts, `ci-cd` skill for automated pipelines.

## Format Selection

| Format | Use For | Example |
|--------|---------|---------|
| Numbered checklist | Sequential ops/business processes | Deploy release, onboard new client |
| Incident runbook | Outage response with severity tiers | Site down, data breach, API failure |
| Escalation matrix | Contact routing by severity/domain | Who to call at 2 AM |

## 5 SOP Components

Every SOP must include:

1. **Purpose** — one sentence: what this procedure accomplishes
2. **Scope** — when this procedure applies (and when it doesn't)
3. **Prerequisites** — tools, access, permissions needed before starting
4. **Steps** — numbered, actionable, verifiable instructions
5. **Verification** — how to confirm the procedure succeeded

## Step Writing Rules

Each step must answer: "What do I do?" and "How do I know it worked?"

| Bad | Good | Why |
|-----|------|-----|
| "Check the database" | "Run `SELECT count(*) FROM users` — expect > 0" | Specific command + expected result |
| "Deploy the app" | "Run `wrangler pages deploy` — verify 'Success' in output" | Verifiable outcome |
| "Notify the team" | "Post in #ops-alerts: 'Deploy v{X.Y.Z} complete'" | Exact channel + message format |
| "Handle any errors" | "If deploy fails with exit code 1, run `wrangler pages deploy --retry`" | Conditional with specific action |

## References

| Topic | File | Load When |
|-------|------|-----------|
| SOP templates | [templates.md](references/templates.md) | Creating a new checklist, runbook, or escalation matrix |

## MUST DO

- Include all 5 components (purpose, scope, prerequisites, steps, verification)
- Make every step independently verifiable — include expected outputs
- Use exact commands, paths, and values — no placeholders the reader must guess
- Include rollback/undo steps for destructive operations
- Date and version every SOP — procedures drift from reality
- Test the procedure by following it literally before publishing

## MUST NOT

- Write vague steps ("ensure everything is working")
- Assume context — state the starting point explicitly
- Skip prerequisites — missing access derails procedures mid-execution
- Combine multiple actions in one step — one action, one verification
- Use jargon without defining it — SOPs are for the person at 2 AM
- Omit failure paths — every step that can fail needs a recovery action
