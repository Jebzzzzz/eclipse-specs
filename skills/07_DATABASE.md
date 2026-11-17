# 07 — Database

**Purpose:** This document defines the database guardrails the team should follow when the service layer becomes real. It provides the default assumptions for identity, schema evolution, and data integrity before production data exists.

**Confidence note:** Verified against the current repo scaffold on 2026-11-17. No database or migration code exists yet, so this is a design baseline rather than a verified schema.

## Identity strategy

- Use stable, opaque identifiers for rows and user records instead of mutable business keys.
- Keep the system’s identity semantics consistent across the API, web app, and Android app.
- Never rely on a UI-only identifier as the source of truth for persistence.

## Constraints and invariants

- All persisted data should have a clear owner and lifecycle.
- Nullability rules should be explicit; do not hide missing data behind application assumptions.
- Enforce uniqueness and referential integrity at the database boundary for anything critical to the business.
- Treat deletes as a lifecycle event, not as a free-form cleanup mechanism.

## Table map

| Area                      | Expected treatment                                            |
| ------------------------- | ------------------------------------------------------------- |
| Users and auth            | Store principal identity, auth metadata, and role assignments |
| Application records       | Store domain state with created/updated timestamps            |
| Audit or operational logs | Store only minimal structured records necessary for debugging |
| Migrations                | Versioned and reviewable in the API repo                      |

## Migration strategy

- Create forward-only changes that can be reasoned about in sequence.
- Add migration notes to the specs or API change documentation when schema semantics change.
- Backfill and cleanup actions should be explicit and auditable.
- Do not rely on application code to silently repair inconsistent data.

## Dangerous operations

- Drop or rename columns without a compat plan.
- Delete high-value data without a retention policy or backup route.
- Changing identity semantics after data is live.
- Bypassing validation and business rules with raw SQL.

## Indexing guidance

- Add indexes only where access patterns demand them.
- Measure the cost of indexing before broad rollout.
- Do not treat every query as a candidate for indexing without evidence.

This document will become concrete when the actual schema and migrations are added to the API repo.
