# 08 — API

**Purpose:** This document defines the backend API surface and conventions for Eclipse / OJT Chronicle (`eclipse-api`), covering Supabase PostgREST CRUD and Supabase Edge Functions.

**Confidence note:** Verified against `README.md` and `eclipse-specs/db-schema/v1.0.0.sql` on 2026-11-20. Edge Functions are not yet implemented in `eclipse-api`.

## Backend Architecture (No Custom REST Server)

- **Ordinary CRUD:** Handled via Supabase's generated PostgREST API through typed service modules in `eclipse-web/src/services/`, secured by PostgreSQL RLS.
- **Privileged operations:** Handled via Supabase Edge Functions (Deno/TypeScript) in `eclipse-api/supabase/functions/` with `verify_jwt = true`.

## Edge Function Inventory (MVP)

| Function              | Auth        | Responsibility                                                                                       |
| --------------------- | ----------- | ---------------------------------------------------------------------------------------------------- |
| `enhance-description` | User JWT    | Verifies ownership, `profiles.ai_consent_at`, input length, style, and daily rate limit (`ai_usage` vs. `app_settings.ai.requests_per_day`); reads `work_entries.description` server-side; enforces idempotency via `request_id`; creates `ai` revision (`service_role`); calls OpenAI; logs `ai_usage`. |
| `delete-attachment`   | User JWT    | Verifies ownership of `entry_attachments` row; deletes the Storage object from `evidence` bucket; removes (or archives) the metadata row via `service_role`. |
| `delete-entry`        | User JWT    | Verifies ownership of `work_entries` row; deletes all Storage objects for the entry from `evidence`; explicitly deletes `entry_attachments`, `entry_revisions`, and `work_entries` rows (no DB cascades exist on domain tables). |
| `delete-account`      | User JWT    | Verifies caller; removes all Storage objects under `{user_uuid}/` in `evidence`; explicitly deletes user rows from `ai_usage`, `entry_revisions`, `entry_attachments`, `work_entries`, `entry_categories`, and `ojt_profiles`; deletes the `auth.users` account (cascading to `profiles`). |

## Edge Function Response Convention

Return consistent JSON payloads and standard HTTP status codes (`200`, `400`, `401`, `403`, `404`, `429`, `500`):

```json
{
  "data": {},
  "error": null
}
```

On failure, return a non-sensitive machine-readable `code` and user-safe `message` (never stack traces, SQL errors, or secrets):

```json
{
  "data": null,
  "error": {
    "code": "AI_RATE_LIMITED",
    "message": "Daily AI enhancement limit reached."
  }
}
```

## Validation & Security Rules

- Always derive the caller's identity from the verified JWT (`auth.getUser()`), never from a client-supplied `user_uuid`.
- Revalidate all inputs server-side (UUID format, enum values, text length, ownership).
- For `enhance-description`, always read the source text from `work_entries.description` in PostgreSQL rather than trusting text posted from the browser.
- Use `service_role` only inside Edge Functions after verifying caller identity and ownership.

## Common Mistakes

- Assuming `DELETE FROM work_entries` or `auth.admin.deleteUser()` cascades to domain tables (it does not; domain tables omit `REFERENCES`).
- Allowing clients to insert `source = 'ai'` rows directly into `entry_revisions` (blocked by RLS).
- Skipping `request_id` idempotency checks in `enhance-description` (causes duplicate OpenAI billing on retries/double-clicks).
