---
name: mykit-ops
description: My Kit standalone utilities — handles code audits.
---

# My Kit Operations

Handles standalone utility operations: audit. Auto-activates when the user expresses intent to audit code quality, security, performance, accessibility, or dependencies.

## Trigger Keywords

- **audit**: "audit", "run audit", "code audit", "quality check", "security check", "check code quality"

## Step Identification

| Step | Keywords | Description |
|------|----------|-------------|
| `audit` | audit, quality check, security check | Run comprehensive audit (quality, security, perf, a11y, deps) |

## Routing Logic

### 1. Identify Step

Map user intent to: `audit`.

### 2. Load Reference File

| Step | Reference |
|------|-----------|
| audit | `references/audit.md` |

**Load only the one reference file needed per invocation.**

### 3. Execute Reference Instructions

Follow the loaded reference file's instructions exactly. Each reference contains the complete workflow:

- **audit.md**: 5-domain parallel audit (quality, security, performance, accessibility, dependencies) using dedicated agents, aggregated scoring, and actionable recommendations

## Reference Files

- `references/audit.md` — Comprehensive multi-domain audit workflow
