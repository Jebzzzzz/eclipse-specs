# INBOX

**Purpose:** This inbox is the intake for new lessons, incidents, and process notes before they are promoted into the numbered skills files.

**Confidence note:** Verified against the workspace on 2026-11-20. Resolved bootstrap notes from 2026-11-17 were triaged and removed.

## Current intake

### Empty application repos are not implementation

- **Type / Author / Date:** Risk note / repo bootstrap / 2026-11-17 (reverified 2026-11-20)
- **What:** [eclipse-api](../../eclipse-api), [eclipse-web](../../eclipse-web), and [eclipse-android](../../eclipse-android) contain only `AGENTS.md` and no committed runtime code yet, even though `eclipse-specs` now contains approved Business Logic v1.1 and `db-schema/v1.0.0.sql`.
- **Why:** Without verified runtime code, engineers must treat `skills/` and `README.md` as spec-level guidance until migrations, Edge Functions, and PWA code land.
- **Evidence:** Workspace directory listing on 2026-11-20.

### The skills set must stay grounded in code, not intent

- **Type / Author / Date:** Methodology / engineering practice / 2026-11-17 (reverified 2026-11-20)
- **What:** Once implementation starts in `eclipse-api` and `eclipse-web`, refresh `03_CODE_STYLE`, `04_CHANGE_RULES`, `05_DEBUGGING_PLAYBOOK`, `09_SECURITY`, `10_DEPLOYMENT`, `11_TESTING`, and `14_DEVELOPER_WORKFLOWS` against actual code, scripts, and configs.
- **Why:** The code wins. Any rule not matched by real implementation should be treated as a proposal rather than a fact.
- **Evidence:** Policy in [handoff.md](../../handoff.md).

## Contribution template

```markdown
### <summary>

- **Type / Author / Date:**
- **What:**
- **Why:** what improves, or what breaks without it.
- **Evidence:** files, commits, PRs, or the incident.
```

## Triage rule

When an inbox item is verified against code, merge it into the relevant numbered document and remove it from here. If it cannot be verified yet, keep it as an unverified note and label it clearly.
