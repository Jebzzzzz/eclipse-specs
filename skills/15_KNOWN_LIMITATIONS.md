# 15 — Known Limitations

**Purpose:** This document captures the gaps that are likely to surprise a new contributor or reviewer. It is sorted by impact and likelihood so the team knows what deserves attention first.

**Confidence note:** Verified against the repo scaffold on 2026-11-17. This is a limitation register grounded in the actual workspace state: there is no visible app implementation, no deployment configuration, and no data model yet.

## Ranked limitations

1. No application code is currently checked in to the API, web, or Android repos.
2. No runtime configuration, build steps, or deployment manifests are present.
3. Product requirements remain placeholders instead of verified business rules.
4. No real database schema or migration history is available.
5. No auth, security policy, or credential handling has been implemented or reviewed.
6. No actual test suite or smoke coverage has been created yet.
7. No production incident history or operational telemetry is available to validate assumptions.

## Redesign candidates

- Convert the current placeholder repo into a rigorously defined product architecture once the actual app code lands.
- Replace generic spec templates with real user stories and acceptance criteria.
- Add environment and deployment policy documents once app repos contain actual build output.
- Establish a real data model and migration strategy before feature work grows.

## Risk statement

The project currently has the shape of a multi-repo system but not the implementation evidence to support the expected operation. Treat the current documents as scaffolding for discipline until they are replaced by reality.
