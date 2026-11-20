# 07 — Database

**Purpose:** This document defines the database identity strategy, integrity invariants, security grants, and migration rules for Eclipse / OJT Chronicle.

**Confidence note:** Verified against `eclipse-specs/db-schema/v1.0.0.sql` and `eclipse-specs/db-design-choices.md` on 2026-11-20. No migrations are committed in `eclipse-api` yet.

## Identity strategy

Follow [db-design-choices.md](../db-design-choices.md):
- **Server-only surrogate PK:** Every public table has `id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY` strictly for B-tree locality and server arrival order. Never expose, sync, or reference `id` in foreign keys.
- **Global UUID identity:** Every table has `uuid uuid NOT NULL UNIQUE`, and all cross-table links use `*_uuid` columns (`user_uuid`, `ojt_profile_uuid`, `category_uuid`, `entry_uuid`, `accepted_revision_uuid`, `revision_uuid`).
- **Omitted server `REFERENCES` on domain tables:** Only `profiles.uuid -> auth.users(id) ON DELETE CASCADE` is declared as a server FK. Omitting domain `REFERENCES` preserves compatibility with future offline-first out-of-order sync batches. *Miss → deleting a parent row in Postgres will NOT cascade to child tables; `delete-entry` and `delete-account` Edge Functions must explicitly delete all child rows.*

## Constraints and invariants

- **Attribution & soft delete:** Every table includes `created_by` (server-stamped from `auth.uid()` by trigger), `created_at`, `updated_at` (maintained by `set_updated_at` while preserving explicit client timestamps for LWW sync), and `archived_at`.
- **Live uniqueness:** Enforce uniqueness on live rows only using partial unique indexes (`WHERE archived_at IS NULL`).
- **Archive sync on `work_entries`:** `work_entries_archived_sync_check` enforces `(status = 'archived') = (archived_at IS NOT NULL)` so status and tombstone never drift.
- **Immutable original text:** `trg_entry_revisions_protect_original_text` raises an exception if `entry_revisions.original_text` is modified.
- **Closed vocabularies:** Use Postgres `ENUM`s (`work_entry_status`, `revision_source`, `revision_status`, `revision_review_decision`, `ai_enhancement_style`, `ai_usage_outcome`).
- **No direct client `DELETE`:** `DELETE` is revoked from `anon` and `authenticated` on all public tables and omitted from `evidence` Storage policies. Permanent deletion runs only via Edge Functions (`delete-attachment`, `delete-entry`, `delete-account`).
- **Revision source isolation:** RLS on `entry_revisions` restricts client `INSERT` to `source = 'user'`; AI revisions are inserted server-side by `enhance-description` using `service_role`.

## Table map (`v1.0.0.sql`)

| Table               | Purpose                                                               | Client privileges (RLS-gated)   |
| ------------------- | --------------------------------------------------------------------- | ------------------------------- |
| `profiles`          | Student profile, timezone, `ai_consent_at`, `upload_notice_ack_at`    | `SELECT, UPDATE` (own)          |
| `ojt_profiles`      | Host company, department, supervisor, dates, `required_hours`         | `SELECT, INSERT, UPDATE` (own)  |
| `entry_categories`  | System (`user_uuid IS NULL`) or custom student categories             | `SELECT` (sys+own), `INSERT, UPDATE` (own) |
| `work_entries`      | Daily activity logs, hours (0–24), `status`, `search_vector`          | `SELECT, INSERT, UPDATE` (own)  |
| `entry_attachments` | Screenshot metadata & private `evidence` Storage path                 | `SELECT, INSERT, UPDATE` (own)  |
| `entry_revisions`   | Append-only `user`/`ai` text versions, `review_decision`, `final_text`| `SELECT, INSERT (user), UPDATE` (own) |
| `ai_usage`          | Server-written AI request log (rate limits & token usage)             | `SELECT` (own) only             |
| `app_settings`      | Platform limits (`max_file_size_bytes`, `max_per_entry`, `requests_per_day`) | `SELECT` (live rows) only  |

**Private Storage bucket:** `evidence` (`public = false`, 5 MB limit, `image/jpeg`, `image/png`, `image/webp`), path `{user_uuid}/{entry_uuid}/{attachment_uuid}.{ext}`.

## Migration strategy

- Authoritative spec baseline lives in `eclipse-specs/db-schema/v1.0.0.sql`; executable migrations live in `eclipse-api/supabase/migrations/`.
- Keep changes additive and idempotent. Never edit an already-applied migration.
- After any schema change, regenerate `eclipse-web/src/types/database.types.ts` in the same change set. *Miss → web app compiles against stale types and fails at runtime.*
- Run `supabase db lint` and pgTAP RLS/Storage tests (`supabase test db`) before merging.

## Dangerous operations

- Relying on `ON DELETE CASCADE` for domain tables (will silently leave orphans).
- Disabling RLS or granting `DELETE` to `authenticated` as a shortcut.
- Mutating `entry_revisions.original_text` or bypassing `app_settings` / Storage MIME checks.
