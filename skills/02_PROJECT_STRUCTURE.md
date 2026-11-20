# 02 — Project Structure

**Purpose:** This document defines where code and specifications live in the Eclipse ecosystem and what belongs in each repository.

**Confidence note:** Verified against the workspace on 2026-11-20. Specification files and `db-schema/v1.0.0.sql` exist; `eclipse-api`, `eclipse-web`, and `eclipse-android` currently contain only `AGENTS.md`.

## Repository layout

```text
eclipse-ecosystem/
├─ AGENTS.md                           # Ecosystem-wide agent instructions
├─ README.md                           # Ecosystem specification & developer guide
├─ handoff.md                          # Skills generation & maintenance guide
├─ eclipse-specs/                      # Source of truth (docs & schema baseline only)
│  ├─ AGENTS.md
│  ├─ business-logic-v1.0.md           # Historical baseline (superseded for MVP)
│  ├─ business-logic-v1.1-proposed.md  # Approved MVP baseline (filename retained)
│  ├─ db-design-choices.md             # Offline-first DB conventions
│  ├─ db-schema/
│  │  └─ v1.0.0.sql                    # Authoritative idempotent MVP SQL baseline
│  ├─ git-guidelines.md                # Eclipse (ECL) commit & release-tag rules
│  ├─ sense-making.md                  # Environmental scanning instructions
│  ├─ planning/
│  │  └─ sense-making.csv
│  └─ skills/
│     ├─ 00_INDEX.md
│     ├─ INBOX.md
│     └─ 01..16_*.md
├─ eclipse-api/                        # Supabase project (migrations, RLS, Edge Functions)
│  └─ AGENTS.md                        # (scaffold; code pending)
├─ eclipse-web/                        # React + Vite PWA
│  └─ AGENTS.md                        # (scaffold; code pending)
└─ eclipse-android/                    # Reserved for future native Android (out of scope for MVP)
   └─ AGENTS.md
```

## Where new code goes

- Add SQL migrations, RLS/Storage policies, pgTAP tests, and Supabase Edge Functions (`enhance-description`, `delete-attachment`, `delete-entry`, `delete-account`) in [eclipse-api](../../eclipse-api).
- Add React + Vite PWA pages, feature modules, Supabase service wrappers, and browser DOCX export in [eclipse-web](../../eclipse-web).
- Add product requirements, schema baselines (`db-schema/v1.0.x.sql`), contracts, and skills updates in [eclipse-specs](../).
- Do **not** add code to [eclipse-android](../../eclipse-android) until native Android scope is formally approved.

## Must not go here

- Do not place application code or secrets in `eclipse-specs`.
- Do not place OpenAI keys, Supabase service-role keys, or authoritative authorization checks in `eclipse-web`.
- Do not scatter raw Supabase queries across presentational UI components; keep them in `eclipse-web/src/services/`.

## Naming conventions that matter

- PostgreSQL tables and columns: lowercase `snake_case`, plural table names, `*_uuid` for cross-table references.
- Edge Function folders: `kebab-case` (`enhance-description`, `delete-attachment`, `delete-entry`, `delete-account`).
- React components: `PascalCase`; hooks/utilities/variables: `camelCase`.
- Schema files in `eclipse-specs/db-schema/`: `v1.0.0.sql` baseline, patch bumps (`v1.0.1.sql`) for forward migrations, minor bumps (`v1.1.0.sql`) for full snapshots.
