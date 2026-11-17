# 10 — Deployment

**Purpose:** This document defines the intended release order and deployment guardrails for the Eclipse ecosystem. It records what a deployable service needs and how the team should coordinate release steps across the web, mobile, API, and specs repositories.

**Confidence note:** Verified against the current repo scaffold on 2026-11-17. No production deployment manifests or app builds are present, so this is an operational template awaiting real deployment configuration.

## Release order

1. Update specs and business rules.
2. Ship backend API changes and migrations.
3. Validate API compatibility and smoke tests.
4. Deploy web app updates.
5. Deploy Android app updates only after the API contract is confirmed.
6. Verify release notes, telemetry, and rollback readiness.

## What each deployable needs

| Component   | Must have before release                                               |
| ----------- | ---------------------------------------------------------------------- |
| API         | versioned change set, migration plan, env config, smoke test           |
| Web app     | build artifact, env variables, reverse proxy or static hosting config  |
| Android app | release config, signing, app version metadata, API compatibility check |
| Specs       | versioned requirements and decision record changes                     |

## Tags and release discipline

- Tag the API, web app, Android app, and specs repo consistently for a release train.
- If one component is incompatible with another, treat the release as a blocked deployment.
- Record the exact version used during smoke tests and rollback decisions.

## Release checklist

- Confirm the service and clients are on compatible contract versions.
- Verify configuration values for each environment.
- Confirm auth providers, tokens, and secrets are valid.
- Run smoke tests on the changed path.
- Document the rollback route before release approval.

This document should be revised once actual build and deployment files exist in the app repositories.
