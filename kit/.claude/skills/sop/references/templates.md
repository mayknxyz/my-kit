# SOP Templates Reference

Three boilerplate templates. Copy, fill in, delete unused sections.

## Template 1: Numbered Checklist (Ops + Business)

For sequential processes with clear start and end. Suitable for deployments, onboarding, audits, and recurring operations.

```markdown
# {Procedure Name}

**Version**: 1.0 | **Last Updated**: YYYY-MM-DD | **Owner**: {team/person}

## Purpose

{One sentence: what this procedure accomplishes and why it matters.}

## Scope

- **Applies to**: {when/where this procedure is used}
- **Does not apply to**: {exclusions — what this doesn't cover}

## Prerequisites

- [ ] {Tool or access requirement}
- [ ] {Permission or credential}
- [ ] {Environmental condition}

## Steps

### 1. {First Action}

{Specific command or action.}

**Expected result**: {What you should see/verify.}

### 2. {Second Action}

{Specific command or action.}

**Expected result**: {What you should see/verify.}

### 3. {Third Action}

{Specific command or action.}

**Expected result**: {What you should see/verify.}

## Verification

- [ ] {Final check that confirms the procedure succeeded}
- [ ] {Second verification if applicable}

## Rollback

If the procedure fails at any step:

1. {Undo action for the most recent completed step}
2. {Continue undoing in reverse order}
3. {Notify relevant parties}
```

## Template 2: Incident Runbook

For outage response with severity classification, diagnostic branching, and rollback procedures.

```markdown
# {Incident Type} Runbook

**Version**: 1.0 | **Last Updated**: YYYY-MM-DD | **Owner**: {team/person}

## Purpose

{One sentence: what incident this runbook addresses.}

## Scope

- **Applies to**: {incident types and systems this runbook covers}
- **Does not apply to**: {exclusions — e.g., scheduled maintenance, non-production}

## Severity Classification

| Severity | Criteria | Response Time | Escalation |
|----------|----------|---------------|------------|
| P1 — Critical | {Full outage, data loss} | Immediate | {VP Engineering} |
| P2 — High | {Degraded service, partial outage} | 30 min | {Team Lead} |
| P3 — Medium | {Minor impact, workaround exists} | 4 hours | {On-call engineer} |
| P4 — Low | {Cosmetic, no user impact} | Next business day | {Ticket queue} |

## Prerequisites

- [ ] Access to {monitoring dashboard URL}
- [ ] CLI access: `wrangler`, `gh`
- [ ] Permissions: {required roles/access}

## Diagnosis

### 1. Assess Impact

{Command to check service status.}

```bash
{diagnostic command}
```

- **If {condition A}**: go to [Scenario A](#scenario-a)
- **If {condition B}**: go to [Scenario B](#scenario-b)
- **If unknown**: escalate to {contact}

### Scenario A: {Description}

1. {Diagnostic step with command}
   **Expected**: {what indicates this scenario}

2. {Fix action}
   **Expected**: {what recovery looks like}

3. {Verification}
   **Expected**: {what confirms resolution}

### Scenario B: {Description}

1. {Diagnostic step with command}
2. {Fix action}
3. {Verification}

## Rollback

1. {Revert to last known good state}
   ```bash
   {rollback command}
   ```
2. {Verify rollback succeeded}
3. {Notify stakeholders}

## Verification

- [ ] {Service is responding with 200 status}
- [ ] {Monitoring dashboard shows normal metrics}
- [ ] {No new error alerts for 15 minutes}

## Post-Incident

- [ ] Write incident report within 24 hours
- [ ] Identify root cause
- [ ] Create follow-up issues for preventive measures
- [ ] Update this runbook if procedure changed
```

## Template 3: Escalation Matrix

For routing contacts by severity, domain, and time. Combine the contact table with card templates for each role.

```markdown
# Escalation Matrix

**Version**: 1.0 | **Last Updated**: YYYY-MM-DD | **Owner**: {team/person}

## Purpose

{One sentence: defines who to contact, when, and how for operational issues.}

## Scope

- **Applies to**: {incident response, on-call escalation, outage communication}
- **Does not apply to**: {routine support requests — use ticket queue}

## Contact Table

| Domain | P1 (Critical) | P2 (High) | P3 (Medium) | P4 (Low) |
|--------|---------------|-----------|-------------|----------|
| Infrastructure | {Name} | {Name} | {Name} | Ticket |
| Application | {Name} | {Name} | {Name} | Ticket |
| Database | {Name} | {Name} | {Name} | Ticket |
| Security | {Name} | {Name} | {Name} | Ticket |
| Business/Client | {Name} | {Name} | {Name} | Ticket |

## Escalation Rules

1. **First response**: Contact the P-level owner for the relevant domain
2. **No response in {X} minutes**: Escalate to the next severity column
3. **Cross-domain issues**: Contact owners for all affected domains
4. **After hours**: Follow the on-call schedule below

## On-Call Schedule

| Week | Primary | Secondary |
|------|---------|-----------|
| {Date range} | {Name} | {Name} |
| {Date range} | {Name} | {Name} |

## Contact Cards

### {Person Name}

- **Role**: {Title}
- **Domain**: {Area of expertise}
- **Phone**: {Number}
- **Slack**: @{handle}
- **Available**: {Hours/timezone}
- **Escalate to**: {Next person in chain}

### {Person Name}

- **Role**: {Title}
- **Domain**: {Area of expertise}
- **Phone**: {Number}
- **Slack**: @{handle}
- **Available**: {Hours/timezone}
- **Escalate to**: {Next person in chain}

## Communication Templates

### Initial Notification

> **[P{N}] {Incident type}** — {One-line description}
> **Impact**: {Who/what is affected}
> **Status**: Investigating
> **Lead**: {Name}
> **Channel**: #{incident-channel}

### Resolution Notification

> **[RESOLVED] {Incident type}** — {One-line description}
> **Duration**: {Start time} — {End time} ({total duration})
> **Root cause**: {Brief description}
> **Follow-up**: {Link to incident report or issues}
```
