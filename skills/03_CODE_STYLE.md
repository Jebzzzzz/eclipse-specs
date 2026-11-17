# 03 — Code Style

**Purpose:** This document captures the team’s coding conventions for readability, safety, and maintainability. It is designed to reduce the number of ambiguous decisions and to make hidden assumptions visible before they become outages.

**Confidence note:** Verified against the current repo scaffold on 2026-11-17. No implementation code is present, so this document records the default engineering standards expected once app code lands, rather than a production style guide for a live system.

## Comment philosophy

- Comments explain the why, not the what.
- If the code can be named clearly, do not add a comment just to restate it.
- Record assumptions, invariants, and edge cases that are easy to miss in a future refactor.
- Leave warnings near the line or logic they guard, and attach the cost of a wrong assumption.

## Naming rules

- Name variables and functions for behavior and domain, not for the implementation detail.
- Prefer explicit names over short ambiguous names.
- Keep API contract names, database fields, and UI labels aligned across repos.
- When a term means different things in different repos, document the mapping immediately.

## Error handling

- Fail loudly and early when a contract is violated.
- Surface user-facing errors without leaking secrets or internal stack traces.
- Return structured error responses from the API, not ad hoc text.
- Log the context that explains the failure, not just the exception string.

## Logging and observability

- Add logs at boundaries where state transitions happen.
- Log identifiers, operation names, and the relevant user or request context.
- Avoid logging secrets, tokens, or raw customer content.
- Prefer a consistent message pattern so a symptom can be searched and triaged quickly.

## Preferred patterns

- Keep business rules in the API where the canonical state can be enforced.
- Keep UI validation thin and user-friendly.
- Keep one source of truth for each important domain object or contract.
- Prefer small, typed functions with explicit inputs and outputs.

## Anti-patterns to avoid

- Re-implementing server-side validation in a client.
- Adding silent fallbacks that hide data loss or policy drift.
- Copying enums, field names, or status values across repos without a lockstep review.
- Writing comments that describe recent bugs without linking them to the actual fix or incident.

## Commit conventions

Use repository commit messages in the form described by the Git guidelines: `scope: Imperative summary` with a concise body explaining why the change exists. This is the team’s fastest way to keep architecture decisions and bug fixes visible without reading a full diff.

This document is intentionally generic until app code exists. When the real repositories are populated, tighten it to the repo-specific language and toolchain used there.
