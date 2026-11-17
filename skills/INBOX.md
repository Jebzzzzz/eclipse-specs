# INBOX

**Purpose:** This inbox is the intake for new lessons, incidents, and process notes before they are promoted into the numbered skills files.

**Confidence note:** Verified against the repo scaffold on 2026-11-17. The current project contains only empty application repositories and placeholder specs, so this inbox is intentionally a starting list of risks and expectations rather than operational history.

## Current intake

### Empty application repos are not implementation

- **Type / Author / Date:** Risk note / repo bootstrap / 2026-11-17
- **What:** The [eclipse-api](../eclipse-api), [eclipse-web](../eclipse-web), and [eclipse-android](../eclipse-android) repositories exist but contain no application source files or tracked commits.
- **Why:** Without a verified implementation, engineers can easily assume the project is further along than it is, which creates false confidence and stale architecture assumptions.
- **Evidence:** Directory listings and Git status from the repos; each one is a Git repo with no commits and no app code.

### Project detail placeholders need real product facts

- **Type / Author / Date:** Design note / repo spec / 2026-11-17
- **What:** The business logic template still contains placeholders such as `<Platform>`, `<App/Software Type>`, and `<Team Name>`.
- **Why:** Product-level assumptions affect security, auth, user roles, and release plans; placeholders leave the system architecture under-specified.
- **Evidence:** [eclipse-specs/business-logic-v1.0.md](../business-logic-v1.0.md)

### The skills set must stay grounded in code, not intent

- **Type / Author / Date:** Methodology / engineering practice / 2026-11-17
- **What:** This folder captures the expected operating model for the ecosystem, but it is explicitly marked as scaffold-level guidance until code lands.
- **Why:** The code wins. Any rule not matched by real implementation should be treated as a proposal rather than a fact.
- **Evidence:** This repository snapshot, the handoff instructions, and the policy in [handoff.md](../../handoff.md)

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
