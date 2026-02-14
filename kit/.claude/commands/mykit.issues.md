---
description: Invoke the mykit-issues skill to analyze GitHub issues (no args = triage, number = deep-dive, audit/bulk/all = bulk review).
---

Invoke the mykit-issues skill to handle **issue analysis**.

User arguments: $ARGUMENTS

Routing hint:
- No arguments → triage open issues
- Numeric argument (e.g., `42`, `#42`) → deep-dive on that issue
- Keyword (`audit`, `bulk`, `all`) → bulk review all issues

Follow the mykit-issues skill's routing logic and workflow instructions.
