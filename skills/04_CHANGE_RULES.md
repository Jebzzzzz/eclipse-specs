# 04 — Change Rules

**Purpose:** This document lists the lockstep changes that need to happen together to avoid drift between the product specs, API, web app, Android app, and deployment setup.

**Confidence note:** Verified against the current repo scaffold on 2026-11-17. The actual application is absent, so these rules are deliberately written as operating constraints for future implementation rather than a log of past production changes.

## Core lockstep sets

### 1. Product requirements and app behavior

- Change set: [eclipse-specs](../), API, web client, Android client
- Miss → a product request is implemented in one repo and reinterpreted differently elsewhere, causing inconsistent behavior and support churn.
- Retest: user flow, auth behavior, role-based access, and release notes.

### 2. API contract and client usage

- Change set: API contract, web app calls, Android app calls
- Miss → clients drift from the server contract, creating failures that look random but are actually version mismatches.
- Retest: request/response envelopes, field names, error codes, and auth headers.

### 3. Data model and schema migration

- Change set: schema or DB migration, API validators, UI forms, specs notes
- Miss → form inputs and server persistence disagree, causing silent data loss or corruption.
- Retest: create, update, delete flows, soft deletes, and default values.

### 4. Auth and authorization

- Change set: identity provider config, API authorization checks, web route guards, Android auth flow
- Miss → users can authenticate but still hit unauthorized actions, or private data leaks into client state.
- Retest: sign-in, role checks, token refresh, and expired session handling.

### 5. Release configuration and deployment

- Change set: version tags, env config, API config, build pipeline, web/Android app packaging
- Miss → a deployable build goes live without the server or config it expects, producing mismatched environments.
- Retest: smoke tests across each environment and release checklist validation.

## Hidden dependencies

- A specification change without an implementation change is a decision, not a feature.
- A client-only change without an API review can create a contract mismatch that appears only in staging.
- A deployment or config change without a rollback plan creates operational risk independent of app code.

## High-risk areas

1. Auth and token refresh
2. Database schema changes and soft deletes
3. API versioning and route compatibility
4. Secrets, environment variables, and test credentials
5. Cross-repo release timing

## Review checklist for every feature change

1. Identify which repos are in scope.
2. Check whether the change touches a lockstep set.
3. Confirm the contract or rule is documented in specs.
4. Run a smoke test across the affected clients.
5. Record the rollback or revert path before merging.

This set is deliberately conservative and should be tightened once the codebase contains real features and configuration files.
