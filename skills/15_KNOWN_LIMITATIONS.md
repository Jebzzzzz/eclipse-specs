# 15 — Known Limitations

**Purpose:** This document captures current gaps, deferred capabilities, and architectural constraints likely to surprise a contributor or reviewer.

**Confidence note:** Verified against the workspace on 2026-11-20.

## Ranked limitations

1. **No application code committed yet:** `eclipse-api`, `eclipse-web`, and `eclipse-android` currently contain only `AGENTS.md`. Migrations, Edge Functions, React PWA source, and tests are not yet implemented.
2. **Offline sync is deferred, though the schema prepares for it:** `v1.0.0.sql` uses offline-first UUID/soft-delete conventions (`db-design-choices.md`), but the MVP web app is online-first with PWA app-shell caching only. Offline drafts and upload queues are a later phase.
3. **No DB-level `ON DELETE CASCADE` on domain tables:** By design (`db-design-choices.md`), domain tables omit `REFERENCES`. Edge Functions (`delete-attachment`, `delete-entry`, `delete-account`) must explicitly delete child rows, and reads must tolerate missing optional parents.
4. **Images only for MVP evidence:** `v1.0.0.sql` and `evidence` Storage bucket restrict uploads to `image/jpeg`, `image/png`, and `image/webp` (5 MB max). PDFs and other document types are not supported in the MVP.
5. **Single-user scope only in MVP:** Supervisor, Faculty Reviewer, and Admin portals (from historical `v1.0`) and the Manuscript section builder are deferred to post-MVP.
6. **Unfinalized operational/legal choices:** Hosting provider, production SMTP, OpenAI model/budget, Google OAuth project ownership, and final software license remain TBD (tracked in `README.md` §18).

## Redesign / future-phase candidates

- Implement `eclipse-api` migrations (from `v1.0.0.sql`), Edge Functions, and pgTAP tests first, then generate `database.types.ts` for `eclipse-web`.
- Add later-phase manuscript tables (`manuscript_sections`, `manuscript_section_entries`, `work_entries.approved_for_manuscript`) via forward migrations (`v1.0.1+`).
- Add a periodic Storage orphan-reconciliation job if partial failures occur during uploads or deletions.
