-- =============================================================================
-- Eclipse / OJT Chronicle — MVP Database Schema (v1.0.0)
-- Target: Supabase PostgreSQL
--
-- Design alignment:
--   - Business Logic: eclipse-specs/business-logic-v1.1-proposed.md (approved MVP baseline)
--   - Design Choices: eclipse-specs/db-design-choices.md
--
-- Key conventions:
--   1. Idempotent: safe to run on a fresh database or re-run on an existing one.
--   2. Server-only surrogate PK: every table has `id bigint GENERATED ALWAYS AS
--      IDENTITY PRIMARY KEY` strictly for B-tree indexing and arrival order.
--      `id` is never synced or referenced by foreign keys.
--   3. Global identity & FKs: every table has `uuid uuid NOT NULL UNIQUE`, and
--      all cross-table relationships use `*_uuid` columns. Server-side
--      `REFERENCES` constraints are omitted on syncable domain tables so
--      offline-first batches can arrive in any order (see db-design-choices.md §3).
--      The sole declared `REFERENCES` is `profiles.uuid -> auth.users(id)`
--      because profile creation always happens online via the Auth trigger.
--   4. Soft deletes: `archived_at timestamptz` acts as a syncable tombstone;
--      live uniqueness is enforced with partial unique indexes
--      (`WHERE archived_at IS NULL`).
--   5. Security: RLS is enabled on all public tables; direct client DELETE is
--      revoked so permanent deletion runs through Supabase Edge Functions.
--
-- Deferred (post-MVP, add via forward migrations v1.0.1+):
--   - manuscript_sections, manuscript_section_entries, work_entries.approved_for_manuscript
--   - supervisor / faculty reviewer / admin review tables
-- =============================================================================

BEGIN;

-- -----------------------------------------------------------------------------
-- 1. Extensions
-- -----------------------------------------------------------------------------

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- -----------------------------------------------------------------------------
-- 2. Enums (closed vocabularies; see db-design-choices.md §7)
-- -----------------------------------------------------------------------------

DO $$
BEGIN
  CREATE TYPE public.work_entry_status AS ENUM ('draft', 'completed', 'archived');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  CREATE TYPE public.revision_source AS ENUM ('user', 'ai');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  CREATE TYPE public.revision_status AS ENUM ('pending', 'completed', 'failed');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  CREATE TYPE public.revision_review_decision AS ENUM ('pending', 'accepted', 'edited', 'discarded');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  CREATE TYPE public.ai_enhancement_style AS ENUM ('grammar', 'clarity', 'professional');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  CREATE TYPE public.ai_usage_outcome AS ENUM ('completed', 'failed', 'rate_limited');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

-- -----------------------------------------------------------------------------
-- 3. Tables
-- -----------------------------------------------------------------------------

-- 3.1 profiles
-- Application profile for an authenticated OJT student.
-- `uuid` mirrors `auth.users.id` (created online via trigger on sign-up).
CREATE TABLE IF NOT EXISTS public.profiles (
  id                   bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  uuid                 uuid NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name            text,
  school_name          text,
  program              text,
  timezone             text NOT NULL DEFAULT 'Asia/Manila',
  ai_consent_at        timestamptz,
  upload_notice_ack_at timestamptz,
  created_by           uuid,
  created_at           timestamptz NOT NULL DEFAULT now(),
  updated_at           timestamptz NOT NULL DEFAULT now(),
  archived_at          timestamptz,
  CONSTRAINT profiles_pkey PRIMARY KEY (id)
);

-- 3.2 ojt_profiles
-- Internship placement details and required hours for a student.
CREATE TABLE IF NOT EXISTS public.ojt_profiles (
  id              bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  uuid            uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  user_uuid       uuid NOT NULL,
  company_name    text,
  department      text,
  supervisor_name text,
  start_date      date,
  end_date        date,
  required_hours  numeric(6,2),
  created_by      uuid,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now(),
  archived_at     timestamptz,
  CONSTRAINT ojt_profiles_pkey PRIMARY KEY (id),
  CONSTRAINT ojt_profiles_dates_check CHECK (
    end_date IS NULL OR start_date IS NULL OR end_date >= start_date
  ),
  CONSTRAINT ojt_profiles_required_hours_check CHECK (
    required_hours IS NULL OR required_hours >= 0
  )
);

-- 3.3 entry_categories
-- Activity labels: system-defined (`user_uuid IS NULL`) or student-defined.
CREATE TABLE IF NOT EXISTS public.entry_categories (
  id          bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  uuid        uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  user_uuid   uuid,
  name        text NOT NULL,
  created_by  uuid,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now(),
  archived_at timestamptz,
  CONSTRAINT entry_categories_pkey PRIMARY KEY (id),
  CONSTRAINT entry_categories_name_not_blank CHECK (btrim(name) <> '')
);

-- 3.4 work_entries
-- Daily OJT activity logs and work-hour entries.
CREATE TABLE IF NOT EXISTS public.work_entries (
  id                     bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  uuid                   uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  user_uuid              uuid NOT NULL,
  ojt_profile_uuid       uuid,
  category_uuid          uuid,
  accepted_revision_uuid uuid,
  title                  text NOT NULL,
  work_date              date NOT NULL,
  hours_rendered         numeric(4,2),
  description            text,
  status                 public.work_entry_status NOT NULL DEFAULT 'draft',
  search_vector          tsvector,
  created_by             uuid,
  created_at             timestamptz NOT NULL DEFAULT now(),
  updated_at             timestamptz NOT NULL DEFAULT now(),
  archived_at            timestamptz,
  CONSTRAINT work_entries_pkey PRIMARY KEY (id),
  CONSTRAINT work_entries_title_not_blank CHECK (btrim(title) <> ''),
  CONSTRAINT work_entries_hours_check CHECK (
    hours_rendered IS NULL OR (hours_rendered >= 0 AND hours_rendered <= 24)
  ),
  CONSTRAINT work_entries_archived_sync_check CHECK (
    (status = 'archived') = (archived_at IS NOT NULL)
  )
);

-- 3.5 entry_attachments
-- Metadata and private Supabase Storage path for screenshot evidence.
CREATE TABLE IF NOT EXISTS public.entry_attachments (
  id           bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  uuid         uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  entry_uuid   uuid NOT NULL,
  user_uuid    uuid NOT NULL,
  storage_path text NOT NULL,
  file_name    text NOT NULL,
  mime_type    text NOT NULL,
  file_size    bigint NOT NULL,
  caption      text,
  sort_order   integer NOT NULL DEFAULT 0,
  uploaded_at  timestamptz NOT NULL DEFAULT now(),
  created_by   uuid,
  created_at   timestamptz NOT NULL DEFAULT now(),
  updated_at   timestamptz NOT NULL DEFAULT now(),
  archived_at  timestamptz,
  CONSTRAINT entry_attachments_pkey PRIMARY KEY (id),
  CONSTRAINT entry_attachments_file_name_not_blank CHECK (btrim(file_name) <> ''),
  CONSTRAINT entry_attachments_mime_type_check CHECK (
    mime_type IN ('image/jpeg', 'image/png', 'image/webp')
  ),
  CONSTRAINT entry_attachments_file_size_check CHECK (file_size > 0),
  CONSTRAINT entry_attachments_sort_order_check CHECK (sort_order >= 0)
);

-- 3.6 entry_revisions
-- Append-only user and AI text versions for a work entry.
-- `original_text` is immutable once written.
CREATE TABLE IF NOT EXISTS public.entry_revisions (
  id              bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  uuid            uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  entry_uuid      uuid NOT NULL,
  user_uuid       uuid NOT NULL,
  revision_number integer NOT NULL,
  source          public.revision_source NOT NULL,
  original_text   text NOT NULL,
  enhanced_text   text,
  style           public.ai_enhancement_style,
  status          public.revision_status NOT NULL DEFAULT 'completed',
  error_code      text,
  review_decision public.revision_review_decision NOT NULL DEFAULT 'pending',
  final_text      text,
  ai_model        text,
  prompt_version  text,
  request_id      uuid,
  enhanced_at     timestamptz,
  created_by      uuid,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now(),
  archived_at     timestamptz,
  CONSTRAINT entry_revisions_pkey PRIMARY KEY (id),
  CONSTRAINT entry_revisions_number_positive CHECK (revision_number > 0),
  CONSTRAINT entry_revisions_user_no_enhanced CHECK (
    source <> 'user' OR enhanced_text IS NULL
  )
);

-- 3.7 ai_usage
-- Server-written log of AI enhancement requests for rate limiting & cost tracking.
CREATE TABLE IF NOT EXISTS public.ai_usage (
  id            bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  uuid          uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  user_uuid     uuid NOT NULL,
  revision_uuid uuid,
  model         text,
  input_tokens  integer,
  output_tokens integer,
  outcome       public.ai_usage_outcome NOT NULL,
  requested_at  timestamptz NOT NULL DEFAULT now(),
  created_by    uuid,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now(),
  archived_at   timestamptz,
  CONSTRAINT ai_usage_pkey PRIMARY KEY (id),
  CONSTRAINT ai_usage_input_tokens_check CHECK (input_tokens IS NULL OR input_tokens >= 0),
  CONSTRAINT ai_usage_output_tokens_check CHECK (output_tokens IS NULL OR output_tokens >= 0)
);

-- 3.8 app_settings
-- Configurable platform settings stored as rows (see db-design-choices.md §7).
CREATE TABLE IF NOT EXISTS public.app_settings (
  id          bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  uuid        uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  feature     text NOT NULL,
  name        text NOT NULL,
  value       text NOT NULL,
  description text,
  created_by  uuid,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now(),
  archived_at timestamptz,
  CONSTRAINT app_settings_pkey PRIMARY KEY (id),
  CONSTRAINT app_settings_feature_not_blank CHECK (btrim(feature) <> ''),
  CONSTRAINT app_settings_name_not_blank CHECK (btrim(name) <> '')
);

-- -----------------------------------------------------------------------------
-- 4. Indexes
-- -----------------------------------------------------------------------------

-- ojt_profiles
CREATE INDEX IF NOT EXISTS idx_ojt_profiles_user_uuid
  ON public.ojt_profiles (user_uuid);
CREATE INDEX IF NOT EXISTS idx_ojt_profiles_user_live
  ON public.ojt_profiles (user_uuid) WHERE archived_at IS NULL;

-- entry_categories
CREATE INDEX IF NOT EXISTS idx_entry_categories_user_uuid
  ON public.entry_categories (user_uuid);
CREATE UNIQUE INDEX IF NOT EXISTS idx_entry_categories_system_name_live
  ON public.entry_categories (lower(btrim(name)))
  WHERE user_uuid IS NULL AND archived_at IS NULL;
CREATE UNIQUE INDEX IF NOT EXISTS idx_entry_categories_user_name_live
  ON public.entry_categories (user_uuid, lower(btrim(name)))
  WHERE user_uuid IS NOT NULL AND archived_at IS NULL;

-- work_entries
CREATE INDEX IF NOT EXISTS idx_work_entries_user_uuid
  ON public.work_entries (user_uuid);
CREATE INDEX IF NOT EXISTS idx_work_entries_user_timeline_live
  ON public.work_entries (user_uuid, work_date DESC, created_at DESC, id DESC)
  WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_work_entries_ojt_profile_uuid
  ON public.work_entries (ojt_profile_uuid);
CREATE INDEX IF NOT EXISTS idx_work_entries_category_uuid
  ON public.work_entries (category_uuid);
CREATE INDEX IF NOT EXISTS idx_work_entries_accepted_revision_uuid
  ON public.work_entries (accepted_revision_uuid);
CREATE INDEX IF NOT EXISTS idx_work_entries_search_vector
  ON public.work_entries USING GIN (search_vector);

-- entry_attachments
CREATE INDEX IF NOT EXISTS idx_entry_attachments_entry_uuid
  ON public.entry_attachments (entry_uuid, sort_order);
CREATE INDEX IF NOT EXISTS idx_entry_attachments_user_uuid
  ON public.entry_attachments (user_uuid);
CREATE UNIQUE INDEX IF NOT EXISTS idx_entry_attachments_storage_path_live
  ON public.entry_attachments (storage_path)
  WHERE archived_at IS NULL;

-- entry_revisions
CREATE INDEX IF NOT EXISTS idx_entry_revisions_entry_uuid
  ON public.entry_revisions (entry_uuid);
CREATE INDEX IF NOT EXISTS idx_entry_revisions_user_uuid
  ON public.entry_revisions (user_uuid);
CREATE UNIQUE INDEX IF NOT EXISTS idx_entry_revisions_entry_number_live
  ON public.entry_revisions (entry_uuid, revision_number)
  WHERE archived_at IS NULL;
CREATE UNIQUE INDEX IF NOT EXISTS idx_entry_revisions_entry_request_id_live
  ON public.entry_revisions (entry_uuid, request_id)
  WHERE request_id IS NOT NULL AND archived_at IS NULL;

-- ai_usage
CREATE INDEX IF NOT EXISTS idx_ai_usage_user_requested_at
  ON public.ai_usage (user_uuid, requested_at DESC);
CREATE INDEX IF NOT EXISTS idx_ai_usage_revision_uuid
  ON public.ai_usage (revision_uuid);

-- app_settings
CREATE UNIQUE INDEX IF NOT EXISTS idx_app_settings_feature_name_live
  ON public.app_settings (feature, name)
  WHERE archived_at IS NULL;

-- -----------------------------------------------------------------------------
-- 5. Functions & Triggers
-- -----------------------------------------------------------------------------

-- 5.1 Maintain `updated_at` on online updates while preserving explicit
--     client-supplied timestamps during offline-first LWW sync.
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public, pg_temp
AS $$
BEGIN
  IF NEW.updated_at IS NULL OR NEW.updated_at = OLD.updated_at THEN
    NEW.updated_at := now();
  END IF;
  RETURN NEW;
END;
$$;

-- 5.2 Server-stamp `created_by` from the authenticated session on insert
--     so clients cannot spoof ownership (see db-design-choices.md §4).
CREATE OR REPLACE FUNCTION public.stamp_created_by()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public, pg_temp
AS $$
BEGIN
  IF auth.uid() IS NOT NULL THEN
    NEW.created_by := auth.uid();
  END IF;
  RETURN NEW;
END;
$$;

-- 5.3 Automatically create a `profiles` row when a user signs up in Supabase Auth.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  INSERT INTO public.profiles (uuid, full_name, created_by)
  VALUES (
    NEW.id,
    COALESCE(
      NEW.raw_user_meta_data ->> 'full_name',
      NEW.raw_user_meta_data ->> 'name'
    ),
    NEW.id
  )
  ON CONFLICT (uuid) DO NOTHING;

  RETURN NEW;
END;
$$;

-- 5.4 Assign sequential `revision_number` per `entry_uuid` server-side to avoid races.
CREATE OR REPLACE FUNCTION public.assign_entry_revision_number()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public, pg_temp
AS $$
DECLARE
  v_next_number integer;
BEGIN
  IF NEW.revision_number IS NULL THEN
    PERFORM pg_advisory_xact_lock(hashtext(NEW.entry_uuid::text));

    SELECT COALESCE(MAX(revision_number), 0) + 1
      INTO v_next_number
      FROM public.entry_revisions
     WHERE entry_uuid = NEW.entry_uuid
       AND archived_at IS NULL;

    NEW.revision_number := v_next_number;
  END IF;
  RETURN NEW;
END;
$$;

-- 5.5 Enforce immutability of `entry_revisions.original_text`.
CREATE OR REPLACE FUNCTION public.protect_revision_original_text()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public, pg_temp
AS $$
BEGIN
  IF NEW.original_text IS DISTINCT FROM OLD.original_text THEN
    RAISE EXCEPTION 'entry_revisions.original_text is immutable and cannot be modified';
  END IF;
  RETURN NEW;
END;
$$;

-- 5.6 Maintain `work_entries.search_vector` from title + effective text
--     (accepted revision `final_text` if present, otherwise `description`).
CREATE OR REPLACE FUNCTION public.refresh_work_entry_search_vector()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public, pg_temp
AS $$
DECLARE
  v_effective_text text;
BEGIN
  IF NEW.accepted_revision_uuid IS NOT NULL THEN
    SELECT er.final_text
      INTO v_effective_text
      FROM public.entry_revisions er
     WHERE er.uuid = NEW.accepted_revision_uuid
       AND er.entry_uuid = NEW.uuid
       AND er.archived_at IS NULL;
  END IF;

  v_effective_text := COALESCE(v_effective_text, NEW.description, '');

  NEW.search_vector :=
    setweight(to_tsvector('english', COALESCE(NEW.title, '')), 'A') ||
    setweight(to_tsvector('english', v_effective_text), 'B');

  RETURN NEW;
END;
$$;

-- 5.7 Refresh parent `work_entries.search_vector` when its accepted revision
--     arrives or updates `final_text` / `archived_at`.
CREATE OR REPLACE FUNCTION public.sync_work_entry_search_on_revision_change()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public, pg_temp
AS $$
BEGIN
  UPDATE public.work_entries we
     SET search_vector =
           setweight(to_tsvector('english', COALESCE(we.title, '')), 'A') ||
           setweight(
             to_tsvector(
               'english',
               COALESCE(
                 CASE WHEN NEW.archived_at IS NULL THEN NEW.final_text ELSE NULL END,
                 we.description,
                 ''
               )
             ),
             'B'
           )
   WHERE we.uuid = NEW.entry_uuid
     AND we.accepted_revision_uuid = NEW.uuid;

  RETURN NEW;
END;
$$;

-- Attach `set_updated_at` triggers
DROP TRIGGER IF EXISTS trg_profiles_set_updated_at ON public.profiles;
CREATE TRIGGER trg_profiles_set_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS trg_ojt_profiles_set_updated_at ON public.ojt_profiles;
CREATE TRIGGER trg_ojt_profiles_set_updated_at
  BEFORE UPDATE ON public.ojt_profiles
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS trg_entry_categories_set_updated_at ON public.entry_categories;
CREATE TRIGGER trg_entry_categories_set_updated_at
  BEFORE UPDATE ON public.entry_categories
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS trg_work_entries_set_updated_at ON public.work_entries;
CREATE TRIGGER trg_work_entries_set_updated_at
  BEFORE UPDATE OF user_uuid, ojt_profile_uuid, category_uuid, accepted_revision_uuid,
                   title, work_date, hours_rendered, description, status, archived_at
  ON public.work_entries
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS trg_entry_attachments_set_updated_at ON public.entry_attachments;
CREATE TRIGGER trg_entry_attachments_set_updated_at
  BEFORE UPDATE ON public.entry_attachments
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS trg_entry_revisions_set_updated_at ON public.entry_revisions;
CREATE TRIGGER trg_entry_revisions_set_updated_at
  BEFORE UPDATE ON public.entry_revisions
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS trg_ai_usage_set_updated_at ON public.ai_usage;
CREATE TRIGGER trg_ai_usage_set_updated_at
  BEFORE UPDATE ON public.ai_usage
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS trg_app_settings_set_updated_at ON public.app_settings;
CREATE TRIGGER trg_app_settings_set_updated_at
  BEFORE UPDATE ON public.app_settings
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- Attach `stamp_created_by` triggers
DROP TRIGGER IF EXISTS trg_ojt_profiles_stamp_created_by ON public.ojt_profiles;
CREATE TRIGGER trg_ojt_profiles_stamp_created_by
  BEFORE INSERT ON public.ojt_profiles
  FOR EACH ROW EXECUTE FUNCTION public.stamp_created_by();

DROP TRIGGER IF EXISTS trg_entry_categories_stamp_created_by ON public.entry_categories;
CREATE TRIGGER trg_entry_categories_stamp_created_by
  BEFORE INSERT ON public.entry_categories
  FOR EACH ROW EXECUTE FUNCTION public.stamp_created_by();

DROP TRIGGER IF EXISTS trg_work_entries_stamp_created_by ON public.work_entries;
CREATE TRIGGER trg_work_entries_stamp_created_by
  BEFORE INSERT ON public.work_entries
  FOR EACH ROW EXECUTE FUNCTION public.stamp_created_by();

DROP TRIGGER IF EXISTS trg_entry_attachments_stamp_created_by ON public.entry_attachments;
CREATE TRIGGER trg_entry_attachments_stamp_created_by
  BEFORE INSERT ON public.entry_attachments
  FOR EACH ROW EXECUTE FUNCTION public.stamp_created_by();

DROP TRIGGER IF EXISTS trg_entry_revisions_stamp_created_by ON public.entry_revisions;
CREATE TRIGGER trg_entry_revisions_stamp_created_by
  BEFORE INSERT ON public.entry_revisions
  FOR EACH ROW EXECUTE FUNCTION public.stamp_created_by();

-- Attach Auth sign-up trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Attach domain triggers
DROP TRIGGER IF EXISTS trg_entry_revisions_assign_number ON public.entry_revisions;
CREATE TRIGGER trg_entry_revisions_assign_number
  BEFORE INSERT ON public.entry_revisions
  FOR EACH ROW EXECUTE FUNCTION public.assign_entry_revision_number();

DROP TRIGGER IF EXISTS trg_entry_revisions_protect_original_text ON public.entry_revisions;
CREATE TRIGGER trg_entry_revisions_protect_original_text
  BEFORE UPDATE ON public.entry_revisions
  FOR EACH ROW EXECUTE FUNCTION public.protect_revision_original_text();

DROP TRIGGER IF EXISTS trg_work_entries_search_vector ON public.work_entries;
CREATE TRIGGER trg_work_entries_search_vector
  BEFORE INSERT OR UPDATE OF title, description, accepted_revision_uuid ON public.work_entries
  FOR EACH ROW EXECUTE FUNCTION public.refresh_work_entry_search_vector();

DROP TRIGGER IF EXISTS trg_entry_revisions_sync_search ON public.entry_revisions;
CREATE TRIGGER trg_entry_revisions_sync_search
  AFTER INSERT OR UPDATE OF final_text, archived_at ON public.entry_revisions
  FOR EACH ROW EXECUTE FUNCTION public.sync_work_entry_search_on_revision_change();

-- -----------------------------------------------------------------------------
-- 6. Row Level Security (RLS) & Table Privileges
-- -----------------------------------------------------------------------------

ALTER TABLE public.profiles          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ojt_profiles      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.entry_categories  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.work_entries      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.entry_attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.entry_revisions   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_usage          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_settings      ENABLE ROW LEVEL SECURITY;

-- Least-privilege table grants:
-- Clients never have direct DELETE on user tables (permanent deletes run via
-- Edge Functions; soft deletes set `archived_at`).
-- Clients have read-only access to `ai_usage` and `app_settings`.
REVOKE ALL ON public.profiles          FROM anon, authenticated;
REVOKE ALL ON public.ojt_profiles      FROM anon, authenticated;
REVOKE ALL ON public.entry_categories  FROM anon, authenticated;
REVOKE ALL ON public.work_entries      FROM anon, authenticated;
REVOKE ALL ON public.entry_attachments FROM anon, authenticated;
REVOKE ALL ON public.entry_revisions   FROM anon, authenticated;
REVOKE ALL ON public.ai_usage          FROM anon, authenticated;
REVOKE ALL ON public.app_settings      FROM anon, authenticated;

GRANT SELECT, UPDATE         ON public.profiles          TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.ojt_profiles      TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.entry_categories  TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.work_entries      TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.entry_attachments TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.entry_revisions   TO authenticated;
GRANT SELECT                 ON public.ai_usage          TO authenticated;
GRANT SELECT                 ON public.app_settings      TO authenticated;

-- 6.1 profiles policies
DROP POLICY IF EXISTS "profiles_select_own" ON public.profiles;
CREATE POLICY "profiles_select_own"
  ON public.profiles FOR SELECT
  TO authenticated
  USING (uuid = auth.uid());

DROP POLICY IF EXISTS "profiles_update_own" ON public.profiles;
CREATE POLICY "profiles_update_own"
  ON public.profiles FOR UPDATE
  TO authenticated
  USING (uuid = auth.uid())
  WITH CHECK (uuid = auth.uid());

-- 6.2 ojt_profiles policies
DROP POLICY IF EXISTS "ojt_profiles_select_own" ON public.ojt_profiles;
CREATE POLICY "ojt_profiles_select_own"
  ON public.ojt_profiles FOR SELECT
  TO authenticated
  USING (user_uuid = auth.uid());

DROP POLICY IF EXISTS "ojt_profiles_insert_own" ON public.ojt_profiles;
CREATE POLICY "ojt_profiles_insert_own"
  ON public.ojt_profiles FOR INSERT
  TO authenticated
  WITH CHECK (user_uuid = auth.uid());

DROP POLICY IF EXISTS "ojt_profiles_update_own" ON public.ojt_profiles;
CREATE POLICY "ojt_profiles_update_own"
  ON public.ojt_profiles FOR UPDATE
  TO authenticated
  USING (user_uuid = auth.uid())
  WITH CHECK (user_uuid = auth.uid());

-- 6.3 entry_categories policies
DROP POLICY IF EXISTS "entry_categories_select_system_or_own" ON public.entry_categories;
CREATE POLICY "entry_categories_select_system_or_own"
  ON public.entry_categories FOR SELECT
  TO authenticated
  USING (user_uuid IS NULL OR user_uuid = auth.uid());

DROP POLICY IF EXISTS "entry_categories_insert_own" ON public.entry_categories;
CREATE POLICY "entry_categories_insert_own"
  ON public.entry_categories FOR INSERT
  TO authenticated
  WITH CHECK (user_uuid = auth.uid());

DROP POLICY IF EXISTS "entry_categories_update_own" ON public.entry_categories;
CREATE POLICY "entry_categories_update_own"
  ON public.entry_categories FOR UPDATE
  TO authenticated
  USING (user_uuid = auth.uid())
  WITH CHECK (user_uuid = auth.uid());

-- 6.4 work_entries policies
DROP POLICY IF EXISTS "work_entries_select_own" ON public.work_entries;
CREATE POLICY "work_entries_select_own"
  ON public.work_entries FOR SELECT
  TO authenticated
  USING (user_uuid = auth.uid());

DROP POLICY IF EXISTS "work_entries_insert_own" ON public.work_entries;
CREATE POLICY "work_entries_insert_own"
  ON public.work_entries FOR INSERT
  TO authenticated
  WITH CHECK (user_uuid = auth.uid());

DROP POLICY IF EXISTS "work_entries_update_own" ON public.work_entries;
CREATE POLICY "work_entries_update_own"
  ON public.work_entries FOR UPDATE
  TO authenticated
  USING (user_uuid = auth.uid())
  WITH CHECK (user_uuid = auth.uid());

-- 6.5 entry_attachments policies
DROP POLICY IF EXISTS "entry_attachments_select_own" ON public.entry_attachments;
CREATE POLICY "entry_attachments_select_own"
  ON public.entry_attachments FOR SELECT
  TO authenticated
  USING (user_uuid = auth.uid());

DROP POLICY IF EXISTS "entry_attachments_insert_own" ON public.entry_attachments;
CREATE POLICY "entry_attachments_insert_own"
  ON public.entry_attachments FOR INSERT
  TO authenticated
  WITH CHECK (user_uuid = auth.uid());

DROP POLICY IF EXISTS "entry_attachments_update_own" ON public.entry_attachments;
CREATE POLICY "entry_attachments_update_own"
  ON public.entry_attachments FOR UPDATE
  TO authenticated
  USING (user_uuid = auth.uid())
  WITH CHECK (user_uuid = auth.uid());

-- 6.6 entry_revisions policies
DROP POLICY IF EXISTS "entry_revisions_select_own" ON public.entry_revisions;
CREATE POLICY "entry_revisions_select_own"
  ON public.entry_revisions FOR SELECT
  TO authenticated
  USING (user_uuid = auth.uid());

DROP POLICY IF EXISTS "entry_revisions_insert_own" ON public.entry_revisions;
CREATE POLICY "entry_revisions_insert_own"
  ON public.entry_revisions FOR INSERT
  TO authenticated
  WITH CHECK (user_uuid = auth.uid() AND source = 'user');

DROP POLICY IF EXISTS "entry_revisions_update_own" ON public.entry_revisions;
CREATE POLICY "entry_revisions_update_own"
  ON public.entry_revisions FOR UPDATE
  TO authenticated
  USING (user_uuid = auth.uid())
  WITH CHECK (user_uuid = auth.uid());

-- 6.7 ai_usage policies (read-only for owner; written by Edge Functions via service_role)
DROP POLICY IF EXISTS "ai_usage_select_own" ON public.ai_usage;
CREATE POLICY "ai_usage_select_own"
  ON public.ai_usage FOR SELECT
  TO authenticated
  USING (user_uuid = auth.uid());

-- 6.8 app_settings policies (read-only live settings for authenticated users)
DROP POLICY IF EXISTS "app_settings_select_live" ON public.app_settings;
CREATE POLICY "app_settings_select_live"
  ON public.app_settings FOR SELECT
  TO authenticated
  USING (archived_at IS NULL);

-- -----------------------------------------------------------------------------
-- 7. Supabase Storage — Private Evidence Bucket & Policies
-- -----------------------------------------------------------------------------

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'evidence',
  'evidence',
  false,
  5242880, -- 5 MB
  ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- Object path convention: {user_uuid}/{entry_uuid}/{attachment_uuid}.{ext}
-- Clients may read, upload, and update objects inside their own prefix only;
-- permanent object deletion is performed by the `delete-attachment`,
-- `delete-entry`, and `delete-account` Edge Functions using the service-role key.
DROP POLICY IF EXISTS "evidence_select_own" ON storage.objects;
CREATE POLICY "evidence_select_own"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (
    bucket_id = 'evidence'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

DROP POLICY IF EXISTS "evidence_insert_own" ON storage.objects;
CREATE POLICY "evidence_insert_own"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'evidence'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

DROP POLICY IF EXISTS "evidence_update_own" ON storage.objects;
CREATE POLICY "evidence_update_own"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (
    bucket_id = 'evidence'
    AND (storage.foldername(name))[1] = auth.uid()::text
  )
  WITH CHECK (
    bucket_id = 'evidence'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

-- -----------------------------------------------------------------------------
-- 8. Idempotent Baseline Reference Data
-- -----------------------------------------------------------------------------

-- System-defined entry categories (deterministic UUIDs so re-runs are no-ops)
INSERT INTO public.entry_categories (uuid, user_uuid, name)
VALUES
  ('00000000-0000-4000-8000-000000000101', NULL, 'Development'),
  ('00000000-0000-4000-8000-000000000102', NULL, 'Documentation'),
  ('00000000-0000-4000-8000-000000000103', NULL, 'Testing & QA'),
  ('00000000-0000-4000-8000-000000000104', NULL, 'Meetings & Coordination'),
  ('00000000-0000-4000-8000-000000000105', NULL, 'Research & Learning'),
  ('00000000-0000-4000-8000-000000000106', NULL, 'Support & Operations'),
  ('00000000-0000-4000-8000-000000000107', NULL, 'Other')
ON CONFLICT (uuid) DO NOTHING;

-- Default platform settings
INSERT INTO public.app_settings (uuid, feature, name, value, description)
VALUES
  ('00000000-0000-4000-8000-000000000201', 'attachments', 'max_file_size_bytes', '5242880', 'Maximum compressed image upload size in bytes (5 MB).'),
  ('00000000-0000-4000-8000-000000000202', 'attachments', 'max_per_entry',       '10',      'Maximum number of image attachments allowed per work entry.'),
  ('00000000-0000-4000-8000-000000000203', 'ai',          'requests_per_day',    '20',      'Default per-user daily AI enhancement request limit.')
ON CONFLICT (uuid) DO NOTHING;

COMMIT;
