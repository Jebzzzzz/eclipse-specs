# 11 — Testing

**Purpose:** This document establishes the minimum confidence model for the Eclipse ecosystem. It explains what must be tested, what to avoid, and how to gain confidence without pretending that a feature is validated when the code is not there.

**Confidence note:** Verified against the current repo scaffold on 2026-11-17. No app tests or code exist yet, so this is a test policy for future implementation rather than a record of current automated coverage.

## Honest coverage

- A repo with no tests is not a validated system.
- A code path with no smoke test has no proven runtime behavior.
- A UI-only feature is not complete until the API contract and server-side validation are also verified.

## Minimum required test coverage

| Area        | Must be tested                                              |
| ----------- | ----------------------------------------------------------- |
| Auth        | sign-in flow, token expiration, unauthorized access         |
| API         | request validation, error mapping, persistence interactions |
| Web app     | navigation, form validation, route guard behavior           |
| Android app | auth state, API error handling, offline-safe behavior       |
| Release     | smoke test across environments                              |

## Mocking rules

- Mock the boundary, not the behavior you want to prove.
- Avoid tests that only assert a mock was called instead of verifying a user-visible outcome.
- Use real inputs and contract-shaped data when possible.

## Manual drills

- Run a full sign-in and sign-out flow.
- Validate a create-read-update-delete cycle for a core domain object.
- Confirm that the same flow works from both the web and Android clients.
- Test a failure path, not just the happy path.

## Dimensions that break

- Contract drift between the API and clients
- Role and permission mismatches
- Environment differences between local and deployed config
- Missing migration or data backfill coverage

This file becomes precise only after the actual app repos contain tests and runtime logic.
