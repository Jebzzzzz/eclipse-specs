# 01 — Architecture

**Purpose:** This document describes the approved MVP architecture of the Eclipse (OJT Chronicle) ecosystem and the boundaries between `eclipse-specs`, `eclipse-api` (Supabase), `eclipse-web` (React + Vite PWA), and `eclipse-android` (reserved, post-MVP).

**Confidence note:** Verified against `README.md`, `business-logic-v1.1-proposed.md` (approved MVP baseline), and `db-schema/v1.0.0.sql` on 2026-11-20. Application repos are still scaffolds without runtime code.

## One-paragraph model

Eclipse (OJT Chronicle) is a single-user, student-first Progressive Web App backed by **Supabase** (PostgreSQL with Row Level Security, Supabase Auth with Google OAuth + email/password, private Supabase Storage `evidence` bucket, and Deno/TypeScript Edge Functions). There is no separate custom API server: `eclipse-web` communicates with Supabase via the typed browser client for ordinary RLS-protected CRUD and calls Supabase Edge Functions for privileged operations (`enhance-description`, `delete-attachment`, `delete-entry`, `delete-account`). Report-ready DOCX export runs entirely in the browser using short-lived signed URLs for private screenshots. `eclipse-android` is reserved and out of scope for the MVP.

## Components and ownership

| Component                                | Owns                                                                                      | Must not own                                            |
| ---------------------------------------- | ----------------------------------------------------------------------------------------- | ------------------------------------------------------- |
| [eclipse-specs](../)                     | Approved requirements, schema baseline (`db-schema/v1.0.0.sql`), contracts, git & skills  | Runtime code or app state                               |
| [eclipse-api](../../eclipse-api)         | Supabase migrations, RLS & Storage policies, Auth config, Edge Functions, pgTAP tests     | Frontend UI or browser DOCX rendering                   |
| [eclipse-web](../../eclipse-web)         | React + Vite PWA UI, client-side validation, image compression/EXIF strip, DOCX export    | Service-role keys, OpenAI keys, or authoritative authz  |
| [eclipse-android](../../eclipse-android) | Reserved for future native Android client (out of scope for MVP)                          | Any implementation until scope is formally approved     |

## End-to-end data flow

1. Student authenticates via Supabase Auth (Google Sign-In or email/password with verification); `handle_new_user` trigger creates `profiles`.
2. For standard CRUD (`profiles`, `ojt_profiles`, `entry_categories`, `work_entries`, `entry_attachments`, `user` rows in `entry_revisions`), `eclipse-web` calls Supabase PostgREST through feature service modules, protected by PostgreSQL RLS (`auth.uid()`).
3. For screenshot uploads, `eclipse-web` compresses/strips EXIF client-side and uploads to the private `evidence` Storage bucket under `{user_uuid}/{entry_uuid}/{attachment_uuid}.{ext}`, then inserts metadata into `entry_attachments`.
4. For AI writing assistance, `eclipse-web` calls `enhance-description` with `entry_uuid`, `style`, and idempotency `request_id`; the Edge Function verifies JWT, ownership, AI consent, and `ai_usage` daily rate limits, calls OpenAI server-side, writes an `ai` revision, and logs `ai_usage`.
5. For permanent deletions, `eclipse-web` calls `delete-attachment`, `delete-entry`, or `delete-account`, which use `service_role` (after verifying caller JWT and ownership) to delete private Storage objects and all corresponding database rows.
6. For DOCX export, `eclipse-web` queries selected entries, fetches private images via short-lived signed URLs, and builds the `.docx` in the browser.

## Hard boundaries

- **RLS and Storage policies are the authorization boundary** — never rely on frontend filters or disable RLS.
- **No direct client `DELETE`** on domain tables or private Storage objects; permanent deletes go through Edge Functions.
- **No browser calls to OpenAI** — all AI requests run through `enhance-description` with server-side secrets.
- **Original text is immutable** — `entry_revisions.original_text` is protected by a database trigger, and clients can only insert `source = 'user'` revisions.

## Decision records

### Decision: Student-first MVP on Supabase + React PWA (2026-11-20)

**Status:** accepted
**Context / Choice / Alternatives / Consequences:** Multi-role portals and a custom backend would slow time-to-market. Chose a single-user student PWA (`eclipse-web`) on Supabase (`eclipse-api`), deferring reviewer/admin portals, manuscript builder, and `eclipse-android`. Consequence: faster MVP delivery, with offline-first UUID schema conventions preserved in `v1.0.0.sql` for future sync.

## Ranked debt register

1. Application repos (`eclipse-api`, `eclipse-web`) have no committed source code, migrations, or CI yet.
2. Edge Function request/response JSON schemas need concrete payload specs once `eclipse-api` implementation begins.
3. Hosting provider, SMTP provider, and AI budget/model selection remain TBD.
