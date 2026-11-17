# 14 — Developer Workflows

**Purpose:** This document lists the repeatable recipes the team should use for daily work, release prep, and contract-safe feature changes. It is designed to reduce avoidable mistakes, especially in a multi-repo system.

**Confidence note:** Verified against the current repo scaffold on 2026-11-17. No implementation runtimes or app-specific workflows are present yet, so this is a baseline workflow template rather than a fully proven operating procedure.

## Setup

1. Clone or open the relevant repository: API, web, Android, or specs.
2. Confirm the repo is in the expected branch state with a fresh `git status` check.
3. Check the relevant spec and lockstep documents before making a feature change.
4. Verify environment variables, auth config, and expected endpoints before running the app.

## Common recipe: feature change across repos

1. Start with the change in specs or the product decision record.
2. Update the API contract or data model.
3. Update the web or Android clients that consume that contract.
4. Run a smoke test on the affected flow.
5. Verify both the feature and the failure path.
6. Record the change in the relevant inbox or skills document if the pattern is new.

## Common recipe: debugging a drift bug

1. Confirm the repo state is not empty or stale.
2. Compare the server response to the client expectation.
3. Trace the auth and validation path before searching deeper.
4. Check environment config and release version alignment.
5. Add a short failing note to `INBOX.md` if the cause is not yet clear.

## Common recipe: release prep

1. Review the relevant lockstep set and deployment notes.
2. Confirm release versions and environment config.
3. Run smoke checks across the changed components.
4. Record the rollback decision before pushing to the release environment.

> add what surprised you to `INBOX.md`

This workflow is intentionally simple because the current codebase is still a project scaffold. Once real app code exists, the team should replace these baselines with concrete repo commands and release checks.
